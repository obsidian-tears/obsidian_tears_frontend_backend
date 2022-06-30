import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Char "mo:base/Char";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Random "mo:base/Random";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

import AID "../motoko/util/AccountIdentifier";
import ExtCore "../motoko/ext/Core";
import X "./types";

actor class ObsidianTearsRpg() = this {
    // Types
    type AccountIdentifier = ExtCore.AccountIdentifier;
    type TokenIndex = ExtCore.TokenIndex;
    type CommonError = ExtCore.CommonError;
    type SessionData = {
        createdAt : Time.Time;
        goldEarned : Nat16;
        itemsEarned : Nat8;
    };
    public type TxReceipt = {
        #Ok: Nat;
        #Err: {
            #InsufficientAllowance;
            #InsufficientBalance;
            #ErrorOperationStyle;
            #Unauthorized;
            #LedgerTrap;
            #ErrorTo;
            #Other: Text;
            #BlockUsed;
            #AmountTooSmall;
        };
    };

    // Canister Info
    var _name = "Obsidian Tears RPG";

    // Config
    private stable var SESSION_LIFE : Time.Time = 24*60*60*1_000_000_000; // remove sessions after 24 hr (clear gain limits)
    private stable var SESSION_CHECK : Time.Time = 60*60*1_000_000_000; // check sessions every 1 hr
    private stable var REGISTRY_CHECK : Time.Time = 10*60*1_000_000_000; // check sessions every 1 hr
    private stable var MAX_GOLD : Nat16 = 10_000; // max amount of gold earned in 1 session
    private stable var MAX_ITEMS : Nat8 = 10; // max amount of gold earned in 1 session
    private stable var _lastCleared : Time.Time = Time.now(); // keep track of the last time you cleared sessions
    private stable var _lastRegistryUpdate : Time.Time = Time.now(); // keep track of the last time you cleared sessions
    private stable var _runHeartbeat : Bool = true;
    private stable var _minter : Principal = Principal.fromText("6ulqo-ikasf-xzltp-ylrhu-qt4gt-nv4rz-gd46e-nagoe-3bo7b-kbm3h-bqe");
    private stable var _itemCanister : Text = "goei2-daaaa-aaaao-aaiua-cai"; 
    private stable var _characterCanister : Text = "dhyds-jaaaa-aaaao-aaiia-cai";
    // private stable var _goldCanister : Text = "gjfoo-oyaaa-aaaao-aaiuq-cai";  TODO: migrate to standard when it comes out

    // Actors
    let _itemActor = actor(_itemCanister) : actor { mintItem : ({ data : [Nat8]; recipient : AccountIdentifier }) -> async (); getRegistry : () -> async [(TokenIndex, AccountIdentifier)]};
    let _characterActor = actor(_characterCanister) : actor { getRegistry : () -> async [(TokenIndex, AccountIdentifier)]; tokens : (aid : AccountIdentifier) -> async Result.Result<[TokenIndex], CommonError>};
    // let _goldActor = actor (_goldCanister) : actor { mint : (to: Principal, value: Nat) -> async TxReceipt};

    // State
    private stable var _saveDataState : [(TokenIndex, Text)] = [];
    private stable var _sessionsState : [(TokenIndex, SessionData)] = [];
    private stable var _characterRegistryState : [(TokenIndex, AccountIdentifier)] = [];
    private stable var _itemRegistryState : [(TokenIndex, AccountIdentifier)] = [];
    private stable var _equippedItemState : [(TokenIndex, [TokenIndex])] = [];
    private stable var _goldState : [(AccountIdentifier, Nat16)] = [];
    // local
    private var _saveData : HashMap.HashMap<TokenIndex, Text> = HashMap.fromIter(_saveDataState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _sessions : HashMap.HashMap<TokenIndex, SessionData> = HashMap.fromIter(_sessionsState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _equippedItems : HashMap.HashMap<TokenIndex, [TokenIndex]> = HashMap.fromIter(_equippedItemState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _gold : HashMap.HashMap<AccountIdentifier, Nat16> = HashMap.fromIter(_goldState.vals(), 0, AID.equal, AID.hash);
    // TODO map all items to item metadata for minting
    // TODO map all monsters to experience, level, gold, etc
    // TODO map all chests to (json id, opened, item) for loading and deciding what to mint when opening
    // TODO map all markets to items in market
    // TODO track player position in their session. 
    // TODO track player story progress [Nat8]
    // TODO for each treasure chest, market, boss have a list of prerequisite story points that must be toggled
    // TODO map all story points to their index in story progress, with list of prerequisites and optional map position
    // TODO in game asynchronously call checkins and updates to story progress as needed
    // TODO in game await calls that deliver data in game;
    private var _characterRegistry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_characterRegistryState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _itemRegistry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_itemRegistryState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);

    // system functions
    system func preupgrade() {
        _saveDataState := Iter.toArray(_saveData.entries());
        _sessionsState := Iter.toArray(_sessions.entries());
        _characterRegistryState := Iter.toArray(_characterRegistry.entries());
        _itemRegistryState := Iter.toArray(_itemRegistry.entries());
        _equippedItemState := Iter.toArray(_equippedItems.entries());
        _goldState := Iter.toArray(_gold.entries());
    };

    system func postupgrade() {
        _saveDataState := [];
        _sessionsState := [];
        _characterRegistryState := [];
        _itemRegistryState := [];
        _equippedItemState := [];
        _goldState := [];
    };

    system func heartbeat() : async () {
        if(_runHeartbeat and Time.now() >= _lastRegistryUpdate + REGISTRY_CHECK) {
            // every ten minutes, pull the latest character and item registry
            try {
                await getCharacterRegistry();
                await getItemRegistry();
            } catch(e) {
                _runHeartbeat := false;
            };
        };
        if(_runHeartbeat == true and Time.now() >= _lastCleared + SESSION_CHECK) {
            // every hour check all the sessions and delete old ones
            try{
                cleanSessions();
                _lastCleared := Time.now();
            } catch(e){
              _runHeartbeat := false;
            };
        };
    };

    // -----------------------------------
    // user interaction with this canister
    // -----------------------------------

    // check if user owns NFT and create session for fast lookup. return owned NFT data
    public shared({ caller }) func verify() : async(X.ApiResponse<[TokenIndex]>) {
        let address : AccountIdentifier = AID.fromPrincipal(caller, null);
        let result : Result.Result<[TokenIndex], CommonError> = await _characterActor.tokens(address);
        switch(result) {
            case(#ok indices) {
                return #Ok indices;
            };
            case(#err e) {
                return #Err(#Other("Error verifying user"));
            };
        };
    };

    // login when user selects 
    public shared({ caller }) func login(characterIndex : TokenIndex) : async(X.ApiResponse<Text>) {
        switch(checkSession(caller, characterIndex)) {
            case(#err e) {
               return #Err e;
            };
            case(session) {};
        };
        // TODO check if they have a saved game
        switch(_saveData.get(characterIndex)) {
            case(?save) {
                // TODO return the saved game summary
                return #Ok save;
            };
            case(_) {
                return #Err(#Other("No save data"));
            };
        };
    };

    // save game data formatted in json so that unity can load correctly
    public shared({ caller }) func saveGame(characterIndex: TokenIndex, gameData : Text) : async(X.ApiResponse<()>) {
        switch(checkSession(caller, characterIndex)) {
            case(#err e) {
               return #Err e;
            };
            case(_) {};
        };
        // TODO save location and dialogs
        #Ok
    };

    public shared({ caller }) func openChest(characterIndex : TokenIndex ) : async(X.ApiResponse<[Nat8]>) {
        switch(checkSession(caller, characterIndex)) {
            case(#err e) {
               return #Err e;
            };
            case(_) {};
        };
        // TODO select an item to open
        let item : [Nat8] = [];
        let address : AccountIdentifier = AID.fromPrincipal(caller, null);
        return await mintItem(item, address);
    };

    public shared({ caller }) func buyItem(characterIndex: TokenIndex, itemData : [Nat8]) : async(X.ApiResponse<[Nat8]>) {
        switch(checkSession(caller, characterIndex)) {
            case(#err e) {
               return #Err e;
            };
            case(_) {};
        };
        // TODO check that the item exists in a valid shop inventory
        let address : AccountIdentifier = AID.fromPrincipal(caller, null);
        return await mintItem(itemData, address);
    };

    public shared({ caller }) func equipItems(characterIndex : TokenIndex, itemIndices : [TokenIndex]) : async(X.ApiResponse<()>) {
        switch(checkSession(caller, characterIndex)) {
            case(#err e) {
               return #Err e;
            };
            case(_) {};
        };
        // make sure that caller owns all items;
        let address : AccountIdentifier = AID.fromPrincipal(caller, null);
        for (itemIndex in itemIndices.vals()) {
            if(_itemRegistry.get(itemIndex) != ?address) {
                return #Err(#Unauthorized);
            };
        };
        // equip items
        _equippedItems.put(characterIndex, itemIndices);
        #Ok;
    };

    public shared(msg) func checkIn() : async() {};

    public query func http_request(request : X.HttpRequest) : async X.HttpResponse {
        return {
          status_code = 200;
          headers = [("content-type", "text/plain")];
          body = Text.encodeUtf8 (
            _name # "\n" #
            "---\n" #
            "Cycle Balance:                            ~" # debug_show (Cycles.balance()/1000000000000) # "T\n" #
            "---\n" #
            "Current Sessions:                         " # debug_show (_sessions.size()) # "\n" #
            "Saved Games:                              " # debug_show (_saveData.size()) # "\n" #
            "---\n" #
            "Admin:                                    " # debug_show (_minter) # "\n"
          );
          streaming_strategy = null;
        };
    };

    // -----------------------------------
    // helper functions
    // -----------------------------------
    // load game data formatted in json so that unity can load correctly
    func loadGame(characterIndex : TokenIndex) : Text {
        // TODO load json directly
        // return _saveData.get(msg.caller)
        return "";
    };

    // manage session memory
    func cleanSessions() {
        for ((principal, session) in _sessions.entries()) {
            // if jwt is older than 24 hr, delete the entry
            if (session.createdAt < Time.now() - SESSION_LIFE) {
                _sessions.delete(principal);
            };
        };
    };


    func checkSession(caller : Principal, tokenIndex : TokenIndex) : Result.Result<SessionData, X.ApiError> {
        // convert principal into wallet
        let address : AccountIdentifier = AID.fromPrincipal(caller, null);
        // make sure the principal owns this tokenIndex
        switch(_characterRegistry.get(tokenIndex)) {
            case(?owner) {
                if (owner != address) {
                    return #err(#Unauthorized);
                };
            };
            case(_) {
                return #err(#Unauthorized);
            };
        };

        // make sure player hasn't exceeded limits for the day
        switch(_sessions.get(tokenIndex)) {
            // if their session has been reset, replace it
            case(?session) {
                if (session.goldEarned >= MAX_GOLD or session.itemsEarned >= MAX_ITEMS){
                    return #err(#Limit);
                } else {
                    return #ok session;
                }
            };
            case(_) {
                let newSession : SessionData = {
                    createdAt = Time.now(); 
                    goldEarned = 0; 
                    itemsEarned = 0; 
                };
                _sessions.put(tokenIndex, newSession);
                #ok newSession;
            };
        };
    };

    func _append<T>(array : [T], val: T) : [T] {
        let new = Array.tabulate<T>(array.size()+1, func(i) {
            if (i < array.size()) {
                array[i];
            } else {
                val;
            };
        });
        new;
    };

    func _getParam(url : Text, param : Text) : ?Text {
          var _s : Text = url;
      Iter.iterate<Text>(Text.split(_s, #text("/")), func(x, _i) {
            _s := x;
      });
      Iter.iterate<Text>(Text.split(_s, #text("?")), func(x, _i) {
            if (_i == 1) _s := x;
      });
      var t : ?Text = null;
      var found : Bool = false;
      Iter.iterate<Text>(Text.split(_s, #text("&")), func(x, _i) {
            if (found == false) {
              Iter.iterate<Text>(Text.split(x, #text("=")), func(y, _ii) {
                if (_ii == 0) {
                  if (Text.equal(y, param)) found := true;
            } else if (found == true) {
                        t := ?y
            };
          });
        };
      });
      return t;
    };

    // -----------------------------------
    // interaction with other canisters
    // -----------------------------------
    // character nft canister will need to call this when transfering a token and initiate transfers in item canister
    public shared(msg) func getEquippedItems(characterIndex : TokenIndex) : async [TokenIndex] {
        switch(_equippedItems.get(characterIndex)) {
            case(?equippedItems) {
                return equippedItems;
            };
            case(_) {
                return [];
            };
        };
    };

    func mintItem(metadata: [Nat8], recipient : AccountIdentifier) : async X.ApiResponse<[Nat8]> {
        try {
            let result = await _itemActor.mintItem({data= metadata; recipient = recipient;});
            return #Ok(metadata);
        } catch(e) {
            return #Err(#Other("Unable to communicate with item canister"));
        }
    };

    func getItemRegistry() : async () {
        let result = await _itemActor.getRegistry();
        _itemRegistry := HashMap.fromIter(result.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    };

    func getCharacterRegistry() : async () {
        let result = await _characterActor.getRegistry();
        _characterRegistry := HashMap.fromIter(result.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    };

    // -----------------------------------
    // management
    // -----------------------------------
    // heartbeat stuff
    public query func isHeartbeatRunning() : async Bool {
        _runHeartbeat;
    };
    public shared(msg) func adminKillHeartbeat() : async () {
        assert(msg.caller == _minter);
        _runHeartbeat := false;
    };
    public shared(msg) func adminStartHeartbeat() : async () {
        assert(msg.caller == _minter);
        _runHeartbeat := true;
    };

    public shared({ caller }) func setMinter(new : Principal) : async Result.Result<(), X.ApiError> {
        if (caller != _minter) return #err(#Unauthorized);
        _minter := new;
        #ok();
    };

    public func acceptCycles() : () {
        let available = Cycles.available();
        let accepted = Cycles.accept(available);
        assert(available == accepted);
    };

    public query func balance() : async Nat {
        Cycles.balance();
    };
};