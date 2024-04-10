import { characterIdlFactory } from "../../idl_factories/characterIdlFactory.did";
import { characterCanisterId } from "../env";

export const connectToPlug = async (saveLogin, saveActors) => {
  saveLogin("plug");

  let gameActor = null;
  let charActor = await agent.createActor({
    canisterId: characterCanisterId,
    interfaceFactory: characterIdlFactory,
  });

  saveActors(gameActor, charActor);
};
