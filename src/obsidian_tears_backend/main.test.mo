import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Blob "mo:base/Blob";

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
import ExtCore "ext/Core";
import ExtCommon "ext/Common";
import CharacterActor "../../spec/actors/CharacterActor";
import ItemActor "../../spec/actors/ItemActor";
import GameJsonFactory "../../spec/factories/GameJsonFactory";
import Option "mo:base/Option";
import Text "mo:base/Text";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";

let backendActor = await Main.ObsidianTearsBackend();

// ==================
// setup
// ==================

// stubbed actors
let characterActor = await CharacterActor.CharacterActor();
let characterActorId = Principal.toText(Principal.fromActor(characterActor));
let itemActor = await ItemActor.ItemActor();
let itemActorId = Principal.toText(Principal.fromActor(itemActor));
ignore await backendActor.adminSetStubbedCanisterIds(characterActorId, itemActorId);

// set default character nfts
let defaultTokensResponse : Result.Result<[ExtCore.TokenIndex], ExtCore.CommonError> = #ok([1, 2, 3, 4]);
await characterActor.setTokensResponse(defaultTokensResponse);

// vars
var playerNftId : Nat32 = 2;
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
            case (#Ok(gameData)) assertTrue(Text.size(gameData) > 12900);
            case (#Err(_message)) false;
          };
        },
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
          let address : ExtCore.AccountIdentifier = "8ee8481915a2e00843289d5f0682509cba078f9c0664ca086cecbf28d022277c";
          let stubbedResponse : [(ExtCore.TokenIndex, ExtCore.AccountIdentifier)] = [(potionTokenIndex, address)];
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
