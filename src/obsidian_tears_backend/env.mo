import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

module {
  public let network = "local"; // ic, local, staging, beta

  public func getItemCanisterId() : Text {
    if (network == "ic") return "goei2-daaaa-aaaao-aaiua-cai";
    if (network == "staging") return "bavpk-lyaaa-aaaan-qc7bq-cai";
    if (network == "beta") return "7tscg-xaaaa-aaaan-qdasa-cai";

    // else local
    return "b77ix-eeaaa-aaaaa-qaada-cai";
  };

  public func getCharacterCanisterId() : Text {
    if (network == "ic") return "dhyds-jaaaa-aaaao-aaiia-cai";
    if (network == "staging") return "bhuj6-gaaaa-aaaan-qc7ba-cai";
    if (network == "beta") return "7gvtl-wiaaa-aaaan-qdarq-cai";

    // else "local"
    return "br5f7-7uaaa-aaaaa-qaaca-cai";
  };

  public func getAdminPrincipals() : [Text] {
    if (network == "ic") return ["6ulqo-ikasf-xzltp-ylrhu-qt4gt-nv4rz-gd46e-nagoe-3bo7b-kbm3h-bqe"]; // obsidian production principal
    if (network == "staging") return ["4e6g2-eoooo-h2lec-3h725-hvmmc-fvgsd-qakd3-qsj44-6dlaw-p5ngz-mae"];
    if (network == "beta") return ["4e6g2-eoooo-h2lec-3h725-hvmmc-fvgsd-qakd3-qsj44-6dlaw-p5ngz-mae"];

    // else "local"
    return [
      "4e6g2-eoooo-h2lec-3h725-hvmmc-fvgsd-qakd3-qsj44-6dlaw-p5ngz-mae",
      "heq22-7v76v-gwzlq-hl5da-czgby-ghdql-sas4k-ii2tr-voaep-amcsi-tqe",
    ]; // tiago and gastao's dev principals
  };

  public func isAdmin(caller : Principal) : Bool {
    let minters : [Text] = getAdminPrincipals();
    let callerText = Principal.toText(caller);

    return Array.indexOf<Text>(callerText, minters, Text.equal) != null;
  };
};
