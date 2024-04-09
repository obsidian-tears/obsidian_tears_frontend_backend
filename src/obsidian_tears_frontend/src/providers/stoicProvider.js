import { Actor, HttpAgent } from "@dfinity/agent";
import { StoicIdentity } from "ic-stoic-identity";
import {
  canisterId as backendCanisterId,
  createActor as backendCreateActor,
} from "../../../declarations/obsidian_tears_backend";
import { characterIdlFactory } from "../../idl_factories/characterIdlFactory.did";
import { itemIdlFactory } from "../../idl_factories/itemIdlFactory.did";
import { characterCanisterId, itemCanisterId, network } from "../env";

export const loadStoicActors = (
  agent,
  setGameActor,
  setCharActor,
  setItemActor
) => {
  let characterActor = Actor.createActor(characterIdlFactory, {
    agent: agent,
    canisterId: characterCanisterId,
  });
  setGameActor(backendCreateActor(backendCanisterId, { agent: agent }));
  setCharActor(characterActor);
  setItemActor(
    Actor.createActor(itemIdlFactory, {
      agent: agent,
      canisterId: itemCanisterId,
    })
  );

  return characterActor;
};

// export const verifyStoicConnectionAndAgent = (
//   identity,
//   setLoginInfo,
//   setRoute
// ) => {
//   StoicIdentity.load().then(async (id) => {
//     if (id) {
//       setLoginInfo((prevState) => ({
//         ...prevState,
//         principal: identity.getPrincipal(),
//       }));
//       let agent = new HttpAgent({ identity, host });
//       if (network === "local") {
//         agent.fetchRootKey();
//       }
//     } else {
//       let id = await StoicIdentity.connect();
//       setLoginInfo((prevState) => ({
//         ...prevState,
//         identity: identity,
//       }));
//       if (id) setRoute("nftSelector");
//     }
//   });
// };

//add missing arguments
export const connectToStoic = async (
  identity,
  setLoginInfo,
  setRoute,
  setGameActor,
  setCharActor,
  setItemActor
) => {
  StoicIdentity.load().then(async (identity) => {
    identity = await StoicIdentity.connect();
    let agent = new HttpAgent({ identity: identity });
    if (network === "local") {
      agent.fetchRootKey();
    }
    setLoginInfo({
      loggedInWith: "stoic",
      identity: identity,
      principal: identity.getPrincipal().toText(),
    });
    await loadStoicActors(agent, setGameActor, setCharActor, setItemActor);
    setRoute("nftSelector");
  });
};
