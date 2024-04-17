import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Cycles "mo:base/ExperimentalCycles";
import Nat "mo:base/Nat";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Random "mo:base/Random";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Canistergeek "mo:canistergeek/canistergeek";
import Map "mo:map/Map";

import Env "env";
import EC "lib/ext/Common";
import ER "lib/ext/Core";
import { TokenIndex } "lib/ext/Core";
import AID "lib/util/AccountIdentifier";
import M "middleware";
import Ref "reference";
import T "types";

actor class _ObsidianTearsBackend() = this {
  // Types
  type AccountIdentifier = ER.AccountIdentifier;
  type TokenIndex = ER.TokenIndex;
  type CommonError = ER.CommonError;
  type Metadata = EC.Metadata;

  stable var lastRegistryUpdate : Time.Time = Time.now(); // keep track of the last time registries were updated

  // Env
  let itemCanisterEnv : Text = Env.getItemCanisterId();
  let characterCanisterEnv : Text = Env.getCharacterCanisterId();

  // Actors
  var characterActor : T.CharacterInterface = actor (characterCanisterEnv);
  var itemActor : T.ItemInterface = actor (itemCanisterEnv);

  let tokenHash : Map.HashUtils<TokenIndex> = (TokenIndex.hash, TokenIndex.equal);
  let accountHash : Map.HashUtils<AccountIdentifier> = (AID.hash, AID.equal);

  // State
  stable var authTokenRegistry : Map.Map<Text, T.TokenWithTimestamp> = Map.new<Text, T.TokenWithTimestamp>();
  stable var saveData : Map.Map<TokenIndex, Text> = Map.new<TokenIndex, Text>();
  stable var ownedNonNftItems : Map.Map<TokenIndex, [Nat16]> = Map.new<TokenIndex, [Nat16]>();
  stable var goldMap : Map.Map<AccountIdentifier, Nat32> = Map.new<AccountIdentifier, Nat32>();
  stable var characterRegistry : Map.Map<TokenIndex, AccountIdentifier> = Map.new<TokenIndex, AccountIdentifier>();
  stable var itemRegistry : Map.Map<TokenIndex, AccountIdentifier> = Map.new<TokenIndex, AccountIdentifier>();
  stable var itemMetadata : Map.Map<TokenIndex, Metadata> = Map.new<TokenIndex, Metadata>();

  // ********* NOW ********* //
  // TODO create new game function that sets player data at default
  // TODO create level up function that increases player level and stats

  // ********* LATER ********* //
  // TODO track player position with timestamps. based on event positions (eg. opening chests) determine whether player could have traveled that far
  // TODO keep track of story progress for player (list of events in story that have been completed)
  // TODO for each relevent event (eg. opening a chest at the end of a sidequest) have a list of story events that must be completed to open chest.
  // TODO keep track of opened chests for each character

  // system functions
  system func preupgrade() {
    // canistergeek
    canistergeekMonitorUD := ?canistergeekMonitor.preupgrade();
    canistergeekLoggerUD := ?canistergeekLogger.preupgrade();
  };

  system func postupgrade() {
    // canistergeek
    canistergeekMonitor.postupgrade(canistergeekMonitorUD);
    canistergeekMonitorUD := null;
    canistergeekLogger.postupgrade(canistergeekLoggerUD);
    canistergeekLoggerUD := null;
    canistergeekLogger.setMaxMessagesCount(3000);
    canistergeekLogger.logMessage("postupgrade");
  };

  // -----------------------------------
  // user interaction with this canister
  // -----------------------------------

  // TODO: remove once frontend is updated
  // check if user owns character NFT. return owned NFT data
  public shared ({ caller }) func verify() : async (T.ApiResponse<[TokenIndex]>) {
    canistergeekMonitor.collectMetrics();
    let address : AccountIdentifier = AID.fromPrincipal(caller, null);

    // get and update character cache registry
    let resultCharacter : Result.Result<[TokenIndex], CommonError> = await characterActor.tokens(address);
    let characterIndices = switch (resultCharacter) {
      case (#ok(characterIndices)) characterIndices;
      case (#err(_e)) return #Err(#Other("Error verifying user"));
    };
    for (index in characterIndices.vals()) {
      Map.set(characterRegistry, tokenHash, index, address);
    };

    // get and update item cache registry
    let resultItem : Result.Result<[TokenIndex], CommonError> = await itemActor.tokens(address);
    let itemIndeces = switch (resultItem) {
      case (#ok(itemIndeces)) itemIndeces;
      case (#err(_e))[];
    };
    for (index in itemIndeces.vals()) {
      Map.set(itemRegistry, tokenHash, index, address);
    };

    // return characterIndices
    return #Ok(characterIndices);
  };

  public shared ({ caller }) func getAuthToken(characterIndex : TokenIndex) : async Result.Result<Text, Text> {
    canistergeekMonitor.collectMetrics();
    let address : AccountIdentifier = AID.fromPrincipal(caller, null);

    // check ownership of hero NFT and update character cache registry
    let resultCharacter : Result.Result<[TokenIndex], CommonError> = await characterActor.tokens(address);
    let characterIndices = switch (resultCharacter) {
      case (#ok(characterIndices)) characterIndices;
      case (#err(_e)) return #err("Error verifying user");
    };
    var found = false;
    for (index in characterIndices.vals()) {
      Map.set(characterRegistry, tokenHash, index, address);
      if (characterIndex == index) found := true;
    };
    if (not found) return #err("Caller is not owner of NFT " # debug_show characterIndex);

    // // get and update item cache registry
    // let resultItem : Result.Result<[TokenIndex], CommonError> = await itemActor.tokens(address);
    // let itemIndeces = switch (resultItem) {
    //   case (#ok(itemIndeces)) itemIndeces;
    //   case (#err(_e)) [];
    // };
    // for (index in itemIndeces.vals()) {
    //   itemRegistry.put(index, address);
    // };

    // generate new authtoken
    let newAuthToken : Text = await M.generateAuthToken();
    let tokenWithTimestamp : T.TokenWithTimestamp = (characterIndex, Time.now());
    Map.set<Text, T.TokenWithTimestamp>(authTokenRegistry, Map.thash, newAuthToken, tokenWithTimestamp);

    return #ok(newAuthToken);
  };

  // load game data formatted in json so that unity can load correctly
  public shared func loadGame(characterIndex : TokenIndex, authToken : Text) : async (T.ApiResponse<Text>) {
    if (not M.hasValidToken(characterIndex, authToken, authTokenRegistry)) return #Err(#Unauthorized);

    switch (Map.get(saveData, tokenHash, characterIndex)) {
      case (?save) return #Ok(save);
      case (null) return #Err(#Other("No save data"));
    };
  };

  // save game data formatted in json so that unity can load correctly
  public shared func saveGame(characterIndex : TokenIndex, gameData : Text, authToken : Text) : async (T.ApiResponse<Text>) {
    if (not M.hasValidToken(characterIndex, authToken, authTokenRegistry)) return #Err(#Unauthorized);

    Map.set(saveData, tokenHash, characterIndex, gameData);
    return #Ok(gameData);
  };

  // called when opening a treasure chest or receiving
  public shared ({ caller }) func openChest(characterIndex : TokenIndex, chestIndex : Nat16, authToken : Text) : async (T.ApiResponse<T.RewardInfo>) {
    if (not M.hasValidToken(characterIndex, authToken, authTokenRegistry)) return #Err(#Unauthorized);

    let optChest : ?Ref.TreasureChest = Array.find(
      Ref.chests,
      func(chest : Ref.TreasureChest) : Bool {
        return chest.id == chestIndex;
      },
    );
    switch (optChest) {
      case (?chest) {
        var rewardInfo : T.RewardInfo = {
          itemIds = [];
          gold = 0;
          xp = 0;
        };
        if (chest.gold > 0) {
          rewardInfo := {
            itemIds = rewardInfo.itemIds;
            gold = giveGold(chest.gold, caller, true);
            xp = rewardInfo.xp;
          };
        };
        let itemResult : T.RewardInfo = await mintRewardItems(chest.itemReward, caller, characterIndex);
        rewardInfo := {
          itemIds = itemResult.itemIds;
          gold = rewardInfo.gold;
          xp = 0;
        };
        // return the collected return vals in RewardInfo
        #Ok(rewardInfo);
      };
      case _ return #Err(#Other("Server Error: Chest Definition Missing"));
    };
  };

  // when you defeat a monster.... can win gold, xp, and items
  public shared ({ caller }) func defeatMonster(characterIndex : TokenIndex, monsterIndex : Nat16, authToken : Text) : async (T.ApiResponse<T.RewardInfo>) {
    if (not M.hasValidToken(characterIndex, authToken, authTokenRegistry)) return #Err(#Unauthorized);

    // look up monster by index
    let optMonster : ?Ref.Monster = Array.find(
      Ref.monsters,
      func(monster : Ref.Monster) : Bool {
        return monster.id == monsterIndex;
      },
    );
    // add monster rewards to character
    switch (optMonster) {
      case (?monster) {
        // give player gold
        let itemInfo : T.RewardInfo = await mintRewardItemsProb(monster.itemReward, caller, monster.itemProb, characterIndex);
        let rewardInfo : T.RewardInfo = {
          gold = giveGold(monster.gold, caller, true);
          xp = monster.xp;
          itemIds = itemInfo.itemIds;
        };
        #Ok rewardInfo;
      };
      case (_) {
        #Err(#Other("Server Error. Failed to find monster data."));
      };
    };
  };

  // -----------------------------------
  // http
  // -----------------------------------
  public query func http_request(_request : T.HttpRequest) : async T.HttpResponse {
    let name = "Obsidian Tears RPG";
    return {
      status_code = 200;
      headers = [("content-type", "text/plain")];
      body = Text.encodeUtf8(
        name # "\n" # "---\n" # "Cycle Balance:                            ~" # debug_show (Cycles.balance() / 1000000000000) # "T\n" # "Saved Games:                              " # debug_show (saveData.size()) # "\n" # "---\n" # "Admins:                                    " # debug_show (Env.getAdminPrincipals()) # "\n"
      );
      streaming_strategy = null;
    };
  };

  // -----------------------------------
  // helper functions
  // -----------------------------------

  func append<T>(array : [T], val : T) : [T] {
    let new = Array.tabulate<T>(
      array.size() +1,
      func(i) {
        if (i < array.size()) {
          array[i];
        } else {
          val;
        };
      },
    );
    new;
  };

  func mintRewardItemsProb(itemReward : Ref.ItemReward, caller : Principal, itemProb : Nat8, characterIndex : TokenIndex) : async T.RewardInfo {
    // check probability and mint items
    let optRandomNumber : ?Nat = Random.Finite(Principal.toBlob(caller)).range(8);
    switch (optRandomNumber) {
      case (?randomNumber) {
        if (randomNumber % 100 <= Nat8.toNat(itemProb)) {
          await mintRewardItems(itemReward, caller, characterIndex);
        } else {
          {
            xp = 0;
            gold = 0;
            itemIds = [];
          };
        };
      };
      case _ {
        {
          xp = 0;
          gold = 0;
          itemIds = [];
        };
      };
    };
  };

  func mintRewardItems(itemReward : Ref.ItemReward, caller : Principal, characterIndex : TokenIndex) : async T.RewardInfo {
    let address : AccountIdentifier = AID.fromPrincipal(caller, null);
    var defaultReward : T.RewardInfo = {
      xp = 0;
      gold = 0;
      itemIds = [];
    };
    switch (itemReward) {
      case (#SpecificItem itemContainer) {
        // give user specific items
        for (itemIndex in itemContainer.items.vals()) {
          // get item metadata
          let optItem : ?Ref.Item = Array.find(
            Ref.items,
            func(item : Ref.Item) : Bool {
              return item.id == itemIndex;
            },
          );
          switch (optItem) {
            case (?item) {
              ignore (await mintItemMetadata(item.metadata, address, characterIndex, item.id));
              defaultReward := {
                itemIds = append(defaultReward.itemIds, item.unityId);
                gold = 0;
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
        ignore (
          do ? {
            // get items within a tier
            let filteredItems : [Ref.Item] = Array.filter<Ref.Item>(
              Ref.items,
              func(item : Ref.Item) : Bool {
                return item.tier == itemContainer.tier;
              },
            );
            // choose a random item from the list
            let item : Ref.Item = filteredItems[randomNumber! % filteredItems.size()];
            // give item to user
            ignore (await mintItemMetadata(item.metadata, address, characterIndex, item.id));
            defaultReward := {
              itemIds = append(defaultReward.itemIds, item.unityId);
              gold = 0;
              xp = 0;
            };
          }
        );
        defaultReward;

      };
      case _ defaultReward;
    };
  };

  func giveGold(gold : Nat32, caller : Principal, positive : Bool) : Nat32 {
    let address : AccountIdentifier = AID.fromPrincipal(caller, null);
    // give user gold
    let optCurrGold : ?Nat32 = Map.get(goldMap, accountHash, address);
    switch (optCurrGold) {
      case (?currGold) {
        if (positive) {
          Map.set(goldMap, accountHash, address, currGold + gold);
        } else {
          if (gold >= currGold) {
            Map.set(goldMap, accountHash, address, Nat32.fromNat(0));
          } else {
            Map.set(goldMap, accountHash, address, currGold - gold);
          };
        };
      };
      case _ {
        Map.set(goldMap, accountHash, address, gold);
      };
    };
    gold;
  };

  // -----------------------------------
  // interaction with other canisters
  // -----------------------------------

  // TODO: refactor call
  public func mintItem(itemId : Nat16, recipient : AccountIdentifier, characterIndex : TokenIndex) : async T.ApiResponse<[Nat8]> {
    // get item metadata
    let itemContainer : ?Ref.Item = Array.find(
      Ref.items,
      func(item : Ref.Item) : Bool {
        return itemId == item.id;
      },
    );
    switch (itemContainer) {
      case (?item) {
        return await mintItemMetadata(item.metadata, recipient, characterIndex, itemId);
      };
      case _ #Err(#Other "Unable to retrieve item data");
    };
  };

  func mintItemMetadata(metadata : [Nat8], recipient : AccountIdentifier, characterIndex : TokenIndex, itemIndex : Nat16) : async T.ApiResponse<[Nat8]> {
    try {
      if (metadata == []) {
        let optNonNftItems : ?[Nat16] = Map.get(ownedNonNftItems, tokenHash, characterIndex);
        switch (optNonNftItems) {
          case (?nonNftItems) {
            Map.set(ownedNonNftItems, tokenHash, characterIndex, append(nonNftItems, itemIndex));
            return #Ok(metadata);
          };
          case _ return #Err(#Other "item definition doesn't exist");
        };
      } else {
        await itemActor.mintItem(metadata, recipient);
        return #Ok(metadata);
      };
    } catch (e) {
      return #Err(#Other("Unable to communicate with item canister: " # Error.message(e)));
    };
  };

  func getItemRegistry() : async () {
    let result = await itemActor.getRegistry();
    itemRegistry := Map.fromIter(result.vals(), tokenHash);
  };

  func getItemMetadata() : async () {
    let result = await itemActor.getMetadata();
    itemMetadata := Map.fromIter(result.vals(), tokenHash);
  };

  func getCharacterRegistry() : async () {
    let result = await characterActor.getRegistry();
    characterRegistry := Map.fromIter(result.vals(), tokenHash);
  };

  // -----------------------------------
  // canistergeek
  // -----------------------------------

  stable var canistergeekMonitorUD : ?Canistergeek.UpgradeData = null;
  private let canistergeekMonitor = Canistergeek.Monitor();

  stable var canistergeekLoggerUD : ?Canistergeek.LoggerUpgradeData = null;
  private let canistergeekLogger = Canistergeek.Logger();

  private let adminPrincipal : Text = "csvbe-getzk-3k2vt-boxl5-v2mzn-rzn23-oraa7-gjauz-dvoyn-upjlb-3ae";

  public query ({ caller }) func getCanistergeekInformation(request : Canistergeek.GetInformationRequest) : async Canistergeek.GetInformationResponse {
    validateCaller(caller);
    Canistergeek.getInformation(?canistergeekMonitor, ?canistergeekLogger, request);
  };

  public shared ({ caller }) func updateCanistergeekInformation(request : Canistergeek.UpdateInformationRequest) : async () {
    validateCaller(caller);
    canistergeekMonitor.updateInformation(request);
  };

  private func validateCaller(principal : Principal) : () {
    // data is available only for specific principal
    if (not (Principal.toText(principal) == adminPrincipal)) {
      Debug.trap("Not Authorized");
    };
  };

  // -----------------------------------
  // management
  // -----------------------------------

  public shared ({ caller }) func adminUpdateRegistryCache() : async () {
    assert Env.isAdmin(caller);

    await getCharacterRegistry();
    await getItemRegistry();
    await getItemMetadata();
    lastRegistryUpdate := Time.now();
  };

  public func specSetStubbedCanisterIds(characterCanisterId : Text, itemCanisterId : Text) : async Result.Result<(), Text> {
    if (Env.network != "local") return #err("Method only allowed in local");

    characterActor := actor (characterCanisterId);
    itemActor := actor (itemCanisterId);
    #ok;
  };

  public query func specGetCharacterOwner(characterIndex : ER.TokenIndex) : async Result.Result<(ER.AccountIdentifier), Text> {
    if (Env.network != "local") return #err("Method only allowed in local");

    let ownerId = Map.get(characterRegistry, tokenHash, characterIndex);
    switch (ownerId) {
      case (?ownerId) return #ok(ownerId);
      case (null) return #err("Not Found");
    };
  };

  public query func specGetItemOwner(itemIndex : ER.TokenIndex) : async Result.Result<(ER.AccountIdentifier), Text> {
    if (Env.network != "local") return #err("Method only allowed in local");

    let ownerId = Map.get(itemRegistry, tokenHash, itemIndex);
    switch (ownerId) {
      case (?ownerId) return #ok(ownerId);
      case (null) return #err("Not Found");
    };
  };

  public query func specGetState(key : Text) : async Text {
    if (Env.network != "local") return Debug.trap("Method only allowed in local");

    switch (key) {
      case ("authTokenSize") return debug_show Map.size(authTokenRegistry);
      case _ return Debug.trap("key not found");
    };
  };
};
