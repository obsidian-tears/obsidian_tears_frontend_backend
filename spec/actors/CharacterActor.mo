import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import ExtCore "../../src/obsidian_tears_backend/lib/ext/Core";

actor class CharacterActor() {
  public type RegistryResponse = [(ExtCore.TokenIndex, ExtCore.AccountIdentifier)];
  var registryResponse : RegistryResponse = [];

  public type TokensResponse = Result.Result<[ExtCore.TokenIndex], ExtCore.CommonError>;
  var tokensResponse : Result.Result<[ExtCore.TokenIndex], ExtCore.CommonError> = #err(#Other("not set"));

  public query func getRegistry() : async RegistryResponse {
    return registryResponse;
  };

  public func setRegistryResponse(response : RegistryResponse) : async () {
    registryResponse := response;
  };

  public query func tokens(aid : ExtCore.AccountIdentifier) : async TokensResponse {
    return tokensResponse;
  };

  public func setTokensResponse(response : TokensResponse) : async () {
    tokensResponse := response;
  };
};
