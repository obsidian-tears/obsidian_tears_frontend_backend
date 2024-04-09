import { characterIdlFactory } from "../../idl_factories/characterIdlFactory.did";
import { itemIdlFactory } from "../../idl_factories/itemIdlFactory.did";
import { characterCanisterId, itemCanisterId } from "../env";

export const connectToPlug = async (saveLogin, saveActors) => {
  saveLogin("plug");

  let gameActor = null;
  let charActor = await agent.createActor({
    canisterId: characterCanisterId,
    interfaceFactory: characterIdlFactory,
  });
  let itemActor = await agent.createActor({
    canisterId: itemCanisterId,
    interfaceFactory: itemIdlFactory,
  });

  saveActors(gameActor, charActor, itemActor);
};
