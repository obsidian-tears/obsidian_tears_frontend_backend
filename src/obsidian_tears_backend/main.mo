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
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Random "mo:base/Random";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

import AID "util/AccountIdentifier";
import ExtCommon "ext/Common";
import ExtCore "ext/Core";
import { TokenIndex } "ext/Core";
import Ref "reference";
import T "types";
import C "consts";
import Env "env";

actor class ObsidianTearsBackend() = this {
  // Types
  type AccountIdentifier = ExtCore.AccountIdentifier;
  type TokenIndex = ExtCore.TokenIndex;
  type CommonError = ExtCore.CommonError;
  type Metadata = ExtCommon.Metadata;

  // Sessions DB
  stable var _lastCleared : Time.Time = Time.now(); // keep track of the last time you cleared sessions
  stable var _lastRegistryUpdate : Time.Time = Time.now(); // keep track of the last time you cleared sessions

  // Env
  let _minter : Principal = Principal.fromText(Env.getAdminPrincipal());
  let _itemCanister : Text = Env.getItemCanisterId();
  let _characterCanister : Text = Env.getCharacterCanisterId();

  // Actors
  var _characterActor : T.CharacterInterface = actor (_characterCanister);
  var _itemActor : T.ItemInterface = actor (_itemCanister);

  // State
  stable var _saveDataState : [(TokenIndex, Text)] = [];
  stable var _sessionsState : [(TokenIndex, T.SessionData)] = [];
  stable var _characterRegistryState : [(TokenIndex, AccountIdentifier)] = [];
  stable var _itemMetadataState : [(TokenIndex, Metadata)] = [];
  stable var _itemRegistryState : [(TokenIndex, AccountIdentifier)] = [];
  stable var _equippedItemsState : [(TokenIndex, [Nat16])] = [];
  stable var _ownedNonNftItemsState : [(TokenIndex, [Nat16])] = [];
  stable var _completedEventsState : [(TokenIndex, [Nat16])] = []; // which plot events and chests have been completed
  stable var _playerDataState : [(TokenIndex, T.PlayerData)] = [];
  stable var _goldState : [(AccountIdentifier, Nat32)] = [];

  // Dynamic
  var _saveData : HashMap.HashMap<TokenIndex, Text> = HashMap.fromIter(_saveDataState.vals(), 0, TokenIndex.equal, TokenIndex.hash);
  var _sessions : HashMap.HashMap<TokenIndex, T.SessionData> = HashMap.fromIter(_sessionsState.vals(), 0, TokenIndex.equal, TokenIndex.hash);
  var _equippedItems : HashMap.HashMap<TokenIndex, [Nat16]> = HashMap.fromIter(_equippedItemsState.vals(), 0, TokenIndex.equal, TokenIndex.hash);
  var _ownedNonNftItems : HashMap.HashMap<TokenIndex, [Nat16]> = HashMap.fromIter(_ownedNonNftItemsState.vals(), 0, TokenIndex.equal, TokenIndex.hash);
  var _completedEvents : HashMap.HashMap<TokenIndex, [Nat16]> = HashMap.fromIter(_completedEventsState.vals(), 0, TokenIndex.equal, TokenIndex.hash);
  var _playerData : HashMap.HashMap<TokenIndex, T.PlayerData> = HashMap.fromIter(_playerDataState.vals(), 0, TokenIndex.equal, TokenIndex.hash);
  var _gold : HashMap.HashMap<AccountIdentifier, Nat32> = HashMap.fromIter(_goldState.vals(), 0, AID.equal, AID.hash);

  // ********* NOW ********* //
  // TODO create new game function that sets player data at default
  // TODO create level up function that increases player level and stats

  // ********* LATER ********* //
  // TODO track player position with timestamps. based on event positions (eg. opening chests) determine whether player could have traveled that far
  // TODO keep track of story progress for player (list of events in story that have been completed)
  // TODO for each relevent event (eg. opening a chest at the end of a sidequest) have a list of story events that must be completed to open chest.
  // TODO keep track of opened chests for each character

  var _characterRegistry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_characterRegistryState.vals(), 0, TokenIndex.equal, TokenIndex.hash);
  var _itemRegistry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_itemRegistryState.vals(), 0, TokenIndex.equal, TokenIndex.hash);
  var _itemMetadata : HashMap.HashMap<TokenIndex, Metadata> = HashMap.fromIter(_itemMetadataState.vals(), 0, TokenIndex.equal, TokenIndex.hash);

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

  // -----------------------------------
  // user interaction with this canister
  // -----------------------------------

  // check if user owns character NFT and create session for fast lookup. return owned NFT data
  public shared ({ caller }) func verify() : async (T.ApiResponse<[TokenIndex]>) {
    let address : AccountIdentifier = AID.fromPrincipal(caller, null);
    let result : Result.Result<[TokenIndex], CommonError> = await _characterActor.tokens(address);
    switch (result) {
      case (#ok indices) {
        return #Ok indices;
      };
      case (#err e) {
        return #Err(#Other("Error verifying user"));
      };
    };
  };

  // login when user selects
  public shared ({ caller }) func loadGame(characterIndex : TokenIndex) : async (T.ApiResponse<Text>) {
    switch (checkSession(caller, characterIndex)) {
      case (#Err e) {
        return #Err e;
      };
      case (_) {};
    };
    // check if they have a saved game
    return _load(characterIndex, AID.fromPrincipal(caller, null));
  };

  // save game data formatted in json so that unity can load correctly
  public shared ({ caller }) func saveGame(characterIndex : TokenIndex, gameData : Text) : async (T.ApiResponse<Text>) {
    switch (checkSession(caller, characterIndex)) {
      case (#Err e) {
        return #Err e;
      };
      case (_) {};
    };
    // TODO: save the equipped items data into the equipped items stable memory
    // save boring data (everything but items and player stats)
    _saveData.put(characterIndex, gameData);
    return _load(characterIndex, AID.fromPrincipal(caller, null));
  };

  // called when opening a treasure chest or receiving
  public shared ({ caller }) func openChest(characterIndex : TokenIndex, chestIndex : Nat16) : async (T.ApiResponse<T.RewardInfo>) {
    switch (checkSession(caller, characterIndex)) {
      case (#Err e) {
        return #Err e;
      };
      case (#Ok session) {
        let address : AccountIdentifier = AID.fromPrincipal(caller, null);
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
                gold = _giveGold(chest.gold, caller, true);
                xp = rewardInfo.xp;
              };
            };
            let itemResult : T.RewardInfo = await _mintRewardItems(chest.itemReward, caller, characterIndex);
            rewardInfo := {
              itemIds = itemResult.itemIds;
              gold = rewardInfo.gold;
              xp = 0;
            };
            // return the collected return vals in RewardInfo
            ignore (updateSession(characterIndex, session, 0, rewardInfo.gold, Nat8.fromNat(rewardInfo.itemIds.size())));
            #Ok(rewardInfo);
          };
          case _ return #Err(#Other("Server Error: Chest Definition Missing"));
        };
      };
    };
  };

  // not yet called
  public shared ({ caller }) func consumeItem(characterIndex : TokenIndex, itemIndex : Nat16) : async (T.ApiResponse<()>) {
    switch (checkSession(caller, characterIndex)) {
      case (#Err e) {
        return #Err e;
      };
      case (#Ok session) {
        // get item tokenindex by checking metadata or whatever. burn item
        let address : AccountIdentifier = AID.fromPrincipal(caller, null);
        _unequipItem(itemIndex, characterIndex);
        await _burnItem(address, characterIndex, itemIndex);
        #Ok;
      };
    };
  };

  public shared ({ caller }) func buyItem(characterIndex : TokenIndex, shopIndex : Nat16, qty : Int, itemIndex : Nat16) : async (T.ApiResponse<()>) {
    switch (checkSession(caller, characterIndex)) {
      case (#Err e) {
        return #Err e;
      };
      case (#Ok session) {
        // check that the item exists in a valid shop inventory
        let shopContainer : ?Ref.Market = Array.find(
          Ref.markets,
          func(market : Ref.Market) : Bool {
            return market.id == shopIndex;
          },
        );
        var goldCost : Nat32 = 0;
        switch (shopContainer) {
          case (?shop) {
            let containedItem : ?Ref.ItemListing = Array.find(
              shop.items,
              func(item : Ref.ItemListing) : Bool {
                goldCost := item.cost;
                return item.id == itemIndex;
              },
            );
            if (containedItem == null) {
              return #Err(#Other "item does not exist for shop");
            };
          };
          case _ return #Err(#Other "error retrieving shop data");
        };
        // check that player has enough gold
        let address : AccountIdentifier = AID.fromPrincipal(caller, null);
        let optCurrGold : ?Nat32 = _gold.get(address);
        switch (optCurrGold) {
          case (?currGold) {
            if (currGold < goldCost) {
              return #Err(#Other "not enough gold to purchase item");
            };
            ignore (_giveGold(goldCost, caller, false));
          };
          case _ return #Err(#Other "not enough gold to purchase item");
        };
        // update player session (counts as receiving an item)
        ignore (updateSession(characterIndex, session, 0, 0, 1));
        for (i in Iter.range(1, qty)) {
          ignore (await mintItem(itemIndex, address, characterIndex));
        };
        return #Ok;
      };
    };
  };

  func _unequipItem(itemIndex : Nat16, characterIndex : TokenIndex) : () {
    let optEquippedItems : ?[Nat16] = _equippedItems.get(characterIndex);
    switch (optEquippedItems) {
      case (?equippedItems) {
        // take out one item that matches index.
        let optFoundItem : ?Nat16 = Array.find(
          equippedItems,
          func(item : Nat16) : Bool {
            item == itemIndex;
          },
        );
        switch (optFoundItem) {
          case (?foundItem) {
            let newEquippedItems : [Nat16] = Array.filter(
              equippedItems,
              func(item : Nat16) : Bool {
                item != itemIndex;
              },
            );
            _equippedItems.put(characterIndex, newEquippedItems);
          };
          case _ {};
        };
      };
      case _ {};
    };
  };

  public shared ({ caller }) func equipItems(characterIndex : TokenIndex, itemIndices : [Nat16]) : async (T.ApiResponse<()>) {
    switch (checkSession(caller, characterIndex)) {
      case (#Err e) {
        return #Err e;
      };
      case (_) {};
    };
    // make sure that caller owns all items;
    let address : AccountIdentifier = AID.fromPrincipal(caller, null);
    // get player owned game items
    let gameItems = getOwnedItems(address, characterIndex);
    // get player equipped game items
    let optEquippedItems : ?[Nat16] = _equippedItems.get(characterIndex);
    switch (optEquippedItems) {
      case (?equippedItems) {
        for (itemIndex in itemIndices.vals()) {
          // get item details
          let optItem : ?Ref.Item = Array.find(
            Ref.items,
            func(item : Ref.Item) : Bool {
              return item.id == itemIndex;
            },
          );
          switch (optItem) {
            case (?itemToEquip) {
              // make sure item isn't already equipped
              let equippedMatchingItems : [Nat16] = Array.filter(
                equippedItems,
                func(eItem : Nat16) : Bool {
                  eItem == itemToEquip.id;
                },
              );
              if (equippedMatchingItems.size() > 0) {
                return #Err(#Other("Cannot equip more than one of the same item"));
              };
              // make sure they own unequipped item
              let unequippedMatchingItem : [Ref.Item] = Array.filter(
                gameItems,
                func(item : Ref.Item) : Bool {
                  item.metadata == item.metadata;
                },
              );
              if (unequippedMatchingItem.size() == 0) {
                return #Err(#Other("Cannot equip item not owned by user"));
              };
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
  public shared ({ caller }) func defeatMonster(characterIndex : TokenIndex, monsterIndex : Nat16) : async (T.ApiResponse<T.RewardInfo>) {
    switch (checkSession(caller, characterIndex)) {
      case (#Err e) {
        return #Err e;
      };
      case (#Ok session) {
        // look up monster by index
        let optMonster : ?Ref.Monster = Array.find(
          Ref.monsters,
          func(monster : Ref.Monster) : Bool {
            return monster.id == monsterIndex;
          },
        );
        // add monster rewards to character and session
        switch (optMonster) {
          case (?monster) {
            // give player gold
            switch (_playerData.get(characterIndex)) {
              // TODO: give every player player data on start
              // case(?playerData) {}
              case (_) {
                let itemInfo : T.RewardInfo = await _mintRewardItemsProb(monster.itemReward, caller, monster.itemProb, characterIndex);
                let rewardInfo : T.RewardInfo = {
                  gold = _giveGold(monster.gold, caller, true);
                  xp = monster.xp;
                  itemIds = itemInfo.itemIds;
                };
                ignore (updateSession(characterIndex, session, rewardInfo.xp, rewardInfo.gold, Nat8.fromNat(rewardInfo.itemIds.size())));
                #Ok rewardInfo;
              };
              // case(_) {
              // #Err(#Other("Server Error. Failed to find player data."));
              // };
            };
          };
          case _ {
            #Err(#Other("Server Error. Failed to find monster data."));
          };
        };
      };
    };
  };

  // -----------------------------------
  // http
  // -----------------------------------
  public query func http_request(request : T.HttpRequest) : async T.HttpResponse {
    let name = "Obsidian Tears RPG";
    return {
      status_code = 200;
      headers = [("content-type", "text/plain")];
      body = Text.encodeUtf8(
        name # "\n" # "---\n" # "Cycle Balance:                            ~" # debug_show (Cycles.balance() / 1000000000000) # "T\n" # "---\n" # "Current Sessions:                         " # debug_show (_sessions.size()) # "\n" # "Saved Games:                              " # debug_show (_saveData.size()) # "\n" # "---\n" # "Admin:                                    " # debug_show (_minter) # "\n"
      );
      streaming_strategy = null;
    };
  };

  // -----------------------------------
  // helper functions
  // -----------------------------------
  // compare metadata and a [Nat8]
  func compareMetadata(arrData : [Nat8], metadata : Metadata) : Bool {
    switch (metadata) {
      case (#nonfungible r) {
        switch (r.metadata) {
          case (?data) {
            data == Blob.fromArray(arrData);
          };
          case _ false;
        };
      };
      case _ false;
    };
  };
  // update session when you earn gold, xp, or items
  func updateSession(characterIndex : TokenIndex, session : T.SessionData, xp : Nat32, gold : Nat32, items : Nat8) : T.ApiResponse<()> {
    _sessions.put(
      characterIndex,
      {
        createdAt = session.createdAt;
        goldEarned = session.goldEarned + gold;
        xpEarned = session.xpEarned + xp;
        itemsEarned = session.itemsEarned + items;
      },
    );
    #Ok();
  };
  func _burnItem(accountIdentifier : AccountIdentifier, characterIndex : TokenIndex, itemIndex : Nat16) : async () {
    // filter all item nfts owned by character
    let ownedItems : [TokenIndex] = Iter.toArray(
      HashMap.mapFilter<TokenIndex, AccountIdentifier, TokenIndex>(
        _itemRegistry,
        TokenIndex.equal,
        TokenIndex.hash,
        func(index : TokenIndex, account : AccountIdentifier) : ?TokenIndex {
          if (account == accountIdentifier) {
            return ?index;
          };
          null;
        },
      ).keys()
    );

    let optItemToDelete : ?Ref.Item = Array.find(
      Ref.items,
      func(item : Ref.Item) : Bool {
        item.id == itemIndex;
      },
    );
    switch (optItemToDelete) {
      case (?itemToDelete) {
        // get token to burn
        let optTokenToBurn : ?TokenIndex = Array.find(
          ownedItems,
          func(tokenIndex : TokenIndex) : Bool {
            let optMetadata : ?Metadata = _itemMetadata.get(tokenIndex);
            switch (optMetadata) {
              case (?metadata) {
                switch (metadata) {
                  case (#nonfungible nft) {
                    switch (nft.metadata) {
                      case (?meta) {
                        Blob.toArray(meta) == itemToDelete.metadata;
                      };
                      case _ false;
                    };
                  };
                  case _ false;
                };
              };
              case _ false;
            };
          },
        );
        switch (optTokenToBurn) {
          case (?tokenToBurn) {
            // TODO: implement in items_nft repo
            // await _itemActor.burnItem(tokenToBurn);
          };
          case _ {};
        };
      };
      case _ {};
    };
  };

  func getOwnedItems(accountIdentifier : AccountIdentifier, characterIndex : TokenIndex) : [Ref.Item] {
    // filter all item nfts owned by character
    let ownedItems : [TokenIndex] = Iter.toArray(
      HashMap.mapFilter<TokenIndex, AccountIdentifier, TokenIndex>(
        _itemRegistry,
        TokenIndex.equal,
        TokenIndex.hash,
        func(index : TokenIndex, account : AccountIdentifier) : ?TokenIndex {
          if (account == accountIdentifier) {
            return ?index;
          };
          null;
        },
      ).keys()
    );
    // make sure metadata that identifies what the item is (see item nft canister)
    let ownedItemsMeta : [Metadata] = Array.map<TokenIndex, Metadata>(
      ownedItems,
      func(tokenIndex : TokenIndex) : Metadata {
        let optMetadata : ?Metadata = _itemMetadata.get(tokenIndex);
        switch (optMetadata) {
          case (?metadata) metadata;
          case _ #nonfungible({ metadata = ?Blob.fromArray([]) });
        };
      },
    );
    // matches corresponding metadata in item list
    var gameItems : [Ref.Item] = Array.mapFilter<Metadata, Ref.Item>(
      ownedItemsMeta,
      func(metadata : Metadata) : ?Ref.Item {
        Array.find(
          Ref.items,
          func(i : Ref.Item) : Bool {
            compareMetadata(i.metadata, metadata);
          },
        );
      },
    );
    let optNonNftItems : ?[Nat16] = _ownedNonNftItems.get(characterIndex);
    switch (optNonNftItems) {
      case (?nonNftItems) {
        let newItems : [Ref.Item] = Array.mapFilter<Nat16, Ref.Item>(
          nonNftItems,
          func(index : Nat16) : ?Ref.Item {
            Array.find(
              Ref.items,
              func(i : Ref.Item) : Bool {
                i.id == index;
              },
            );
          },
        );
        gameItems := _appendAll(gameItems, newItems);
      };
      case _ {};
    };
    gameItems;
  };
  // load game data formatted in json so that unity can load correctly
  func _load(characterIndex : TokenIndex, accountIdentifier : AccountIdentifier) : T.ApiResponse<Text> {
    switch (_saveData.get(characterIndex)) {
      case (?save) {
        // piece together the inventory and player stats
        // "{\\"items\\":[],\\"equippedItems\\":[\\"2069047119\\"],\\"currency\\":10}"
        var itemsString = "\\\"items\\\":[";
        var equippedItemsString = "\\\"equippedItems\\\":[";
        var goldString = "\\\"currency\\\":";
        // get user gold
        let optCurrency : ?Nat32 = _gold.get(accountIdentifier);
        switch (optCurrency) {
          case (?currency) {
            goldString #= Nat32.toText(currency);
          };
          case _ goldString #= Nat8.toText(0);
        };
        // get the unityId for owned items
        let ownedItems : [Ref.Item] = getOwnedItems(accountIdentifier, characterIndex);
        switch (_equippedItems.get(characterIndex)) {
          case (?items) {
            // add all equipped items to equipped items string. everything else to items string
            // loop through items and get equipped item strings
            let unityIds : Text = Array.foldLeft(
              items,
              "",
              func(prev : Text, itemId : Nat16) : Text {
                var returnText = "";
                let itemContainer : ?Ref.Item = Array.find(
                  Ref.items,
                  func(item : Ref.Item) : Bool {
                    return item.id == itemId;
                  },
                );
                switch (itemContainer) {
                  case (?item) {
                    if (prev != "") {
                      returnText #= ",";
                    };
                    returnText #= "\\\"" # item.unityId # "\\\"";

                  };
                  case _ {};
                };
                prev # returnText;
              },
            );
            equippedItemsString #= unityIds;

            // add the rest to items string
            let unequippedOwnedItems : [Ref.Item] = Array.filter(
              ownedItems,
              func(item : Ref.Item) : Bool {
                let returnId : ?Nat16 = Array.find(
                  items,
                  func(id : Nat16) : Bool {
                    id == item.id;
                  },
                );
                switch (returnId) {
                  case (?id) false;
                  case _ true;
                };
              },
            );
            let unequippedUnityIds : Text = Array.foldLeft(
              unequippedOwnedItems,
              "",
              func(prev : Text, item : Ref.Item) : Text {
                var returnText = "";
                if (prev != "") {
                  returnText #= ",";
                };
                returnText #= "\\\"" # item.unityId # "\\\"";
                prev # returnText;
              },
            );
            itemsString #= unequippedUnityIds;

          };
          case (_) {
            // don't add anything to equipped items string. add everything to items string
            let unityIds : Text = Array.foldLeft(
              ownedItems,
              "",
              func(prev : Text, item : Ref.Item) : Text {
                var returnText = "";
                if (prev != "") {
                  returnText #= ",";
                };
                returnText #= "\\\"" # item.unityId # "\\\"";
                return prev # returnText;
              },
            );
            itemsString #= unityIds;
          };
        };
        equippedItemsString #= "]";
        itemsString #= "]";

        let invCurrData : Text = "{" # itemsString # "," # equippedItemsString # "," # goldString # "}";
        let invCurrSplit : Iter.Iter<Text> = Text.split(save, #text("playerInvCurrData"));
        let invCurrStitch : Text = Text.join(invCurrData, invCurrSplit);

        // add stats
        // "{
        //   \"characterName\":\"Phendrin\",\"characterClass\":\"\",\"level\":1,\"xp\":0,\"xpToLevelUp\":75,
        //   \"pointsRemaining\":0,\"healthBase\":15,\"healthTotal\":15,\"healthMax\":15,\"magicBase\":10,\"magicTotal\":10,
        //   \"magicMax\":10,\"attackBase\":5,\"attackTotal\":5,\"magicPowerBase\":0,\"magicPowerTotal\":0,\"defenseBase\":5,
        //   \"defenseTotal\":5,\"speedBase\":5,\"speedTotal\":5,\"criticalHitProbability\":0.0,\"characterEffects\":[]
        // }"
        var statsString = "{";
        let optPlayerData : ?T.PlayerData = _playerData.get(characterIndex);
        switch (optPlayerData) {
          case (?playerData) {
            statsString #= "\\\"characterName\\\":\\\"" # playerData.characterName # "\\\",";
            statsString #= "\\\"characterClass\\\":\\\"" # playerData.characterClass # "\\\",";
            statsString #= "\\\"level\\\":" # Nat16.toText(playerData.level) # ",";
            statsString #= "\\\"xp\\\":" # Nat32.toText(playerData.xp) # ",";
            statsString #= "\\\"xpToLevelUp\\\":" # Nat32.toText(playerData.xpToLevelUp) # ",";
            statsString #= "\\\"pointsRemaining\\\":" # Nat32.toText(playerData.pointsRemaining) # ",";
            statsString #= "\\\"healthBase\\\":" # Nat16.toText(playerData.healthBase) # ",";
            statsString #= "\\\"healthTotal\\\":" # Nat16.toText(playerData.healthTotal) # ",";
            statsString #= "\\\"healthMax\\\":" # Nat16.toText(playerData.healthMax) # ",";
            statsString #= "\\\"magicBase\\\":" # Nat16.toText(playerData.magicBase) # ",";
            statsString #= "\\\"magicTotal\\\":" # Nat16.toText(playerData.magicTotal) # ",";
            statsString #= "\\\"magicMax\\\":" # Nat16.toText(playerData.magicMax) # ",";
            statsString #= "\\\"attackBase\\\":" # Nat16.toText(playerData.attackBase) # ",";
            statsString #= "\\\"attackTotal\\\":" # Nat16.toText(playerData.attackTotal) # ",";
            statsString #= "\\\"defenseBase\\\":" # Nat16.toText(playerData.defenseBase) # ",";
            statsString #= "\\\"defenseTotal\\\":" # Nat16.toText(playerData.defenseTotal) # ",";
            statsString #= "\\\"speedBase\\\":" # Nat16.toText(playerData.speedBase) # ",";
            statsString #= "\\\"speedTotal\\\":" # Nat16.toText(playerData.speedTotal) # ",";
            statsString #= "\\\"criticalHitProbability\\\":" # Float.toText(playerData.criticalHitProbability) # ",";
            statsString #= "\\\"characterEffects\\\":[]";
            // TODO: format character effects into json string
          };
          case _ {
            statsString #= "\\\"characterName\\\":\\\"Phendrin\\\",";
            statsString #= "\\\"characterClass\\\":\\\"\\\",";
            statsString #= "\\\"level\\\":1,";
            statsString #= "\\\"xp\\\":0,";
            statsString #= "\\\"xpToLevelUp\\\":75,";
            statsString #= "\\\"pointsRemaining\\\":0,";
            statsString #= "\\\"healthBase\\\":15,";
            statsString #= "\\\"healthTotal\\\":15,";
            statsString #= "\\\"healthMax\\\":0,";
            statsString #= "\\\"magicBase\\\":0,";
            statsString #= "\\\"magicTotal\\\":0,";
            statsString #= "\\\"magicMax\\\":0,";
            statsString #= "\\\"attackBase\\\":0,";
            statsString #= "\\\"attackTotal\\\":0,";
            statsString #= "\\\"defenseBase\\\":0,";
            statsString #= "\\\"defenseTotal\\\":0,";
            statsString #= "\\\"speedBase\\\":0,";
            statsString #= "\\\"speedTotal\\\":0,";
            statsString #= "\\\"criticalHitProbability\\\":0.0,";
            statsString #= "\\\"characterEffects\\\":[]";
          };
        };
        statsString #= "}";
        let statsData : Text = statsString;
        let statsSplit : Iter.Iter<Text> = Text.split(invCurrStitch, #text("charStatsData"));
        let statsStitch : Text = Text.join(statsData, statsSplit);

        return #Ok statsStitch;
      };
      case (_) {
        return #Err(#Other("No save data"));
      };
    };
  };

  func checkSession(caller : Principal, tokenIndex : TokenIndex) : T.ApiResponse<T.SessionData> {
    // convert principal into wallet
    let address : AccountIdentifier = AID.fromPrincipal(caller, null);
    // make sure the principal owns this tokenIndex
    switch (_characterRegistry.get(tokenIndex)) {
      case (?owner) {
        if (owner != address and caller != _minter) {
          return #Err(#Unauthorized);
        };
      };
      case (_) {};
    };

    // make sure player hasn't exceeded limits for the day
    switch (_sessions.get(tokenIndex)) {
      // if their session has been reset, replace it
      case (?session) {
        if (session.goldEarned >= C.MAX_GOLD or session.itemsEarned >= C.MAX_ITEMS or session.xpEarned >= C.MAX_XP) {
          // return #Err(#Limit);
          return #Ok session;
        } else {
          return #Ok session;
        };
      };
      case (_) {
        let newSession : T.SessionData = {
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

  func _append<T>(array : [T], val : T) : [T] {
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

  func _appendAll<T>(array : [T], val : [T]) : [T] {
    if (val.size() == 0) {
      return array;
    };
    let new = Array.tabulate<T>(
      array.size() + val.size(),
      func(i) {
        if (i < array.size()) {
          array[i];
        } else {
          val[i - array.size()];
        };
      },
    );
    new;
  };

  func _getParam(url : Text, param : Text) : ?Text {
    var _s : Text = url;
    Iter.iterate<Text>(
      Text.split(_s, #text("/")),
      func(x, _i) {
        _s := x;
      },
    );
    Iter.iterate<Text>(
      Text.split(_s, #text("?")),
      func(x, _i) {
        if (_i == 1) _s := x;
      },
    );
    var t : ?Text = null;
    var found : Bool = false;
    Iter.iterate<Text>(
      Text.split(_s, #text("&")),
      func(x, _i) {
        if (found == false) {
          Iter.iterate<Text>(
            Text.split(x, #text("=")),
            func(y, _ii) {
              if (_ii == 0) {
                if (Text.equal(y, param)) found := true;
              } else if (found == true) {
                t := ?y;
              };
            },
          );
        };
      },
    );
    return t;
  };

  func _mintRewardItemsProb(itemReward : Ref.ItemReward, caller : Principal, itemProb : Nat8, characterIndex : TokenIndex) : async T.RewardInfo {
    // check probability and mint items
    let optRandomNumber : ?Nat = Random.Finite(Principal.toBlob(caller)).range(8);
    switch (optRandomNumber) {
      case (?randomNumber) {
        if (randomNumber % 100 <= Nat8.toNat(itemProb)) {
          await _mintRewardItems(itemReward, caller, characterIndex);
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

  func _mintRewardItems(itemReward : Ref.ItemReward, caller : Principal, characterIndex : TokenIndex) : async T.RewardInfo {
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
              ignore (await _mintItem(item.metadata, address, characterIndex, item.id));
              defaultReward := {
                itemIds = _append(defaultReward.itemIds, item.unityId);
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
            ignore (await _mintItem(item.metadata, address, characterIndex, item.id));
            defaultReward := {
              itemIds = _append(defaultReward.itemIds, item.unityId);
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

  func _giveGold(gold : Nat32, caller : Principal, positive : Bool) : Nat32 {
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
  public shared (msg) func getEquippedItems(characterIndex : TokenIndex, accountIdentifier : AccountIdentifier) : async [TokenIndex] {
    switch (_equippedItems.get(characterIndex)) {
      case (?equippedItems) {
        // get the item nft token indices for all equipped items
        let optEquippedItems : ?[Nat16] = _equippedItems.get(characterIndex);
        switch (optEquippedItems) {
          case (?equippedItems) {
            let optOwnedItems : [TokenIndex] = Iter.toArray(
              HashMap.mapFilter<TokenIndex, AccountIdentifier, TokenIndex>(
                _itemRegistry,
                TokenIndex.equal,
                TokenIndex.hash,
                func(index : TokenIndex, account : AccountIdentifier) : ?TokenIndex {
                  if (account == accountIdentifier) {
                    return ?index;
                  };
                  return null;
                },
              ).keys()
            );
            switch (optOwnedItems) {
              case (ownedItems) {
                // make sure metadata that identifies what the item is (see item nft canister)
                let ownedItemsMeta : [{
                  index : TokenIndex;
                  data : Metadata;
                }] = Array.map<TokenIndex, { index : TokenIndex; data : Metadata }>(
                  ownedItems,
                  func(tokenIndex : TokenIndex) : {
                    index : TokenIndex;
                    data : Metadata;
                  } {
                    let optMetadata : ?Metadata = _itemMetadata.get(tokenIndex);
                    switch (optMetadata) {
                      case (?metadata) return {
                        index = tokenIndex;
                        data = metadata;
                      };
                      case _ return {
                        index = 0;
                        data = #nonfungible({
                          metadata = ?Blob.fromArray([]);
                        });
                      };
                    };
                  },
                );
                let ownedItemObjs : [Ref.Item] = getOwnedItems(accountIdentifier, characterIndex);
                let equippedIndices : [TokenIndex] = Array.mapFilter<Nat16, TokenIndex>(
                  equippedItems,
                  func(id : Nat16) : ?TokenIndex {
                    // get the owned item object corresponding to the equipped item id
                    let optOwnedItemObj : ?Ref.Item = Array.find(
                      ownedItemObjs,
                      func(item : Ref.Item) : Bool {
                        item.id == id;
                      },
                    );
                    switch (optOwnedItemObj) {
                      case (?ownedItemObj) {
                        // compare ownedItem object to the owned item meta mapping. return tokenindex
                        let optFoundItemMeta : ?{
                          index : TokenIndex;
                          data : Metadata;
                        } = Array.find(
                          ownedItemsMeta,
                          func(ownedItemMeta : { index : TokenIndex; data : Metadata }) : Bool {
                            compareMetadata(ownedItemObj.metadata, ownedItemMeta.data);
                          },
                        );
                        switch (optFoundItemMeta) {
                          case (?foundItemMeta) {
                            // reeturn the tokenidnex
                            ?foundItemMeta.index;
                          };
                          case _ null;
                        };
                      };
                      case _ null;
                    };
                  },
                );
                equippedIndices;
              };
            };
          };
          case _ [];
        };
      };
      case _ [];
    };
  };

  func mintItem(itemId : Nat16, recipient : AccountIdentifier, characterIndex : TokenIndex) : async T.ApiResponse<[Nat8]> {
    // get item metadata
    let itemContainer : ?Ref.Item = Array.find(
      Ref.items,
      func(item : Ref.Item) : Bool {
        return itemId == item.id;
      },
    );
    switch (itemContainer) {
      case (?item) {
        return await _mintItem(item.metadata, recipient, characterIndex, itemId);
      };
      case _ #Err(#Other "Unable to retrieve item data");
    };
  };

  func _mintItem(metadata : [Nat8], recipient : AccountIdentifier, characterIndex : TokenIndex, itemIndex : Nat16) : async T.ApiResponse<[Nat8]> {
    try {
      if (metadata == []) {
        let optNonNftItems : ?[Nat16] = _ownedNonNftItems.get(characterIndex);
        switch (optNonNftItems) {
          case (?nonNftItems) {
            _ownedNonNftItems.put(characterIndex, _append(nonNftItems, itemIndex));
            return #Ok(metadata);
          };
          case _ return #Err(#Other "item definition doesn't exist");
        };
      } else {
        let result = await _itemActor.mintItem(metadata, recipient);
        return #Ok(metadata);
      };
    } catch (e) {
      return #Err(#Other("Unable to communicate with item canister: " # Error.message(e)));
    };
  };

  func getItemRegistry() : async () {
    let result = await _itemActor.getRegistry();
    _itemRegistry := HashMap.fromIter(result.vals(), 0, TokenIndex.equal, TokenIndex.hash);
  };

  func getItemMetadata() : async () {
    let result = await _itemActor.getMetadata();
    _itemMetadata := HashMap.fromIter(result.vals(), 0, TokenIndex.equal, TokenIndex.hash);
  };

  func getCharacterRegistry() : async () {
    let result = await _characterActor.getRegistry();
    _characterRegistry := HashMap.fromIter(result.vals(), 0, TokenIndex.equal, TokenIndex.hash);
  };

  // -----------------------------------
  // management
  // -----------------------------------

  public func adminUpdateRegistryCache() : async () {
    await getCharacterRegistry();
    await getItemRegistry();
    await getItemMetadata();
    _lastRegistryUpdate := Time.now();
  };

  public func adminSetStubbedCanisterIds(characterCanisterId : Text, itemCanisterId : Text) : async Result.Result<(), Text> {
    if (Env.network != "local") return #err("Method only allowed in local");

    _characterActor := actor (characterCanisterId);
    _itemActor := actor (itemCanisterId);
    #ok;
  };
};
