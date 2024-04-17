import { Actor, HttpAgent } from "@dfinity/agent";
import { StoicIdentity } from "ic-stoic-identity";
import {
  canisterId as backendCanisterId,
  createActor as backendCreateActor,
} from "../../../declarations/obsidian_tears_backend";
import { characterIdlFactory } from "../../idl_factories/characterIdlFactory.did";
import { characterCanisterId, network } from "../env";

export const connectToStoic = async (saveLogin, saveActors) => {
  StoicIdentity.load().then(async () => {
    let identity = await StoicIdentity.connect();
    let agent = new HttpAgent({ identity: identity });
    if (network === "local") {
      agent.fetchRootKey();
    }

    let gameActor = backendCreateActor(backendCanisterId, { agent: agent });
    let charActor = Actor.createActor(characterIdlFactory, {
      agent: agent,
      canisterId: characterCanisterId,
    });

    saveLogin("stoic", { stoic_identity: identity });
    saveActors(gameActor, charActor);
  });
};
