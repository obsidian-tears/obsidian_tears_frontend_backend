import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import {
  assertTrue;
  describe;
  context;
  it;
  run;
} "mo:mospec/MoSpec";

import Main "main";
import T "types";
import ExtCore "ext/Core";
import CharacterActor "../../spec/actors/CharacterActor";

let backendActor = await Main.ObsidianTearsBackend();

// setup
// stubbed actors
let characterActor = await CharacterActor.CharacterActor();
let characterId = Principal.toText(Principal.fromActor(characterActor));
ignore await backendActor.setStubbedCanisterIds(characterId, "");

// set default character nfts
let defaultTokensResponse : Result.Result<[ExtCore.TokenIndex], ExtCore.CommonError> = #ok([1, 2, 3, 4]);
await characterActor.setTokensResponse(defaultTokensResponse);

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
    "#checkIn",
    [
      it(
        "should greet me",
        do {
          let response = await backendActor.checkIn();
          assertTrue(response == ());
        },
      ),
    ],
  ),
]);

if (success == false) {
  Debug.trap("Tests failed");
};
