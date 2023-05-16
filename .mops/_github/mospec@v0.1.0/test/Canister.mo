import T "Types";
import M "Module";

actor class Canister() {
  public query func greet(args : T.GreetArgs) : async Text {
    return M.greet(args);
  };
  public query func sum(args : T.SumArgs) : async Nat {
    return M.sum(args);
  };
};
