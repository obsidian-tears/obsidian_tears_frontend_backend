import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";

import AID "../util/AccountIdentifier";
import CRC32 "../util/CRC32";
import Hex "../util/Hex";

module ExtCore = {
  public type AccountIdentifier = AID.AccountIdentifier;
  public type SubAccount = AID.SubAccount;
  public type User = {
    #address : AccountIdentifier; //No notification
    #principal : Principal; //defaults to sub account 0
  };
  public type Balance = Nat;
  public type TokenIdentifier = Text;
  public type TokenIndex = Nat32;
  public type TokenObj = {
    index : TokenIndex;
    canister : [Nat8];
  };
  public type Extension = Text;
  public type Memo = Blob;
  public type CommonError = {
    #InvalidToken : TokenIdentifier;
    #Other : Text;
  };
  public type BalanceRequest = {
    user : User;
    token : TokenIdentifier;
  };
  public type BalanceResponse = Result.Result<Balance, CommonError>;

  public type TransferRequest = {
    from : User;
    to : User;
    token : TokenIdentifier;
    amount : Balance;
    memo : Memo;
    notify : Bool;
    subaccount : ?SubAccount;
  };
  public type TransferResponse = Result.Result<Balance, { #Unauthorized : AccountIdentifier; #InsufficientBalance; #Rejected; /* Rejected by canister */ #InvalidToken : TokenIdentifier; #CannotNotify : AccountIdentifier; #Other : Text }>;
  public type NotifyCallback = shared (TokenIdentifier, User, Balance, Memo) -> async ?Balance;
  public type NotifyService = actor {
    tokenTransferNotification : NotifyCallback;
  };

  public type Service = actor {
    extensions : query () -> async [Extension];

    balance : query (request : BalanceRequest) -> async BalanceResponse;

    transfer : shared (request : TransferRequest) -> async TransferResponse;
  };

  public module TokenIndex = {
    public func equal(x : TokenIndex, y : TokenIndex) : Bool {
      return Nat32.equal(x, y);
    };
    public func hash(x : TokenIndex) : Hash.Hash {
      return x;
    };
  };

  public module TokenIdentifier = {
    private let tds : [Nat8] = [10, 116, 105, 100]; //b"\x0Atid"
    public let equal = Text.equal;
    public let hash = Text.hash;

    //Coz can't get principal directly, we can compare the bytes
    public func isPrincipal(tid : TokenIdentifier, p : Principal) : Bool {
      let tobj = decode(tid);
      return Blob.equal(Blob.fromArray(tobj.canister), Principal.toBlob(p));
    };
    public func getIndex(tid : TokenIdentifier) : TokenIndex {
      let tobj = decode(tid);
      tobj.index;
    };
    public func decode(tid : TokenIdentifier) : TokenObj {
      let bytes = Blob.toArray(Principal.toBlob(Principal.fromText(tid)));
      var index : Nat8 = 0;
      var _canister : [Nat8] = [];
      var _token_index : [Nat8] = [];
      var _tdscheck : [Nat8] = [];
      var length : Nat8 = 0;
      var tempBuffer = Buffer.Buffer<Nat8>(0);

      for (b in bytes.vals()) {
        length += 1;
        if (length <= 4) {
          tempBuffer := Buffer.fromArray(_tdscheck);
          tempBuffer.add(b);
          _tdscheck := Buffer.toArray(tempBuffer);
        };
        if (length == 4) {
          if (Array.equal(_tdscheck, tds, Nat8.equal) == false) {
            return {
              index = 0;
              canister = bytes;
            };
          };
        };
      };
      for (b in bytes.vals()) {
        index += 1;
        if (index >= 5) {
          if (index <= (length - 4)) {
            tempBuffer := Buffer.fromArray(_canister);
            tempBuffer.add(b);
            _canister := Buffer.toArray(tempBuffer);
          } else {
            tempBuffer := Buffer.fromArray(_token_index);
            tempBuffer.add(b);
            _token_index := Buffer.toArray(tempBuffer);
          };
        };
      };
      let v : TokenObj = {
        index = bytestonat32(_token_index);
        canister = _canister;
      };
      return v;
    };

    private func bytestonat32(b : [Nat8]) : Nat32 {
      var index : Nat32 = 0;
      Array.foldRight<Nat8, Nat32>(
        b,
        0,
        func(u8, accum) {
          index += 1;
          accum + Nat32.fromNat(Nat8.toNat(u8)) << ((index -1) * 8);
        },
      );
    };
  };

  public module User = {
    public func toAID(user : User) : AccountIdentifier {
      switch (user) {
        case (#address address) address;
        case (#principal principal) {
          AID.fromPrincipal(principal, null);
        };
      };
    };
    public func toPrincipal(user : User) : ?Principal {
      switch (user) {
        case (#address address) null;
        case (#principal principal) ?principal;
      };
    };
    public func equal(x : User, y : User) : Bool {
      let _x = switch (x) {
        case (#address address) address;
        case (#principal principal) {
          AID.fromPrincipal(principal, null);
        };
      };
      let _y = switch (y) {
        case (#address address) address;
        case (#principal principal) {
          AID.fromPrincipal(principal, null);
        };
      };
      return AID.equal(_x, _y);
    };
    public func hash(x : User) : Hash.Hash {
      let _x = switch (x) {
        case (#address address) address;
        case (#principal principal) {
          AID.fromPrincipal(principal, null);
        };
      };
      return AID.hash(_x);
    };
  };
};
