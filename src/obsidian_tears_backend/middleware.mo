import HashMap "mo:base/HashMap";
import ExtCore "lib/ext/Core";
import AID "lib/util/AccountIdentifier";

module Middleware {
  public func isOwner(caller : Principal, index : ExtCore.TokenIndex, registry : HashMap.HashMap<ExtCore.TokenIndex, ExtCore.AccountIdentifier>) : Bool {
    let ownerId = registry.get(index);
    let address : ExtCore.AccountIdentifier = AID.fromPrincipal(caller, null);

    ownerId == ?address;
  };
};
