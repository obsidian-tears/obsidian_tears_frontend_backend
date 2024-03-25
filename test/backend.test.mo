import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";

import {
  test;
} "mo:test";

import Main "../src/obsidian_tears_backend/main";
import T "../src/obsidian_tears_backend/types";
import ExtCore "../src/obsidian_tears_backend/lib/ext/Core";
import ExtCommon "../src/obsidian_tears_backend/lib/ext/Common";
import CharacterActor "../spec/actors/CharacterActor";
import ItemActor "../spec/actors/ItemActor";
import GameJsonFactory "../spec/factories/GameJsonFactory";
import AID "../src/obsidian_tears_backend/lib/util/AccountIdentifier";

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
var itemId : Nat16 = 35;
var shopId : Nat16 = 0;
