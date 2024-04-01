import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import { expect; suite; test } "mo:test/async";

import CharacterActor "../spec/actors/CharacterActor";
import ItemActor "../spec/actors/ItemActor";
import GameJsonFactory "../spec/factories/GameJsonFactory";
import ExtCommon "../src/obsidian_tears_backend/lib/ext/Common";
import ExtCore "../src/obsidian_tears_backend/lib/ext/Core";
import AID "../src/obsidian_tears_backend/lib/util/AccountIdentifier";
import Main "../src/obsidian_tears_backend/main";
import T "../src/obsidian_tears_backend/types";

let backendActor = await Main._ObsidianTearsBackend();

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
var authToken : Text = "";

await suite(
  "#verify",
  func() : async () {
    await test(
      "should return list of NFTs owned",
      func() : async () {
        let response = await backendActor.verify();
        assert response == #Ok([1, 2, 3, 4]);
      },
    );
    await test(
      "should update registery cache of Characters owned",
      func() : async () {
        func show(a : Result.Result<(ExtCore.AccountIdentifier), Text>) : Text = debug_show (a);
        func equal(a : Result.Result<(ExtCore.AccountIdentifier), Text>, b : Result.Result<(ExtCore.AccountIdentifier), Text>) : Bool = a == b;

        let ownerId = await backendActor.specGetCharacterOwner(playerNftId);
        expect.result<(ExtCore.AccountIdentifier), Text>(ownerId, show, equal).equal(#ok(selfAddress));
      },
    );
    await test(
      "should update registry cache of Items owned",
      func() : async () {
        func show(a : Result.Result<(ExtCore.AccountIdentifier), Text>) : Text = debug_show (a);
        func equal(a : Result.Result<(ExtCore.AccountIdentifier), Text>, b : Result.Result<(ExtCore.AccountIdentifier), Text>) : Bool = a == b;

        let ownerId = await backendActor.specGetItemOwner(itemNftIndex);
        expect.result<(ExtCore.AccountIdentifier), Text>(ownerId, show, equal).equal(#ok(selfAddress));
      },
    );
  },
);
await suite(
  "#getAuthToken",
  func() : async () {
    await test(
      "if character is owned, should return an authToken and store in registry",
      func() : async () {
        let result = await backendActor.getAuthToken(playerNftId);
        authToken := switch (result) {
          case (#ok authToken) authToken;
          case (#err e) Debug.trap("Did not retrieve token. Error: " # e);
        };
        expect.nat(Text.size(authToken)).equal(40);

        let authTokenSize = await backendActor.specGetState("authTokenSize");
        expect.text(authTokenSize).equal("1");
      },
    );
    await test(
      "if character is NOT owned, should return error",
      func() : async () {
        let result = await backendActor.getAuthToken(9876);
        expect.bool(Result.isErr(result)).equal(true);
      },
    );
  },
);
await suite(
  "#loadGame",
  func() : async () {
    await test(
      "when no game saved, returns error with message",
      func() : async () {
        let response = await backendActor.loadGame(playerNftId, authToken);
        assert response == #Err(#Other("No save data"));
      },
    );
    await test(
      "when game saved, returns game successfully",
      func() : async () {
        // before
        ignore await backendActor.saveGame(playerNftId, gameData, authToken);

        // assert
        let response = await backendActor.loadGame(playerNftId, authToken);

        // after
        ignore await backendActor.saveGame(playerNftId, "", authToken);

        switch (response) {
          case (#Ok(gameData)) assert (Text.size(gameData) > 12900);
          case (#Err(_message)) assert false;
        };
      },
    );
  },
);
await suite(
  "#saveGame",
  func() : async () {
    await test(
      "saves and returns the load game output to be rendered",
      func() : async () {
        let response = await backendActor.saveGame(playerNftId, gameData, authToken);
        switch (response) {
          case (#Ok(gameData)) {
            assert (Text.size(gameData) > 12900);
          };
          case (#Err(_message)) assert false;
        };
      },
    );
  },
);
await suite(
  "#openChest",
  func() : async () {
    await test(
      "mints items and adds gold",
      func() : async () {
        let expectedRewardInfo : T.RewardInfo = {
          itemIds = ["4290235510"];
          gold = 20;
          xp = 0;
        };
        let response = await backendActor.openChest(playerNftId, chestId, authToken);
        switch (response) {
          case (#Ok(rewardInfo)) assert (rewardInfo == expectedRewardInfo);
          case (#Err(_message)) assert false;
        };
      },
    );
  },
);
await suite(
  "#defeatMonster",
  func() : async () {
    await test(
      "returns rewards from defeated monster",
      func() : async () {
        let monsterId : Nat16 = 1;
        let response = await backendActor.defeatMonster(playerNftId, monsterId, authToken);
        switch (response) {
          case (#Ok(rewardInfo)) assert true;
          case (#Err(message)) Debug.trap(debug_show (message));
        };
      },
    );
  },
);
