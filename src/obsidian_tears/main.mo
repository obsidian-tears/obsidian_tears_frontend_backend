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
import ExtCommon "../motoko/ext/Common";
import Ref "./reference";
import X "./types";


// TODO: track what item transfers go through and which don't. any failed transfers will be stored 

actor class ObsidianTearsRpg() = this {
    // Types
    type AccountIdentifier = ExtCore.AccountIdentifier;
    type TokenIndex = ExtCore.TokenIndex;
    type CommonError = ExtCore.CommonError;
    type Metadata = ExtCommon.Metadata;

    type SessionData = {
        createdAt : Time.Time;
        goldEarned : Nat32;
        xpEarned : Nat32;
        itemsEarned : Nat8;
    };
    type RewardInfo = {
        itemIds : [Nat16];
        gold : Nat32;
        xp : Nat32;
    };
    //   \"characterName\":\"Phendrin\",\"characterClass\":\"\",\"level\":1,\"xp\":0,\"xpToLevelUp\":75,
    //   \"pointsRemaining\":0,\"healthBase\":15,\"healthTotal\":15,\"healthMax\":15,\"magicBase\":10,\"magicTotal\":10,
    //   \"magicMax\":10,\"attackBase\":5,\"attackTotal\":5,\"magicPowerBase\":0,\"magicPowerTotal\":0,\"defenseBase\":5,
    //   \"defenseTotal\":5,\"speedBase\":5,\"speedTotal\":5,\"criticalHitProbability\":0.0,\"characterEffects\":[]
    type PlayerData = {
        characterName: Text;
        characterClass: Text;
        level : Nat16;
        xp : Nat32;
        xpToLevelUp : Nat32;
        pointsRemaining : Nat32;
        healthBase : Nat16;
        healthTotal : Nat16;
        healthMax : Nat16;
        magicBase : Nat16;
        magicTotal : Nat16;
        magicMax : Nat16;
        attackBase : Nat16;
        attackTotal : Nat16;
        defenseBase : Nat16;
        defenseTotal : Nat16;
        speedBase : Nat16;
        speedTotal : Nat16;
        criticalHitProbability : Float;
        characterEffects : [Text];
        kills : Nat16;
        deaths : Nat16;
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
    private stable var REGISTRY_CHECK : Time.Time = 10*60*1_000_000_000; // check sessions every 10 minutes
    private stable var MAX_GOLD : Nat32 = 5_000; // max amount of gold earned in 1 session
    private stable var MAX_XP : Nat32 = 5_000; // max amount of gold earned in 1 session
    private stable var MAX_ITEMS : Nat8 = 10; // max amount of gold earned in 1 session
    private stable var _lastCleared : Time.Time = Time.now(); // keep track of the last time you cleared sessions
    private stable var _lastRegistryUpdate : Time.Time = Time.now(); // keep track of the last time you cleared sessions
    private stable var _runHeartbeat : Bool = true;
    private stable var _minter : Principal = Principal.fromText("6ulqo-ikasf-xzltp-ylrhu-qt4gt-nv4rz-gd46e-nagoe-3bo7b-kbm3h-bqe");
    private stable var _itemCanister : Text = "goei2-daaaa-aaaao-aaiua-cai"; 
    private stable var _characterCanister : Text = "dhyds-jaaaa-aaaao-aaiia-cai";
    // TODO: migrate to separate canister under token standard when it comes out: "castar"
    // private stable var _goldCanister : Text = "gjfoo-oyaaa-aaaao-aaiuq-cai";  

    // Actors
    let _itemActor = actor(_itemCanister) : actor { mintItem : ({ data : [Nat8]; recipient : AccountIdentifier }) -> async (); getRegistry : () -> async [(TokenIndex, AccountIdentifier)]; getMetadata : () -> async [(TokenIndex, Metadata)]};
    let _characterActor = actor(_characterCanister) : actor { getRegistry : () -> async [(TokenIndex, AccountIdentifier)]; tokens : (aid : AccountIdentifier) -> async Result.Result<[TokenIndex], CommonError>};
    // let _goldActor = actor (_goldCanister) : actor { mint : (to: Principal, value: Nat) -> async TxReceipt};

    // State
    private stable var _saveDataState : [(TokenIndex, Text)] = [];
    private stable var _sessionsState : [(TokenIndex, SessionData)] = [];
    private stable var _characterRegistryState : [(TokenIndex, AccountIdentifier)] = [];
  	private stable var _itemMetadataState : [(TokenIndex, Metadata)] = [];
    private stable var _itemRegistryState : [(TokenIndex, AccountIdentifier)] = [];
    private stable var _equippedItemsState : [(TokenIndex, [Nat16])] = [];
    private stable var _ownedNonNftItemsState : [(TokenIndex, [Nat16])] = [];
    private stable var _completedEventsState : [(TokenIndex, [Nat16])] = []; // which plot events and chests have been completed
    private stable var _playerDataState : [(TokenIndex, PlayerData)] = []; 
    private stable var _goldState : [(AccountIdentifier, Nat32)] = [];
    // Dynamic
    private var _saveData : HashMap.HashMap<TokenIndex, Text> = HashMap.fromIter(_saveDataState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _sessions : HashMap.HashMap<TokenIndex, SessionData> = HashMap.fromIter(_sessionsState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _equippedItems : HashMap.HashMap<TokenIndex, [Nat16]> = HashMap.fromIter(_equippedItemsState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _ownedNonNftItems : HashMap.HashMap<TokenIndex, [Nat16]> = HashMap.fromIter(_ownedNonNftItemsState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _completedEvents : HashMap.HashMap<TokenIndex, [Nat16]> = HashMap.fromIter(_completedEventsState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _playerData : HashMap.HashMap<TokenIndex, PlayerData> = HashMap.fromIter(_playerDataState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _gold : HashMap.HashMap<AccountIdentifier, Nat32> = HashMap.fromIter(_goldState.vals(), 0, AID.equal, AID.hash);
    // ********* NOW ********* //
    // TODO map all items to item metadata for minting
    // TODO map all monsters to experience, level, gold, etc
    // TODO map all chests to (json id, opened, item) for loading and deciding what to mint when opening
    // TODO map all markets to items in market
    // TODO in game await calls that deliver data in game;

    // ********* LATER ********* //
    // TODO track player position and time updated. keep a map of transition times for moving from one area to another 
    // TODO create sections in game (based on position) mapped to everything available in the area (and which areas you can transition to)
    // TODO track player story progress map (with prerequisites)
    // TODO map all story points to their index in story progress, with list of prerequisites and optional map position
    // TODO for each treasure chest, market, boss have a list of prerequisite story points that must be toggled ^^
    // TODO in game asynchronously call checkins and updates to story progress as needed

    private var _characterRegistry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_characterRegistryState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _itemRegistry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_itemRegistryState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _itemMetadata : HashMap.HashMap<TokenIndex, Metadata> = HashMap.fromIter(_itemMetadataState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);

    // system functions
    system func preupgrade() {
        _saveDataState := Iter.toArray(_saveData.entries());
        _sessionsState := Iter.toArray(_sessions.entries());
        _characterRegistryState := Iter.toArray(_characterRegistry.entries());
        _itemRegistryState := Iter.toArray(_itemRegistry.entries());
        _itemMetadataState := Iter.toArray(_itemMetadata.entries());
        _equippedItemsState := Iter.toArray(_equippedItems.entries());
        _ownedNonNftItemsState := Iter.toArray(_ownedNonNftItems.entries());
        _completedEventsState := Iter.toArray(_completedEvents.entries());
        _playerDataState := Iter.toArray(_playerData.entries());
        _goldState := Iter.toArray(_gold.entries());
    };

    system func postupgrade() {
        _saveDataState := [];
        _sessionsState := [];
        _characterRegistryState := [];
        _itemRegistryState := [];
        _itemMetadataState := [];
        _equippedItemsState := [];
        _ownedNonNftItemsState := [];
        _completedEventsState := [];
        _playerDataState := [];
        _goldState := [];
    };

    system func heartbeat() : async () {
        if(_runHeartbeat and Time.now() >= _lastRegistryUpdate + REGISTRY_CHECK) {
            // every ten minutes, pull the latest character and item registry
            _lastRegistryUpdate := Time.now();
            try {
                await getCharacterRegistry();
                await getItemRegistry();
                await getItemMetadata();
            } catch(e) {
                _runHeartbeat := false;
            };
        };
        if(_runHeartbeat == true and Time.now() >= _lastCleared + SESSION_CHECK) {
            // every hour check all the sessions and delete old ones
            _lastCleared := Time.now();
            try{
                cleanSessions();
            } catch(e){
                _runHeartbeat := false;
            };
        };
    };

    // -----------------------------------
    // user interaction with this canister
    // -----------------------------------

    // check if user owns character NFT and create session for fast lookup. return owned NFT data
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
    public shared({ caller }) func loadGame(characterIndex : TokenIndex) : async(X.ApiResponse<Text>) {
        switch(checkSession(caller, characterIndex)) {
            case(#Err e) {
               return #Err e;
            };
            case(_) {};
        };
        // check if they have a saved game
        return _load(characterIndex, AID.fromPrincipal(caller, null));
    };

    // save game data formatted in json so that unity can load correctly
    public shared({ caller }) func saveGame(characterIndex: TokenIndex, gameData : Text) : async(X.ApiResponse<Text>) {
        switch(checkSession(caller, characterIndex)) {
            case(#Err e) {
               return #Err e;
            };
            case(_) {};
        };
        // save boring data (everything but items and player stats)
        _saveData.put(characterIndex, gameData);
        return _load(characterIndex, AID.fromPrincipal(caller, null));
    };

    // called when opening a treasure chest or receiving 
    public shared({ caller }) func openChest(characterIndex : TokenIndex, chestIndex : Nat16) : async(X.ApiResponse<RewardInfo>) {
        switch(checkSession(caller, characterIndex)) {
            case(#Err e) {
               return #Err e;
            };
            case(#Ok session) {
                let address : AccountIdentifier = AID.fromPrincipal(caller, null);
                let optChest : ?Ref.TreasureChest = Array.find(Ref.chests, func (chest : Ref.TreasureChest) : Bool {
                    return chest.id == chestIndex;
                });
                switch(optChest) {
                    case (?chest) {
                        var rewardInfo : RewardInfo = {itemIds = []; gold = 0; xp = 0;};
                        if (chest.gold > 0) {
                            ignore(_giveGold(chest.gold, caller, true));
                        };
                        let itemResult : RewardInfo = await _mintRewardItems(chest.itemReward, caller);
                        rewardInfo := {
                            itemIds = itemResult.itemIds;
                            gold = rewardInfo.gold;
                            xp = 0;
                        };
                        // return the collected return vals in RewardInfo
                        ignore(updateSession(characterIndex, session, 0, rewardInfo.gold, Nat8.fromNat(rewardInfo.itemIds.size())));
                        #Ok(rewardInfo);
                    };
                    case _ return #Err(#Other("Server Error: Chest Definition Missing"));
                };
            };
        };
    };

    public shared({ caller }) func buyItem(characterIndex: TokenIndex, shopIndex : Nat16, itemIndex : Nat16) : async(X.ApiResponse<[Nat8]>) {
        switch(checkSession(caller, characterIndex)) {
            case(#Err e) {
               return #Err e;
            };
            case(#Ok session) {
                // check that the item exists in a valid shop inventory
                let shopContainer : ?Ref.Market = Array.find(Ref.markets, func (market : Ref.Market) : Bool {
                    return market.id == shopIndex;
                });
                var goldCost : Nat32 = 0;
                switch (shopContainer) {
                    case(?shop) {
                        let containedItem : ?Ref.ItemListing= Array.find(shop.items, func (item : Ref.ItemListing) : Bool {
                            goldCost := item.cost;
                            return item.id == itemIndex;
                        });
                        if (containedItem == null) {
                            return #Err(#Other "item does not exist for shop");
                        };
                    };
                    case _ return #Err(#Other "error retrieving shop data");
                };
                // check that player has enough gold
                let address : AccountIdentifier = AID.fromPrincipal(caller, null);
                let optCurrGold : ?Nat32 = _gold.get(address);
                switch(optCurrGold) {
                    case(?currGold) {
                        ignore(_giveGold(goldCost, caller, false));
                    };
                    case _ return #Err(#Other "not enough gold to purchase item");
                };
                // update player session (counts as receiving an item)
                ignore(updateSession(characterIndex, session, 0, 0, 1));
                return await mintItem(itemIndex, address);
            };
        };
    };

    public shared({ caller }) func equipItems(characterIndex : TokenIndex, itemIndices : [Nat16]) : async(X.ApiResponse<()>) {
        switch(checkSession(caller, characterIndex)) {
            case(#Err e) {
               return #Err e;
            };
            case(_) {};
        };
        // make sure that caller owns all items;
        let address : AccountIdentifier = AID.fromPrincipal(caller, null);
        // get player owned game items 
        let gameItems = getOwnedItems(characterIndex, address);
        // get player equipped game items
        let optEquippedItems : ?[Nat16] = _equippedItems.get(characterIndex);
        switch(optEquippedItems) {
            case(?equippedItems) {
                for (itemIndex in itemIndices.vals()) {
                    // get item details
                    let optItem : ?Ref.Item = Array.find(Ref.items, func (item : Ref.Item) : Bool {
                        return item.id == itemIndex;
                    });
                    switch(optItem) {
                        case (?itemToEquip) {
                            // make sure item isn't already equipped
                            let equippedMatchingItems : [Ref.Item] = Array.filter(equippedItems, func (eItem : Ref.Item) : Bool {
                                eItem.id == itemToEquip.id;
                            });
                            if (equippedMatchingItems.size() > 0) {
                                return #Err(#Other("Cannot equip more than one of the same item"));
                            }
                            // make sure they own unequipped item
                            let unequippedMatchingItem : [Ref.Item] = Array.filter(gameItems, func (item : Ref.Item) : Bool {
                                item.metadata == item.metadata;
                            });
                            if (unequippedMatchingItem.size() == 0) {
                                return #Err(#Other("Cannot equip item not owned by user"));
                            }
                        };
                        case _ return #Err(#Other("Server Error: Item Definition Missing"));
                    };
                };
                // equip items
                _equippedItems.put(characterIndex, _appendAll(equippedItems, itemIndices));
                #Ok;
            };
            case _ {
                _equippedItems.put(characterIndex, itemIndices);
                #Ok;
            };
        };
    };

    // when you defeat a monster.... can win gold, xp, and items
    public shared({ caller }) func defeatMonster(characterIndex : TokenIndex, monsterIndex : Nat16) : async(X.ApiResponse<RewardInfo>) {
        switch(checkSession(caller, characterIndex)) {
            case(#Err e) {
               return #Err e;
            };
            case(#Ok session) {
                // look up monster by index
                let optMonster : ?Ref.Monster = Array.find(Ref.monsters, func (monster : Ref.Monster) : Bool {
                    return monster.id == monsterIndex;
                });
                // add monster rewards to character and session
                switch(optMonster) {
                    case(?monster) {
                        let itemRewards : RewardInfo = await _mintRewardItems(monster.itemReward, caller);
                        // give player gold
                        switch(_playerData.get(characterIndex)) {
                            case(?playerData) {
                                let itemInfo : RewardInfo = await _mintRewardItemsProb(monster.itemReward, caller, monster.itemProb);
                                let rewardInfo : RewardInfo = {
                                    gold = _giveGold(monster.gold, caller, true);
                                    xp = monster.xp;
                                    itemIds = itemInfo.itemIds;
                                };
                                ignore(updateSession(characterIndex, session, rewardInfo.xp, rewardInfo.gold, Nat8.fromNat(rewardInfo.itemIds.size())));
                                #Ok rewardInfo;
                            };
                            case(_) {
                                #Err(#Other("Server Error. Failed to find player data."));
                            };
                        };
                    };
                    case _ {
                        #Err(#Other("Server Error. Failed to find monster data."));
                    };
                };
            };
        };
    };

    public shared(msg) func checkIn() : async() {};

    // -----------------------------------
    // http
    // -----------------------------------
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
    // update session when you earn gold, xp, or items
    func updateSession(characterIndex: TokenIndex, session : SessionData, xp : Nat32, gold : Nat32, items : Nat8) : X.ApiResponse<()> {
        _sessions.put(characterIndex, {
            createdAt=session.createdAt;
            goldEarned=session.goldEarned + gold;
            xpEarned = session.xpEarned + xp;
            itemsEarned = session.itemsEarned + items;
        });
        #Ok();
    };
    func getOwnedItems(characterIndex : TokenIndex, accountIdentifier : AccountIdentifier) : [Ref.Item] {
        // filter all item nfts owned by character
        let ownedItems : [TokenIndex] = Iter.toArray(HashMap.mapFilter<TokenIndex, AccountIdentifier, AccountIdentifier>(
            _itemRegistry.entries(), 
            ExtCore.TokenIndex.equal, 
            ExtCore.TokenIndex.hash, 
            func (index : TokenIndex, account : AccountIdentifier) : ?AccountIdentifier {
                if (account == accountIdentifier) {
                    return index;
                };
            }).keys());
        // make sure metadata that identifies what the item is (see item nft canister) 
        let ownedItemsMeta : [Metadata] = Array.map<TokenIndex, Metadata>(ownedItems, func (tokenIndex : TokenIndex) : Metadata {
            let optMetadata : ?Metadata =  _itemMetadata.get(tokenIndex);
            switch(opMetadata) {
                case (?metadata) metadata;
                case _ [];
            };
        });
        // matches corresponding metadata in item list
        let gameItems : [Ref.Item] = Array.mapFilter<Metadata, Ref.Item>(ownedItemsMeta, func (metadata : Metadata) : ?Ref.Item {
            Array.find(Ref.items, func (i : Ref.Item) : ?Ref.Item {i.metadata == metadata;});
        });
        gameItems;
    };
    // load game data formatted in json so that unity can load correctly
    func _load(characterIndex : TokenIndex, accountIdentifier : AccountIdentifier) : X.ApiResponse<Text> {
        switch(_saveData.get(characterIndex)) {
            case(?save) {
                // piece together the inventory and player stats
                // "{\\"items\\":[],\\"equippedItems\\":[\\"2069047119\\"],\\"currency\\":10}"
                var itemsString = "\\\\\"items\\\\\":[";
                var equippedItemsString = "\\\\\"equippedItems\\\\\":[";
                var goldString = "\\\\\"currency\\\\\":";
                // get user gold
                let optCurrency : ?Nat32 = _gold.get(accountIdentifier);
                switch(optCurrency) {
                    case(?currency) {
                        goldString #= currency;
                    };
                    case _ goldString #= 0;
                };
                // get the unityId for owned items
                let ownedItems : [Text] = getOwnedItems(characterIndex, acc);
                switch(_equippedItems.get(characterIndex)) {
                    case (?items) {
                        // add all equipped items to equipped items string. everything else to items string
                        // loop through items and get equipped item strings
                        let unityIds : Text = Array.foldLeft(items, "", func (prev : Text, itemId : Nat16) : Text {
                            var returnText = "";
                            let itemContainer : ?Ref.Item = Array.find(Ref.items, func (item : Ref.Item) : Bool {
                                return item.id == itemId;
                            });
                            switch(itemContainer) {
                                case(?item) {
                            if (prev != "") {
                                returnText #= ",";
                            };
                            returnText #= "\\\\\"" # item.unityId # "\\\\\"";
                                    
                                };
                                case _ {};
                            };
                            prev # returnText;
                        });
                        equippedItemsString #= unityIds;

                        // add the rest to items string
                        let unequippedOwnedItems : [Text] = Array.filter(ownedItems, func (item : Ref.Item) : Bool {
                            Array.find(equippedItems, func (id : Nat16) : Bool {
                                id == item.id;
                            }) == null;
                        });
                        let unequippedUnityIds : Text = Array.foldLeft(unequippedOwnedItems, "", func (prev : Text, item : Ref.Item) : Text {
                            var returnText = "";
                            if (prev != "") {
                                returnText #= ",";
                            };
                            returnText #= "\\\\\"" # item.unityId # "\\\\\"";
                            prev # returnText;
                        });
                        itemsString #= unequippedUnityIds;

                    };
                    case (_) {
                        // don't add anything to equipped items string. add everything to items string
                        let unityIds : Text = Array.foldLeft(ownedItems, "", func (prev : Text, item : Ref.Item) : Text {
                            var returnText = "";
                            if (prev != "") {
                                returnText #= ",";
                            };
                            returnText #= "\\\\\"" # item.unityId # "\\\\\"";
                            return prev # returnText;
                        });
                        itemsString #= unityIds;
                    };
                };
                equippedItemsString #= "]";
                itemsString #= "]";

                let invCurrData  : Text = "\"{" # itemsString # "," # equippedItemsString # "," # goldString # "}\"";
                let invCurrSplit  : Iter.Iter<Text> = Text.split(save, #text("playerInvCurrData"));
                let invCurrStitch  : Text = Text.join(invCurrData, invCurrSplit);

                // add stats
                // "{
                //   \"characterName\":\"Phendrin\",\"characterClass\":\"\",\"level\":1,\"xp\":0,\"xpToLevelUp\":75,
                //   \"pointsRemaining\":0,\"healthBase\":15,\"healthTotal\":15,\"healthMax\":15,\"magicBase\":10,\"magicTotal\":10,
                //   \"magicMax\":10,\"attackBase\":5,\"attackTotal\":5,\"magicPowerBase\":0,\"magicPowerTotal\":0,\"defenseBase\":5,
                //   \"defenseTotal\":5,\"speedBase\":5,\"speedTotal\":5,\"criticalHitProbability\":0.0,\"characterEffects\":[]
                // }"
                var statsString = "\"{";
                let optPlayerData : ?PlayerData = _playerData.get(characterIndex);
                switch(optPlayerData) {
                    case(?playerData) {
                        statsString #= "\\\\\"characterName\\\\\":\\\\\"" # playerData.characterName # "\\\\\",";
                        statsString #= "\\\\\"characterClass\\\\\":\\\\\"" # playerData.characterClass # "\\\\\",";
                        statsString #= "\\\\\"level\\\\\":" # playerData.level # ",";
                        statsString #= "\\\\\"xp\\\\\":" # playerData.xp # ",";
                        statsString #= "\\\\\"xpToLevelUp\\\\\":" # playerData.xpToLevelUp # ",";
                        statsString #= "\\\\\"pointsRemaining\\\\\":" # playerData.pointsRemaining # ",";
                        statsString #= "\\\\\"healthBase\\\\\":" # playerData.healthBase # ",";
                        statsString #= "\\\\\"healthTotal\\\\\":" # playerData.healthTotal # ",";
                        statsString #= "\\\\\"healthMax\\\\\":" # playerData.healthMax # ",";
                        statsString #= "\\\\\"magicBase\\\\\":" # playerData.magicBase # ",";
                        statsString #= "\\\\\"magicTotal\\\\\":" # playerData.magicTotal # ",";
                        statsString #= "\\\\\"magicMax\\\\\":" # playerData.magicMax # ",";
                        statsString #= "\\\\\"attackBase\\\\\":" # playerData.attackBase # ",";
                        statsString #= "\\\\\"attackTotal\\\\\":" # playerData.attackTotal # ",";
                        statsString #= "\\\\\"defenseBase\\\\\":" # playerData.defenseBase # ",";
                        statsString #= "\\\\\"defenseTotal\\\\\":" # playerData.defenseTotal # ",";
                        statsString #= "\\\\\"speedBase\\\\\":" # playerData.speedBase # ",";
                        statsString #= "\\\\\"speedTotal\\\\\":" # playerData.speedTotal # ",";
                        statsString #= "\\\\\"criticalHitProbability\\\\\":" # playerData.criticalHitProbability # ",";
                        statsString #= "\\\\\"characterEffects\\\\\":[]";
                        // TODO: format character effects into json string
                    };
                    case _ {
                        statsString #= "\\\\\"characterName\\\\\":\\\\\"Phendrin\\\\\",";
                        statsString #= "\\\\\"characterClass\\\\\":\\\\\"\\\\\",";
                        statsString #= "\\\\\"level\\\\\":1,";
                        statsString #= "\\\\\"xp\\\\\":0,";
                        statsString #= "\\\\\"xpToLevelUp\\\\\":75,";
                        statsString #= "\\\\\"pointsRemaining\\\\\":0,";
                        statsString #= "\\\\\"healthBase\\\\\":15,";
                        statsString #= "\\\\\"healthTotal\\\\\":15,";
                        statsString #= "\\\\\"healthMax\\\\\":0,";
                        statsString #= "\\\\\"magicBase\\\\\":0,";
                        statsString #= "\\\\\"magicTotal\\\\\":0,";
                        statsString #= "\\\\\"magicMax\\\\\":0,";
                        statsString #= "\\\\\"attackBase\\\\\":0,";
                        statsString #= "\\\\\"attackTotal\\\\\":0,";
                        statsString #= "\\\\\"defenseBase\\\\\":0,";
                        statsString #= "\\\\\"defenseTotal\\\\\":0,";
                        statsString #= "\\\\\"speedBase\\\\\":0,";
                        statsString #= "\\\\\"speedTotal\\\\\":0,";
                        statsString #= "\\\\\"criticalHitProbability\\\\\":0.0,";
                        statsString #= "\\\\\"characterEffects\\\\\":[]";
                    };
                };
                let statsData  : Text = "\"{" # statsString # "}\"";
                let statsSplit  : Iter.Iter<Text> = Text.split(invCurrStitch, #text("charStatsData"));
                let statsStitch  : Text = Text.join(statsData, statsSplit);

                return #Ok statsStitch;
            };
            case(_) {
                return #Err(#Other("No save data"));
            };
        };
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


    func checkSession(caller : Principal, tokenIndex : TokenIndex) : X.ApiResponse<SessionData> {
        // convert principal into wallet
        let address : AccountIdentifier = AID.fromPrincipal(caller, null);
        // make sure the principal owns this tokenIndex
        switch(_characterRegistry.get(tokenIndex)) {
            case(?owner) {
                if (owner != address) {
                    return #Err(#Unauthorized);
                };
            };
            case(_) {};
        };

        // make sure player hasn't exceeded limits for the day
        switch(_sessions.get(tokenIndex)) {
            // if their session has been reset, replace it
            case(?session) {
                if (session.goldEarned >= MAX_GOLD or session.itemsEarned >= MAX_ITEMS or session.xpEarned >= MAX_XP){
                    return #Err(#Limit);
                } else {
                    return #Ok session;
                }
            };
            case(_) {
                let newSession : SessionData = {
                    createdAt = Time.now(); 
                    goldEarned = 0; 
                    xpEarned = 0; 
                    itemsEarned = 0; 
                };
                _sessions.put(tokenIndex, newSession);
                #Ok newSession;
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

      func _appendAll<T>(array : [T], val: [T]) : [T] {
    if (val.size() == 0) {
      return array;
    };
    let new = Array.tabulate<T>(array.size() + val.size(), func(i) {
        if (i < array.size()) {
            array[i];
        } else {
            val[i - array.size()];
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

    func _mintRewardItemsProb(itemReward : Ref.ItemReward, caller : Principal, itemProb : Nat8) : async RewardInfo {
        // check probability and mint items
        let randomNumber : ?Nat = Random.Finite(Principal.toBlob(caller)).range(8);
        ignore(do ? {
            if (randomNumber! % 100 <= Nat8.toNat(itemProb)) {
                await _mintRewardItems(itemReward, caller);
            } else {
                {
                    xp = 0;
                    gold = 0;
                    itemIds = [];
                };
            };
        });
        {
            xp = 0;
            gold = 0;
            itemIds = [];
        };
    };

    func _mintRewardItems(itemReward : Ref.ItemReward, caller : Principal) : async RewardInfo {
        let address : AccountIdentifier = AID.fromPrincipal(caller, null);
        var defaultReward : RewardInfo = {
            xp = 0;
            gold = 0;
            itemIds = [];
        };
        switch (itemReward) {
            case (#SpecificItem itemContainer) {
                // give user specific items
                for (itemIndex in itemContainer.items.vals()) {
                    // get item metadata
                    let optItem : ?Ref.Item = Array.find(Ref.items, func (item : Ref.Item) : Bool {
                        return item.id == itemIndex;
                    });
                    switch(optItem) {
                        case(?item) {
                            ignore(await _mintItem(item.metadata, address));
                            defaultReward := {
                                itemIds= _append(defaultReward.itemIds, item.id);
                                gold= 0;
                                xp = 0;
                            };
                        };
                        case _ {};
                    };
                };
                defaultReward;
            };
            case (#RandomItem itemContainer) {
                // choose random item from tier;
                let randomNumber : ?Nat = Random.Finite(Principal.toBlob(caller)).range(16);
                ignore(do ? {
                    // get items within a tier
                    let filteredItems : [Ref.Item] = Array.filter<Ref.Item>(Ref.items, func (item : Ref.Item) : Bool {
                        return item.tier == itemContainer.tier;
                    });
                    // choose a random item from the list
                    let item : Ref.Item = filteredItems[randomNumber! % filteredItems.size()];
                    // give item to user
                    ignore(await _mintItem(item.metadata, address));
                    defaultReward := {
                        itemIds= _append(defaultReward.itemIds, item.id);
                        gold= 0;
                        xp = 0;
                    };
                });
                defaultReward;

            };
            case _ defaultReward;
        };
    };

    func _giveGold(gold: Nat32, caller : Principal, positive : Bool) : Nat32 {
        let address : AccountIdentifier = AID.fromPrincipal(caller, null);
        // give user gold
        let optCurrGold : ?Nat32 = _gold.get(address);
        switch (optCurrGold) {
            case (?currGold) {
                if (positive) {
                    _gold.put(address, currGold + gold);
                } else {
                    if (gold >= currGold) {
                        _gold.put(address, 0);
                    } else {
                        _gold.put(address, currGold - gold);
                    };
                };
            };
            case _ {
                _gold.put(address, gold);
            };
        };
        gold;
    };

    // -----------------------------------
    // interaction with other canisters
    // -----------------------------------
    // character nft canister will need to call this when transfering a token and initiate transfers in item canister
    public shared(msg) func getEquippedItems(characterIndex : TokenIndex, accountIdentifier : AccountIdentifier) : async [TokenIndex] {
        switch(_equippedItems.get(characterIndex)) {
            case(?equippedItems) {
                // get the item nft token indices for all equipped items
                let optEquippedItems : ?[Ref.Item] = _equippedItems.get(characterIndex);
                switch(optEquippedItems) {
                    case(?equippedItems) {
                        let optOwnedItems : [TokenIndex] = Iter.toArray(HashMap.mapFilter<TokenIndex, AccountIdentifier, AccountIdentifier>(
                            _itemRegistry.entries(), 
                            ExtCore.TokenIndex.equal, 
                            ExtCore.TokenIndex.hash, 
                            func (index : TokenIndex, account : AccountIdentifier) : ?AccountIdentifier {
                                if (account == accountIdentifier) {
                                    return index;
                                };
                            }).keys());
                        switch(optOwnedItems) {
                            case(?ownedItems) {
                                // make sure metadata that identifies what the item is (see item nft canister) 
                                let ownedItemsMeta : [{index: TokenIndex; data: Metadata;}] = Array.map<TokenIndex, {index: TokenIndex; data: Metadata;}>(
                                    ownedItems, 
                                    func (tokenIndex : TokenIndex) : {index: TokenIndex; data: Metadata;} {
                                        let optMetadata : ?Metadata =  _itemMetadata.get(tokenIndex);
                                        switch(opMetadata) {
                                            case (?metadata) {index = tokenIndex; data = metadata;};
                                            case _ {index = 0; data = [];};
                                        };
                                    });
                                let equippedIndices : [TokenIndex] = Array.mapFilter<{index: TokenIndex; data: Metadata}, TokenIndex>(
                                    ownedItemsMeta,
                                    func (map : {index: TokenIndex; data: Metadata;}) : ?TokenIndex {
                                        let optFoundItem : ?Ref.Item = Array.find(equippedItems, func (item : Ref.Item) : Bool {
                                            item.metadata == map.data;
                                        };
                                        switch(optFoundItem) {
                                            case(?foundItem) map.index;
                                            case _ {};
                                        };
                                    }
                                );
                                equippedIndices;
                            };
                            case _ [];
                        };
                    };
                    case _ [];
                }
            };
            case _ [];
        };
    };

    func mintItem(itemId : Nat16, recipient : AccountIdentifier) : async X.ApiResponse<[Nat8]> {
        // get item metadata
        let itemContainer : ?Ref.Item = Array.find(Ref.items, func (item : Ref.Item) : Bool {
            return itemId == item.id;
        });
        switch(itemContainer) {
            case(?item) {
                return await _mintItem(item.metadata, recipient);
            };
            case _ #Err(#Other "Unable to retrieve item data");
        };
    };

    func _mintItem(metadata: [Nat8], recipient : AccountIdentifier) : async X.ApiResponse<[Nat8]> {
        try {
            let result = await _itemActor.mintItem({data= metadata; recipient = recipient;});
            return #Ok(metadata);
        } catch(e) {
            return #Err(#Other("Unable to communicate with item canister"));
        };
    };

    func getItemRegistry() : async () {
        let result = await _itemActor.getRegistry();
        _itemRegistry := HashMap.fromIter(result.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    };

    func getItemMetadata() : async () {
        let result = await _itemActor.getMetadata();
        _itemMetadata := HashMap.fromIter(result.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
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