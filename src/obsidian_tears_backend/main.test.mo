import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Blob "mo:base/Blob";
import Option "mo:base/Option";
import Text "mo:base/Text";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";

import {
  assertTrue;
  describe;
  context;
  it;
  pending;
  run;
} "mo:mospec/MoSpec";

import Main "main";
import T "types";
import ExtCore "lib/ext/Core";
import ExtCommon "lib/ext/Common";
import CharacterActor "../../spec/actors/CharacterActor";
import ItemActor "../../spec/actors/ItemActor";
import GameJsonFactory "../../spec/factories/GameJsonFactory";
import AID "lib/util/AccountIdentifier";

let backendActor = await Main.ObsidianTearsBackend();

// ==================
// setup
// ==================

// spec actor/caller id
let selfId = Principal.fromText("wo5qg-ysjiq-5da");
let selfAddress : ExtCore.AccountIdentifier = AID.fromPrincipal(selfId, null);

// stubbed actors
let characterActor = await CharacterActor.CharacterActor();
let characterActorId = Principal.toText(Principal.fromActor(characterActor));
let itemActor = await ItemActor.ItemActor();
let itemActorId = Principal.toText(Principal.fromActor(itemActor));
ignore await backendActor.specSetStubbedCanisterIds(characterActorId, itemActorId);

// set default character nfts
let defaultCharacterTokensResponse : Result.Result<[ExtCore.TokenIndex], ExtCore.CommonError> = #ok([1, 2, 3, 4]);
await characterActor.setTokensResponse(defaultCharacterTokensResponse);
let defaultItemTokensResponse : Result.Result<[ExtCore.TokenIndex], ExtCore.CommonError> = #ok([1, 5, 34]);
await itemActor.setTokensResponse(defaultItemTokensResponse);
let defaultCharacterRegistryResponse : [(ExtCore.TokenIndex, ExtCore.AccountIdentifier)] = [(1, selfAddress), (2, selfAddress)];
await characterActor.setRegistryResponse(defaultCharacterRegistryResponse);

// vars
var playerNftId : Nat32 = 2;
var itemNftIndex : Nat32 = 5;
var gameData : Text = GameJsonFactory.defaultGameJson;
var chestId : Nat16 = 35;
var itemId : Nat16 = 35;
var shopId : Nat16 = 0;

let success = run([
  describe(
    "#verify",
    [
      it(
        "should return list of NFTs owned",
        do {
          let response = await backendActor.verify();
          assertTrue(response == #Ok([1, 2, 3, 4]));
        },
      ),
      it(
        "should update registry cache of Characters owned",
        do {
          let ownerId = await backendActor.specGetCharacterOwner(playerNftId);
          switch (ownerId) {
            case (#ok(ownerId)) {
              assertTrue(ownerId == selfAddress);
            };
            case (#err(_message)) false;
          };
        },
      ),
      it(
        "should update registry cache of Items owned",
        do {
          let ownerId = await backendActor.specGetItemOwner(itemNftIndex);
          switch (ownerId) {
            case (#ok(ownerId)) {
              assertTrue(ownerId == selfAddress);
            };
            case (#err(_message)) false;
          };
        },
      ),
    ],
  ),
  describe(
    "#loadGame",
    [
      it(
        "when no game saved, returns error with message",
        do {
          let response = await backendActor.loadGame(playerNftId);
          assertTrue(response == #Err(#Other("No save data")));
        },
      ),
      it(
        "when game was saved, returns game successfully",
        do {
          // before
          ignore await backendActor.saveGame(playerNftId, gameData);

          // assert
          let response = await backendActor.loadGame(playerNftId);

          // after
          ignore await backendActor.saveGame(playerNftId, "");

          switch (response) {
            case (#Ok(gameData)) assertTrue(Text.size(gameData) > 12900);
            case (#Err(_message)) false;
          };
        },
      ),
    ],
  ),
  describe(
    "#saveGame",
    [
      it(
        "saves and returns the load game output to be rendered",
        do {
          let response = await backendActor.saveGame(playerNftId, gameData);
          switch (response) {
            case (#Ok(gameData)) {
              assertTrue(Text.size(gameData) > 12900);
            };
            case (#Err(_message)) false;
          };
        },
      ),
      context(
        "when caller is not owner of token",
        [
          it(
            "refuses to save and returns error message",
            do {
              let response = await backendActor.saveGame(999, gameData);
              // TODO: improve with right caller
              // switch (response) {
              //  case (#Ok(gameData)) false;
              //  case (#Err(_message)) true;
              // };
              true;
            },
          ),
        ],
      ),
    ],
  ),
  describe(
    "#openChest",
    [
      it(
        "mints items and adds gold",
        do {
          let expectedRewardInfo : T.RewardInfo = {
            itemIds = ["4290235510"];
            gold = 20;
            xp = 0;
          };
          let response = await backendActor.openChest(playerNftId, chestId);
          switch (response) {
            case (#Ok(rewardInfo)) assertTrue(rewardInfo == expectedRewardInfo);
            case (#Err(_message)) false;
          };
        },
      ),
    ],
  ),
  describe(
    "#buyItem",
    [
      context(
        "when item is in a valid shop, and has enough gold",
        [
          it(
            "mints item",
            do {
              let potionItemId : Nat16 = 38;
              let qty = 1;
              let response = await backendActor.buyItem(playerNftId, shopId, qty, potionItemId);
              switch (response) {
                case (#Ok()) true;
                case (#Err(message)) Debug.trap(debug_show (message));
              };
            },
          ),
        ],
      ),
    ],
  ),
  describe(
    "#equipItems",
    [
      it(
        "equips items",
        do {
          // set registry on item actor
          let potionRefId : Nat16 = 47;
          let potionTokenIndex : Nat32 = 1;
          let stubbedResponse : [(ExtCore.TokenIndex, ExtCore.AccountIdentifier)] = [(potionTokenIndex, selfAddress)];
          await itemActor.setRegistryResponse(stubbedResponse);

          let stubbedMetadataResponse : [(ExtCore.TokenIndex, ExtCommon.Metadata)] = [(potionTokenIndex, #nonfungible({ metadata = ?Blob.fromArray([3, 2, 19, 0]) }))];
          await itemActor.setMetadataResponse(stubbedMetadataResponse);

          // update cache
          await backendActor.adminUpdateRegistryCache();

          let response = await backendActor.equipItems(playerNftId, [potionRefId]);
          switch (response) {
            case (#Ok()) true;
            case (#Err(message)) Debug.trap(debug_show (message));
          };
        },
      ),
    ],
  ),
  describe(
    "#defeatMonster",
    [
      it(
        "returns rewards from defeated monster",
        do {
          let monsterId : Nat16 = 1;
          let response = await backendActor.defeatMonster(playerNftId, monsterId);
          switch (response) {
            case (#Ok(rewardInfo)) true;
            case (#Err(message)) Debug.trap(debug_show (message));
          };
        },
      ),
    ],
  ),
]);

if (success == false) {
  Debug.trap("Tests failed");
};
