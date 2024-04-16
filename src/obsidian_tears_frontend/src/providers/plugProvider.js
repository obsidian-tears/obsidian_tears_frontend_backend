import {
  canisterId as backendCanisterId,
  createActor as backendCreateActor,
} from "../../../declarations/obsidian_tears_backend";
import { characterIdlFactory } from "../../idl_factories/characterIdlFactory.did";
import { characterCanisterId } from "../env";
import { PlugMobileProvider } from "@funded-labs/plug-mobile-sdk";

const whitelist = [backendCanisterId, characterCanisterId];

export const connectToPlug = async (saveLogin, saveActors) => {
  const plug = window.ic.plug;

  await plug.requestConnect({ whitelist });

  // handle if timeout / not allowed
  if (!(await plug.isConnected())) return;

  const gameActor = backendCreateActor(backendCanisterId, {
    agent: plug.agent,
  });
  const charActor = await plug.createActor({
    canisterId: characterCanisterId,
    interfaceFactory: characterIdlFactory,
  });

  saveActors(gameActor, charActor);
  saveLogin("plug", plug.principalId);
};

export const connectToPlugMobile = async () => {
  const provider = new PlugMobileProvider({
    debug: true,
    walletConnectProjectId: "6829ff2dda2dbd53d98341bedaabdb9c",
    window: window,
  });

  await provider.initialize();

  if (!provider.isPaired()) {
    await provider.pair().catch(console.log);
  }

  const agent = await provider.createAgent({
    host: "https://icp0.io",
    targets: whitelist,
  });

  const gameActor = backendCreateActor(backendCanisterId, { agent });

  const charActor = Actor.createActor(characterIdlFactory, {
    agent: agent,
    canisterId: characterCanisterId,
  });

  saveActors(gameActor, charActor);
  saveLogin("plug", provider.localIdentity);
};
