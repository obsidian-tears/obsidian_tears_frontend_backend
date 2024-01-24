import Blob "mo:base/Blob";
import Time "mo:base/Time";
import Result "mo:base/Result";

import ExtCore "lib/ext/Core";
import ExtCommon "lib/ext/Common";

module {
  //   \"characterName\":\"Phendrin\",\"characterClass\":\"\",\"level\":1,\"xp\":0,\"xpToLevelUp\":75,
  //   \"pointsRemaining\":0,\"healthBase\":15,\"healthTotal\":15,\"healthMax\":15,\"magicBase\":10,\"magicTotal\":10,
  //   \"magicMax\":10,\"attackBase\":5,\"attackTotal\":5,\"magicPowerBase\":0,\"magicPowerTotal\":0,\"defenseBase\":5,
  //   \"defenseTotal\":5,\"speedBase\":5,\"speedTotal\":5,\"criticalHitProbability\":0.0,\"characterEffects\":[]
  public type PlayerData = {
    characterName : Text;
    characterClass : Text;
    level : Nat16;
    xp : Nat32;
    xpToLevelUp : Nat32;
    pointsRemaining : Nat32;
    healthBase : Nat16;
    healthTotal : Nat16;
    healthMax : Nat16;
    magicBase : Nat16;
    magicTotal : Nat16;
    magicMax : Nat16;
    attackBase : Nat16;
    attackTotal : Nat16;
    defenseBase : Nat16;
    defenseTotal : Nat16;
    speedBase : Nat16;
    speedTotal : Nat16;
    criticalHitProbability : Float;
    characterEffects : [Text];
    kills : Nat16;
    deaths : Nat16;
  };

  public type RewardInfo = {
    itemIds : [Text];
    gold : Nat32;
    xp : Nat32;
  };

  // Actor Interfaces
  public type CharacterInterface = actor {
    getRegistry : query () -> async [(ExtCore.TokenIndex, ExtCore.AccountIdentifier)];
    tokens : query (aid : ExtCore.AccountIdentifier) -> async Result.Result<[ExtCore.TokenIndex], ExtCore.CommonError>;
  };

  public type ItemInterface = actor {
    getRegistry : query () -> async [(ExtCore.TokenIndex, ExtCore.AccountIdentifier)];
    getMetadata : query () -> async [(ExtCore.TokenIndex, ExtCommon.Metadata)];
    mintItem : (data : [Nat8], recipient : ExtCore.AccountIdentifier) -> async ();
    tokens : query (aid : ExtCore.AccountIdentifier) -> async Result.Result<[ExtCore.TokenIndex], ExtCore.CommonError>;
  };

  // Responses
  public type ApiResponse<T> = {
    #Ok : T;
    #Err : ApiError;
  };
  public type ApiError = {
    #Unauthorized;
    #Limit;
    #Other : Text;
  };

  // HTTP
  public type HeaderField = (Text, Text);
  public type HttpResponse = {
    status_code : Nat16;
    headers : [HeaderField];
    body : Blob;
    streaming_strategy : ?HttpStreamingStrategy;
  };
  public type HttpRequest = {
    method : Text;
    url : Text;
    headers : [HeaderField];
    body : Blob;
  };
  public type HttpStreamingCallbackToken = {
    content_encoding : Text;
    index : Nat;
    key : Text;
    sha256 : ?Blob;
  };

  public type HttpStreamingStrategy = {
    #Callback : {
      callback : query (HttpStreamingCallbackToken) -> async (HttpStreamingCallbackResponse);
      token : HttpStreamingCallbackToken;
    };
  };

  public type HttpStreamingCallbackResponse = {
    body : Blob;
    token : ?HttpStreamingCallbackToken;
  };
};
