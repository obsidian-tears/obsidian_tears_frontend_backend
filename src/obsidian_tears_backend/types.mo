import Blob "mo:base/Blob";
import Time "mo:base/Time";

module {
  public type RewardInfo = {
    itemIds : [Text];
    gold : Nat32;
    xp : Nat32;
  };

  public type SessionData = {
    createdAt : Time.Time;
    goldEarned : Nat32;
    xpEarned : Nat32;
    itemsEarned : Nat8;
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
