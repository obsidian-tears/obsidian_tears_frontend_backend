import { characterIdlFactory } from "../../../idl_factories/characterIdlFactory.did";

export const canisters = {
  character: {
    canisterId: "dhyds-jaaaa-aaaao-aaiia-cai",
    // canisterId: "br5f7-7uaaa-aaaaa-qaaca-cai",
    idlFactory: characterIdlFactory,
  },
};

export const canisterIds = [
  "dhyds-jaaaa-aaaao-aaiia-cai", // character nft on mainet (ic)
  // "br5f7-7uaaa-aaaaa-qaaca-cai", // character nft on local
];
