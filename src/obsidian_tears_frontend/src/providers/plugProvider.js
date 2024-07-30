import { Actor, HttpAgent } from "@dfinity/agent";
import { canisterId as backendCanisterId } from "../../../declarations/obsidian_tears_backend";
import { idlFactory as backendIdlFactory } from "../../../declarations/obsidian_tears_backend/obsidian_tears_backend.did.js";
import { characterIdlFactory } from "../../idl_factories/characterIdlFactory.did";
import { characterCanisterId, network } from "../env";

export const connectToPlug = async (saveLogin, saveActors) => {
  const plug = window.ic.plug;

  const host =
    network === "local" ? "http://127.0.0.1:4943/" : "https://icp0.io";
  const whitelist = [backendCanisterId, characterCanisterId];
  await plug.requestConnect({ whitelist, host });

  // handle if timeout / not allowed
  if (!(await window.ic.plug.isConnected())) return;

  // extract the original agent
  let agent = plug.agent.agent;

  if (network === "local") {
    agent.fetchRootKey();
  }

  const gameActor = Actor.createActor(backendIdlFactory, {
    agent: agent,
    canisterId: backendCanisterId,
  });
  const charActor = Actor.createActor(characterIdlFactory, {
    agent: agent,
    canisterId: characterCanisterId,
  });

  saveActors(gameActor, charActor);
  saveLogin("plug", plug.principalId);
};
