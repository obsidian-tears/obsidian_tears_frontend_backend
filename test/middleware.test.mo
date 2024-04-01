import Time "mo:base/Time";
import Map "mo:map/Map";
import { thash } "mo:map/Map";
import { expect; suite; test } "mo:test/async";

import Middleware "../src/obsidian_tears_backend/middleware";
import T "../src/obsidian_tears_backend/types";

// create registry with one element
let authToken : Text = "abc123";
let playerNftId : Nat32 = 2;
let currentTime : Time.Time = Time.now();
var authTokenRegistry : Map.Map<Text, T.TokenWithTimestamp> = Map.new<Text, T.TokenWithTimestamp>();
Map.set<Text, T.TokenWithTimestamp>(authTokenRegistry, thash, authToken, (playerNftId, currentTime));

await suite(
  "#hasValidToken",
  func() : async () {
    await test(
      "when authToken is valid returns true",
      func() : async () {
        let response = Middleware.hasValidToken(playerNftId, authToken, authTokenRegistry);
        expect.bool(response).isTrue();
      },
    );
    await test(
      "when authToken is not valid returns false",
      func() : async () {
        let response = Middleware.hasValidToken(playerNftId, "", authTokenRegistry);
        expect.bool(response).isFalse();
      },
    );
  },
);
