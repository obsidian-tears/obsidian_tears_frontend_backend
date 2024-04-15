import {
  canisterId as backendCanisterId,
  createActor as backendCreateActor,
} from "../../../declarations/obsidian_tears_backend";
import { characterIdlFactory } from "../../idl_factories/characterIdlFactory.did";
import { characterCanisterId } from "../env";

export const connectToPlug = async (saveLogin, saveActors) => {
  const plug = window.ic.plug;

  const whitelist = [backendCanisterId, characterCanisterId];
  await plug.requestConnect({ whitelist });

  // handle if timeout / not allowed
  if (!(await window.ic.plug.isConnected())) return;

  let gameActor = backendCreateActor(backendCanisterId, {
    agent: plug.agent,
  });
  let charActor = await plug.createActor({
    canisterId: characterCanisterId,
    interfaceFactory: characterIdlFactory,
  });

  saveActors(gameActor, charActor);
  saveLogin("plug", plug.principalId);
};
