import {
  canisterId as backendCanisterId,
  createActor as backendCreateActor,
} from "../../../declarations/obsidian_tears_backend";
import { characterIdlFactory } from "../../idl_factories/characterIdlFactory.did";
import { itemIdlFactory } from "../../idl_factories/itemIdlFactory.did";
import { characterCanisterId, itemCanisterId, network } from "../env";
import { Actor, HttpAgent } from "@dfinity/agent";

export const connectToPlug = async (saveLogin, saveActors) => {
  const plug = window.ic.plug;
  const connected = await plug.isConnected();
  let publicKey;
  if (!connected) {
    publicKey = await plug.requestConnect();
  }

  console.log(publicKey);
  const principal = await plug.getPrincipal();
  console.log(principal);
  let agent = plug.agent;
  if (!agent) agent = await plug.createAgent();

  let gameActor = backendCreateActor(backendCanisterId, {
    agent: plug.agent,
  });
  let charActor = await plug.createActor({
    canisterId: characterCanisterId,
    interfaceFactory: characterIdlFactory,
  });
  let itemActor = await plug.createActor({
    canisterId: itemCanisterId,
    interfaceFactory: itemIdlFactory,
  });

  // let agent = new HttpAgent({ identity: principal });
  // if (network === "local") {
  //   agent.fetchRootKey();
  // }

  // let gameActor = backendCreateActor(backendCanisterId, { agent });
  // let charActor = Actor.createActor(characterIdlFactory, {
  //   agent,
  //   canisterId: characterCanisterId,
  // });
  // let itemActor = Actor.createActor(itemIdlFactory, {
  //   agent,
  //   canisterId: itemCanisterId,
  // });

  saveActors(gameActor, charActor, itemActor);
  saveLogin("plug", principal);
};
