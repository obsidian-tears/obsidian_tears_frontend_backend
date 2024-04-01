import Time "mo:base/Time";
import Map "mo:map/Map";
import { expect; suite; test } "mo:test/async";

import Middleware "../src/obsidian_tears_backend/middleware";
import T "../src/obsidian_tears_backend/types";

// create registry with one element
let authToken : Text = "abc123";
let playerNftId : Nat32 = 2;
var authTokenRegistry : Map.Map<Text, T.TokenWithTimestamp> = Map.new<Text, T.TokenWithTimestamp>();

await suite(
  "#hasValidToken",
  func() : async () {
    await test(
      "when authToken is valid returns true",
      func() : async () {
        Map.set<Text, T.TokenWithTimestamp>(authTokenRegistry, Map.thash, authToken, (playerNftId, Time.now()));
        let response = Middleware.hasValidToken(playerNftId, authToken, authTokenRegistry);
        expect.bool(response).isTrue();
      },
    );
    await test(
      "when authToken is not valid returns false",
      func() : async () {
        var response = Middleware.hasValidToken(playerNftId, "", authTokenRegistry);
        expect.bool(response).isFalse();

        response := Middleware.hasValidToken(9, authToken, authTokenRegistry);
        expect.bool(response).isFalse();
      },
    );
    await test(
      "when authToken has expired returns false",
      func() : async () {
        let dayAgo : Time.Time = Time.now() - 90000000000000; // 25 hours ago in nanoseconds
        Map.set<Text, T.TokenWithTimestamp>(authTokenRegistry, Map.thash, authToken, (playerNftId, dayAgo));
        let response = Middleware.hasValidToken(playerNftId, authToken, authTokenRegistry);
        expect.bool(response).isFalse();
      },
    );
  },
);
