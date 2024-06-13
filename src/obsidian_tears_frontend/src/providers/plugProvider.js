import { Actor } from "@dfinity/agent";
import { canisterId as backendCanisterId } from "../../../declarations/obsidian_tears_backend";
import { idlFactory as backendIdlFactory } from "../../../declarations/obsidian_tears_backend/obsidian_tears_backend.did.js";
import { characterIdlFactory } from "../../idl_factories/characterIdlFactory.did";
import { characterCanisterId, network } from "../env";
import { PlugMobileProvider } from "@funded-labs/plug-mobile-sdk";

const WHITELIST = [backendCanisterId, characterCanisterId];

export const connectToPlug = async (saveLogin, saveActors) => {
  const plug = window.ic.plug;

  const host =
    network === "local" ? "http://127.0.0.1:4943/" : "https://icp0.io";
  await plug.requestConnect({ WHITELIST, host });

  // handle if timeout / not allowed
  if (!(await plug.isConnected())) return;

  if (network === "local") {
    plug.agent.fetchRootKey();
  }

  const gameActor = Actor.createActor(backendIdlFactory, {
    agent: plug.agent,
    canisterId: backendCanisterId,
  });
  const charActor = Actor.createActor(characterIdlFactory, {
    agent: plug.agent,
    canisterId: characterCanisterId,
  });

  saveActors(gameActor, charActor);
  saveLogin("plug", plug.principalId);
};

export const connectToPlugMobile = async () => {
  console.log("start");
  const provider = new PlugMobileProvider({
    debug: true,
    walletConnectProjectId: "6829ff2dda2dbd53d98341bedaabdb9c",
    window: window,
  });
  console.log("finished new Provider");
  await provider.initialize().catch(console.log);
  console.log("finished initialize");
  if (!provider.isPaired()) {
    await provider.pair().catch(console.log);
    console.log("finished not paired");
  }

  const agent = await provider.createAgent({
    host: "https://icp0.io",
    targets: WHITELIST,
  });
  console.log("finished createAgent");
  const gameActor = Actor.createActor(backendIdlFactory, {
    agent: agent,
    canisterId: backendCanisterId,
  });
  console.log("finished backend actor");
  const charActor = Actor.createActor(characterIdlFactory, {
    agent: agent,
    canisterId: characterCanisterId,
  });
  console.log("finished char actor");
  saveActors(gameActor, charActor);
  saveLogin("plug", provider.localIdentity);
  console.log("finished method");
};
