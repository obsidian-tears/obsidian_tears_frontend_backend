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
import principalToAccountIdentifier from "./utils";

const ObsidianTears = () => {
  const [loggedInWith, setLoggedInWith] = React.useState(""); // "plug", "stoic" or "" if not logged
  const [route, setRoute] = React.useState("login"); // "login" -> "nftSelector" -> "game"
  const [loading, setLoading] = React.useState(false);
  const [myNfts, setMyNfts] = React.useState([]);
  const [identity, setIdentity] = React.useState(null);
  const [gameActor, setGameActor] = React.useState(null);
  const [charActor, setCharActor] = React.useState(null);
  const [itemActor, setItemActor] = React.useState(null);
  const [selectedNftIndex, setSelectedNftIndex] = React.useState(null);
  const [authToken, setAuthToken] = React.useState("");

  const gameCanisterId = Actor.canisterIdOf(backendActor);

  const whitelist = [gameCanisterId, itemCanisterId, characterCanisterId];

  // asset urls
  const backgroundImageWood2 = { backgroundImage: "url(button-wood-2.png)" };

  const loadActors = async (loggedInWith, a) => {
    console.log("loading actors");
    let characterActor;
    if (loggedInWith === "plug") {
      setItemActor(
        await window.ic.plug.createActor({
          canisterId: itemCanisterId,
          interfaceFactory: itemIdlFactory,
        })
      );
      characterActor = await window.ic.plug.createActor({
        canisterId: characterCanisterId,
        interfaceFactory: characterIdlFactory,
      });
      setCharActor(characterActor);
    } else if (loggedInWith === "stoic") {
      characterActor = Actor.createActor(characterIdlFactory, {
        agent: a,
        canisterId: characterCanisterId,
      });
      setGameActor(backendCreateActor(backendCanisterId, { agent: a }));
      setCharActor(characterActor);
      setItemActor(
        Actor.createActor(itemIdlFactory, {
          agent: a,
          canisterId: itemCanisterId,
        })
      );
    }
    return characterActor;
  };

  const loadCharacters = async (characterActor, p) => {
    setLoading(true);
    console.log(`load characters`);
    let registry = await characterActor.getRegistry();
    const address = principalToAccountIdentifier(p);
    console.log(`address: ${address}`);
    let nfts = registry.filter((val, i, arr) => val[1] == address);
    console.log(`nfts: ${nfts}`);
    setMyNfts(nfts);
    setLoading(false);
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
        if (!window.ic.plug.agent) {
          window.ic.plug.createAgent({ whitelist, host });
        }
      } else if (loggedInWith === "stoic") {
        p = identity.getPrincipal();
        agent = new HttpAgent({ identity, host });
        if (network === "local") {
          agent.fetchRootKey();
        }
      }
    } else {
      connected = await tryToConnect();
    }
    if (connected) {
      console.log("about to load actors");
      let characterActor = await loadActors(loggedInWith, agent);
      console.log("finished loading actors. now load characters");
      await loadCharacters(characterActor, p.toText());
      console.log(
        `loaded actors: c,i,g: ${charActor}, ${itemActor}, ${gameActor}`
      );
    }
  };

  const connectToStoic = async () => {
    StoicIdentity.load().then(async (identity) => {
      // No existing connection, lets make one!
      identity = await StoicIdentity.connect();
      let p = identity.getPrincipal().toText();
      setIdentity(identity);
      let agent = new HttpAgent({ identity: identity });
      if (network === "local") {
        agent.fetchRootKey();
      }
      setLoggedInWith("stoic");
      let characterActor = await loadActors("stoic", agent);
      await loadCharacters(characterActor, p);
      setRoute("nftSelector");
    });
  };

  const selectNft = async (index) => {
    setSelectedNftIndex(index);
    const authToken = await gameActor.getAuthToken(index);

    if (authToken.Err) {
      console.log(authToken.Err);
      return;
    }

    setAuthToken(authToken.ok);
    console.log("Selected NFT index: " + index);
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
          loadActors={loadActors}
          loadCharacters={loadCharacters}
          setLoggedInWith={setLoggedInWith}
          loggedInWith={loggedInWith}
          logout={logout}
        />
      )}
      {route === "nftSelector" && (
        <NftSelector
          selectNft={selectNft}
          loading={loading}
          myNfts={myNfts}
          loggedInWith={loggedInWith}
          logout={logout}
        />
      )}
      {route === "game" && (
        <Game
          authToken={authToken}
          gameActor={gameActor}
          selectedNftIndex={selectedNftIndex}
        />
      )}
    </>
  );
};

const root = createRoot(document.getElementById("app"));
root.render(<ObsidianTears />);
