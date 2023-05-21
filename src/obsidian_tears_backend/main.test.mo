import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
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
import CharacterActor "../../spec/actors/CharacterActor";
import ItemActor "../../spec/actors/ItemActor";
import GameJsonFactory "../../spec/factories/GameJsonFactory";
import Option "mo:base/Option";
import Text "mo:base/Text";
import Nat16 "mo:base/Nat16";

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
    "#consumeItem",
    [
      it(
        "unequips and burns item",
        do {
          let response = await backendActor.consumeItem(playerNftId, itemId);
          switch (response) {
            case (#Ok()) true;
            case (#Err(_message)) false;
          };
        },
      ),
    ],
  ),

]);

if (success == false) {
  Debug.trap("Tests failed");
};
