import Blob "mo:base/Blob";

module {
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
