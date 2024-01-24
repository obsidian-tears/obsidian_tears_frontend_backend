/**
Generates AccountIdentifier's for the IC (32 bytes). Use with
hex library to generate corresponding hex address.
Uses custom SHA224 and CRC32 motoko libraries
 */

import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import SHA224 "./SHA224";
import CRC32 "./CRC32";
import Hex "./Hex";

module {
  public type AccountIdentifier = Text;
  public type SubAccount = [Nat8];

  private let ads : [Nat8] = [10, 97, 99, 99, 111, 117, 110, 116, 45, 105, 100]; //b"\x0Aaccount-id"
  public let SUBACCOUNT_ZERO : [Nat8] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  //Public functions
  public func fromText(t : Text, sa : ?SubAccount) : AccountIdentifier {
    return fromPrincipal(Principal.fromText(t), sa);
  };
  public func fromPrincipal(p : Principal, sa : ?SubAccount) : AccountIdentifier {
    return fromBlob(Principal.toBlob(p), sa);
  };
  public func fromBlob(b : Blob, sa : ?SubAccount) : AccountIdentifier {
    return fromBytes(Blob.toArray(b), sa);
  };
  public func fromBytes(data : [Nat8], sa : ?SubAccount) : AccountIdentifier {
    let _sa = switch (sa) {
      case (?sa) sa;
      case (null) SUBACCOUNT_ZERO;
    };
    var tempBuffer = Buffer.fromArray<Nat8>(ads);
    tempBuffer.append(Buffer.fromArray<Nat8>(data));
    tempBuffer.append(Buffer.fromArray<Nat8>(_sa));
    var hash : [Nat8] = SHA224.sha224(Buffer.toArray(tempBuffer));
    var crc : [Nat8] = CRC32.crc32(hash);
    tempBuffer := Buffer.fromArray<Nat8>(crc);
    tempBuffer.append(Buffer.fromArray<Nat8>(hash));
    return Hex.encode(Buffer.toArray(tempBuffer));
  };

  public let equal = Text.equal;
  public let hash = Text.hash;
};
