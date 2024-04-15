import { Actor, HttpAgent } from "@dfinity/agent";
import { StoicIdentity } from "ic-stoic-identity";
import {
  canisterId as backendCanisterId,
  createActor as backendCreateActor,
} from "../../../declarations/obsidian_tears_backend";
import { characterIdlFactory } from "../../idl_factories/characterIdlFactory.did";
import { itemIdlFactory } from "../../idl_factories/itemIdlFactory.did";
import { characterCanisterId, itemCanisterId, network } from "../env";

export const connectToStoic = async (saveLogin, saveActors) => {
  StoicIdentity.load().then(async () => {
    let identity = await StoicIdentity.connect();
    console.log(identity);
    let agent = new HttpAgent({ identity: identity });
    if (network === "local") {
      agent.fetchRootKey();
    }

    let gameActor = backendCreateActor(backendCanisterId, { agent: agent });
    let charActor = Actor.createActor(characterIdlFactory, {
      agent: agent,
      canisterId: characterCanisterId,
    });
    let itemActor = Actor.createActor(itemIdlFactory, {
      agent: agent,
      canisterId: itemCanisterId,
    });

    saveActors(gameActor, charActor, itemActor);
    saveLogin("stoic", identity);
  });
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
