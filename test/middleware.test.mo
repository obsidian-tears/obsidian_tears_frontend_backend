import Time "mo:base/Time";
import Map "mo:map/Map";
import { expect; suite; test } "mo:test/async";

import Middleware "../src/obsidian_tears_backend/middleware";
import T "../src/obsidian_tears_backend/types";

// create registry with one element
let authToken : Text = "abc123";
let authToken2 : Text = "abc1234";
let playerNftId : Nat32 = 1;
let playerNftId2 : Nat32 = 2;
let dayAgo : Time.Time = Time.now() - 25 * 60 * 60 * 1000000000; // 25 hours ago in nanoseconds
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
        Map.set<Text, T.TokenWithTimestamp>(authTokenRegistry, Map.thash, authToken, (playerNftId, dayAgo));
        let response = Middleware.hasValidToken(playerNftId, authToken, authTokenRegistry);
        expect.bool(response).isFalse();
      },
    );
  },
);

await suite(
  "#authTokenRegistryIsClean",
  func() : async () {
    await test(
      "when cleaner is run old tokens are removed",
      func() : async () {
        Map.clear(authTokenRegistry);
        Map.set<Text, T.TokenWithTimestamp>(authTokenRegistry, Map.thash, authToken, (playerNftId, Time.now()));
        Map.set<Text, T.TokenWithTimestamp>(authTokenRegistry, Map.thash, authToken2, (playerNftId2, dayAgo));

        let initialRegistrySize = Map.size(authTokenRegistry);
        expect.nat(initialRegistrySize).equal(2);

        Middleware.cleanAuthTokenRegistry(authTokenRegistry);

        let finalRegistrySize = Map.size(authTokenRegistry);
        let onlyElement = Map.has(authTokenRegistry, Map.thash, authToken);
        expect.nat(finalRegistrySize).equal(1);
        expect.bool(onlyElement).isTrue();
      },
    );
  },
);
