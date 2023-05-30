import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import ExtCore "../../src/obsidian_tears_backend/ext/Core";
import ExtCommon "../../src/obsidian_tears_backend/ext/Common";
import T "../../src/obsidian_tears_backend/types";

actor class ItemActor() {
  public type RegistryResponse = [(ExtCore.TokenIndex, ExtCore.AccountIdentifier)];
  var registryResponse : RegistryResponse = [];

  public type MetadataResponse = [(ExtCore.TokenIndex, ExtCommon.Metadata)];
  var metadataResponse : MetadataResponse = [];

  public query func getRegistry() : async RegistryResponse {
    return registryResponse;
  };

  public func setRegistryResponse(response : RegistryResponse) : async () {
    registryResponse := response;
  };

  public query func getMetadata() : async MetadataResponse {
    return metadataResponse;
  };

  public func setMetadataResponse(response : MetadataResponse) : async () {
    metadataResponse := response;
  };

  // MINTING MOCK CODE

  let registry = HashMap.HashMap<ExtCore.TokenIndex, ExtCore.AccountIdentifier>(0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
  var nextTokenId : ExtCore.TokenIndex = 0;

  public func mintItem(data : [Nat8], recipient : ExtCore.AccountIdentifier) : async () {
    registry.put(nextTokenId, recipient);
    nextTokenId += 1;

    return ();
  };
};
