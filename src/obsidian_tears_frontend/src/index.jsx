import * as React from "react";
import { createRoot } from "react-dom/client";

import Game from "./pages/game";
import Login from "./pages/login";
import NftSelector from "./pages/nftSelector";

import { Actor, HttpAgent } from "@dfinity/agent";
import { StoicIdentity } from "ic-stoic-identity";
import {
  obsidian_tears_backend as backendActor,
  canisterId as backendCanisterId,
  createActor as backendCreateActor,
} from "../../declarations/obsidian_tears_backend";
import { characterIdlFactory } from "../idl_factories/characterIdlFactory.did";
import { itemIdlFactory } from "../idl_factories/itemIdlFactory.did";
import { characterCanisterId, itemCanisterId, network } from "./env";

const ObsidianTears = () => {
  const [loggedInWith, setLoggedInWith] = React.useState(""); // "plug", "stoic" or "" if not logged
  const [route, setRoute] = React.useState("login"); // "login" -> "nftSelector" -> "game"
  const [identity, setIdentity] = React.useState(null);
  const [principal, setPrincipal] = React.useState(null);
  const [gameActor, setGameActor] = React.useState(null);
  const [charActor, setCharActor] = React.useState(null);
  const [itemActor, setItemActor] = React.useState(null);
  const [selectedNftInfo, setSelectedNftInfo] = React.useState(null);

  const gameCanisterId = Actor.canisterIdOf(backendActor);

  const whitelist = [gameCanisterId, itemCanisterId, characterCanisterId];

  // asset urls
  const backgroundImageWood2 = { backgroundImage: "url(button-wood-2.png)" };

  const loadActors = async (loggedInWith, agent) => {
    console.log("loading actors");
    let characterActor;
    if (loggedInWith === "plug") {
      setItemActor(
        await agent.createActor({
          canisterId: itemCanisterId,
          interfaceFactory: itemIdlFactory,
        })
      );
      characterActor = await agent.createActor({
        canisterId: characterCanisterId,
        interfaceFactory: characterIdlFactory,
      });
      setCharActor(characterActor);
    } else if (loggedInWith === "stoic") {
      characterActor = Actor.createActor(characterIdlFactory, {
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
    }
    return characterActor;
  };

  const verifyConnectionAndAgent = async () => {
    var connected;
    if (loggedInWith === "plug") {
      connected = await window.ic.plug.isConnected();
    } else if (loggedInWith === "stoic") {
      StoicIdentity.load().then(async (id) => {
        connected = id !== false;
      });
    }
    // connect to wallet if not connected
    let agent;
    let p;
    if (connected) {
      if (loggedInWith === "plug") {
        p = await window.ic.plug.getPrincipal().toText();
        setPrincipal(p);
        if (!window.ic.plug.agent) {
          window.ic.plug.createAgent({ whitelist, host });
        }
      } else if (loggedInWith === "stoic") {
        p = identity.getPrincipal();
        setPrincipal(p);
        agent = new HttpAgent({ identity, host });
        if (network === "local") {
          agent.fetchRootKey();
        }
      }
    } else {
      connected = await tryToConnect();
    }
    if (connected) {
      setRoute("nftSelector");
    }
  };

  const connectToStoic = async () => {
    StoicIdentity.load().then(async (identity) => {
      // No existing connection, lets make one!
      identity = await StoicIdentity.connect();
      let p = identity.getPrincipal().toText();
      setIdentity(identity);
      setPrincipal(p);
      let agent = new HttpAgent({ identity: identity });
      if (network === "local") {
        agent.fetchRootKey();
      }
      setLoggedInWith("stoic");
      await loadActors("stoic", agent);
      setRoute("nftSelector");
    });
  };

  const connectToPlug = async () => {
    props.setLoggedInWith("plug");
    let p = await window.ic.plug.agent.getPrincipal();
    setPrincipal(p);
    await loadActors("plug", window.ic.plug);
    setRoute("nftSelector");
  };

  const setNftInfo = async (nftInfo) => {
    setSelectedNftInfo(nftInfo);
    console.log("Selected NFT index: " + nftInfo.index);
    setRoute("game");
  };

  const tryToConnect = async () => {
    var connected = false;
    if (loggedInWith === "plug") {
      await window.ic.plug.requestConnect({ whitelist, host });
      connected = await window.ic.plug.isConnected();
    } else if (loggedInWith === "stoic") {
      let id = await StoicIdentity.connect();
      setIdentity(id);
      connected = id !== false;
    }
    return connected;
  };

  const logout = () => {
    if (loggedInWith === "plug") {
      window.ic.plug.disconnect();
    } else if (loggedInWith === "stoic") {
      StoicIdentity.disconnect();
    }

    setRoute("login");
    setLoggedInWith("");
  };

  React.useEffect(() => {
    async function checkAndRecoverSession() {
      if (gameActor == null && itemActor == null && charActor == null) {
        await verifyConnectionAndAgent();
      }
    }
    checkAndRecoverSession();
  }, [gameActor, itemActor, charActor]);

  return (
    <>
      {route === "login" && (
        <Login
          whitelist={whitelist}
          connectToStoic={connectToStoic}
          connectToPlug={connectToPlug}
          loadActors={loadActors}
          setLoggedInWith={setLoggedInWith}
          loggedInWith={loggedInWith}
          logout={logout}
        />
      )}
      {route === "nftSelector" && (
        <NftSelector
          setNftInfo={setNftInfo}
          gameActor={gameActor}
          charActor={charActor}
          principal={principal}
          loggedInWith={loggedInWith}
          logout={logout}
        />
      )}
      {route === "game" && (
        <Game gameActor={gameActor} selectedNftInfo={selectedNftInfo} />
      )}
    </>
  );
};

const root = createRoot(document.getElementById("app"));
root.render(<ObsidianTears />);
