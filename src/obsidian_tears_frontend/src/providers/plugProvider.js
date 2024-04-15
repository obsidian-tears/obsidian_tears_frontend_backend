import {
  canisterId as backendCanisterId,
  createActor as backendCreateActor,
} from "../../../declarations/obsidian_tears_backend";
import { characterIdlFactory } from "../../idl_factories/characterIdlFactory.did";
import { characterCanisterId, network } from "../env";

export const connectToPlug = async (saveLogin, saveActors) => {
  const plug = window.ic.plug;

  const whitelist = [backendCanisterId, characterCanisterId];
  let publicKey = await plug.requestConnect({ whitelist });

  // handle if timeout / not allowed
  if (!(await window.ic.plug.isConnected())) return;

  const principal = plug.principalId;
  const agent = plug.agent;
  console.log(principal);

  let gameActor = backendCreateActor(backendCanisterId, {
    agent: agent,
  });
  let charActor = await plug.createActor({
    canisterId: characterCanisterId,
    interfaceFactory: characterIdlFactory,
  });

  saveActors(gameActor, charActor);
  saveLogin("plug", principal);
};
