import { NFID } from "@nfid/embed";
import { Actor, HttpAgent } from "@dfinity/agent";
import {
  canisterId as backendCanisterId,
  createActor as backendCreateActor,
} from "../../../declarations/obsidian_tears_backend";
import { characterIdlFactory } from "../../idl_factories/characterIdlFactory.did";
import { characterCanisterId, network } from "../env";

export const connectToNFID = async (saveLogin, saveActors) => {
  const nfid = await NFID.init({
    application: {
      name: "Obsidian Tears",
      logo: "https://staging.obsidiantears.xyz/header-logo.png",
    },
  });

  const delegationIdentity = await nfid.getDelegation({
    // Only for custom domain
    derivationOrigin:
      network === "local"
        ? undefined
        : "https://boxcc-qiaaa-aaaan-qc7aq-cai.ic0.app",

    // 8 hours in nanoseconds
    maxTimeToLive: BigInt(8) * BigInt(3_600_000_000_000),
  });

  let agent = new HttpAgent({ identity: delegationIdentity });
  if (network === "local") {
    agent.fetchRootKey();
  }

  let gameActor = backendCreateActor(backendCanisterId, { agent: agent });
  let charActor = Actor.createActor(characterIdlFactory, {
    agent: agent,
    canisterId: characterCanisterId,
  });

  saveLogin("nfid", delegationIdentity.getPrincipal().toText());
  saveActors(gameActor, charActor);
};
