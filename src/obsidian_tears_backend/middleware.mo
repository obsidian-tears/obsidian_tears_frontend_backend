import Time "mo:base/Time";
import Map "mo:map/Map";
import { thash } "mo:map/Map";

import ExtCore "lib/ext/Core";

module Middleware {
  type TokenIndex = ExtCore.TokenIndex;
  type TokenWithTimestamp = ExtCore.TokenWithTimestamp;
  type Time = ExtCore.Time;

  let fullDay : Time = 86400000000000;

  public func hasValidToken(index : TokenIndex, authToken : Text, registry : Map.Map<Text, TokenWithTimestamp>) : Bool {
    let optTokenWithTimestamp : ?TokenWithTimestamp = Map.get<Text, TokenWithTimestamp>(registry, thash, authToken);
    switch (optTokenWithTimestamp) {
      case (?tokenWithTimestamp) {
        let tokenIndex : TokenIndex = tokenWithTimestamp.0;
        let timestamp : Time = tokenWithTimestamp.1;
        let currentTime : Time = Time.now();

        return (tokenIndex == index) and ((timestamp + fullDay) > currentTime);
      };
      case (null) return false;
    };
  };
};
