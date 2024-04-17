import {
  canisterId as backendCanisterId,
  createActor as backendCreateActor,
} from "../../../declarations/obsidian_tears_backend";
import { characterIdlFactory } from "../../idl_factories/characterIdlFactory.did";
import { characterCanisterId, network } from "../env";

export const connectToPlug = async (saveLogin, saveActors) => {
  const plug = window.ic.plug;

  const host =
    network === "local"
      ? "http://127.0.0.1:4943/"
      : "https://mainnet.dfinity.network";
  const whitelist = [backendCanisterId, characterCanisterId];
  await plug.requestConnect({ whitelist, host });

  // handle if timeout / not allowed
  if (!(await window.ic.plug.isConnected())) return;

  const gameActor = backendCreateActor(backendCanisterId, {
    agent: plug.agent,
  });
  const charActor = await plug.createActor({
    canisterId: characterCanisterId,
    interfaceFactory: characterIdlFactory,
  });
  saveActors(gameActor, charActor);
  saveLogin("plug", { plug_principal: plug.principalId });
};
