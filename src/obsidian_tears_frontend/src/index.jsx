import * as React from "react";
import { createRoot } from "react-dom/client";

import Home from "./pages/home";
import Game from "./pages/game";

import { network, characterCanisterId, itemCanisterId } from "./env";
import { obsidian_tears_backend as backendActor } from "../../declarations/obsidian_tears_backend";
import { characterIdlFactory } from "../idl_factories/characterIdlFactory.did";
import { itemIdlFactory } from "../idl_factories/itemIdlFactory.did";
import principalToAccountIdentifier from "./utils";
import { Principal } from "@dfinity/principal";
import { Actor, HttpAgent } from "@dfinity/agent";
import { StoicIdentity } from "ic-stoic-identity";

const ObsidianTears = () => {
  const [loggedIn, setLoggedIn] = React.useState(false);
  const [principal, setPrincipal] = React.useState("");
  const [expandHeader, setExpandHeader] = React.useState(false);
  const [route, setRoute] = React.useState("home");
  const [usingPlug, setUsingPlug] = React.useState(false);
  const [usingStoic, setUsingStoic] = React.useState(false);
  const [loading, setLoading] = React.useState(false);
  const [myNfts, setMyNfts] = React.useState([]);
  const [identity, setIdentity] = React.useState(null);
  const [gameActor, _setGameActor] = React.useState(backendActor);
  const [charActor, _setCharActor] = React.useState(null);
  const [itemActor, _setItemActor] = React.useState(null);
  const [stoicHttpAgent, setStoicHttpAgent] = React.useState(null);
  const [selectedNftIndex, _setSelectedNftIndex] = React.useState(null);
  const gameActorRef = React.useRef(gameActor);
  const itemActorRef = React.useRef(itemActor);
  const charActorRef = React.useRef(charActor);
  const selectedNftIndexRef = React.useRef(selectedNftIndex);
  const setSelectedNftIndex = (data) => {
    selectedNftIndexRef.current = data;
    _setSelectedNftIndex(data);
  };
  const setItemActor = (data) => {
    itemActorRef.current = data;
    _setItemActor(data);
  };
  const setGameActor = (data) => {
    gameActorRef.current = data;
    _setGameActor(data);
  };
  const setCharActor = (data) => {
    charActorRef.current = data;
    _setCharActor(data);
  };
  const gameCanisterId = Actor.canisterIdOf(backendActor);

  const whitelist = [gameCanisterId, itemCanisterId, characterCanisterId];

  // asset urls
  const backgroundImageWood2 = { backgroundImage: "url(button-wood-2.png)" };

  const loadActors = async (plug, stoic, a) => {
    console.log("loading actors");
    let characterActor;
    if (plug) {
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
    } else if (stoic) {
      characterActor = Actor.createActor(characterIdlFactory, {
        agent: a,
        canisterId: characterCanisterId,
      });
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
    if (usingPlug) {
      connected = await window.ic.plug.isConnected();
    } else if (usingStoic) {
      StoicIdentity.load().then(async (id) => {
        connected = id !== false;
      });
    }
    // connect to wallet if not connected
    let agent;
    let p;
    if (connected) {
      if (usingPlug) {
        p = await window.ic.plug.getPrincipal().toText();
        setPrincipal(p);
        if (!window.ic.plug.agent) {
          window.ic.plug.createAgent({ whitelist, host });
        }
      } else if (usingStoic) {
        p = identity.getPrincipal();
        setPrincipal(p.toText());
        agent = new HttpAgent({ identity, host });
        if (network === "local") {
          agent.fetchRootKey();
        }
        setStoicHttpAgent(agent);
      }
    } else {
      connected = await tryToConnect();
    }
    if (connected) {
      console.log("about to load actors");
      let characterActor = await loadActors(usingPlug, usingStoic, agent);
      console.log("finished loading actors. now load characters");
      await loadCharacters(characterActor, p.toText());
      console.log(
        `loaded actors: c,i,g: ${charActor}, ${itemActor}, ${gameActor}`
      );
    }
    // setLoggedIn(connected)
  };

  const connectToStoic = async () => {
    StoicIdentity.load().then(async (identity) => {
      // No existing connection, lets make one!
      identity = await StoicIdentity.connect();
      let p = identity.getPrincipal();
      setIdentity(identity);
      setPrincipal(p.toText());
      let agent = new HttpAgent({ identity: identity });
      if (network === "local") {
        agent.fetchRootKey();
      }
      setStoicHttpAgent(agent);
      setLoggedIn(true);
      let characterActor = await loadActors(false, true, agent);
      await loadCharacters(characterActor, p.toText());
      setUsingStoic(true);
      setUsingPlug(false);
    });
  };

  const selectNft = async (index) => {
    setSelectedNftIndex(index);
    // load player save data from game canister
    const verifiedNfts = await gameActor.verify();
    console.log(`verifiedNfts: ${verifiedNfts}`);
    if (!verifiedNfts["Ok"]) {
    }
    const loginData = await gameActor.loadGame(index);
    console.log(`loginData ${loginData + ", index: " + index}`);
    setRoute("game");
  };

  const tryToConnect = async () => {
    var connected = false;
    if (usingPlug) {
      await window.ic.plug.requestConnect({ whitelist, host });
      connected = await window.ic.plug.isConnected();
    } else if (usingStoic) {
      let id = await StoicIdentity.connect();
      setIdentity(id);
      connected = id !== false;
    }
    return connected;
  };

  const logout = () => {
    window.ic.plug.disconnect();
    setRoute("home");
    setLoggedIn(false);
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
      <div id="header">
        <div className="leftHeader">
          <img alt="logo" src="icp-badge.png" height="50"></img>
        </div>
        <div className="rightHeader">
          <button
            className="buttonWood"
            style={backgroundImageWood2}
            onClick={() => setRoute("home")}
          >
            Home
          </button>

          <button
            className="buttonWood"
            style={backgroundImageWood2}
            onClick={() =>
              window.open("https://entrepot.app/marketplace/obsidian-tears")
            }
          >
            Shop NFTs
          </button>

          {loggedIn ? (
            <div className="rightHeader2">
              <button className="buttonWood" style={backgroundImageWood2}>
                {principal.slice(0, 5)}
              </button>

              <button
                className="buttonWood"
                style={backgroundImageWood2}
                onClick={() => logout()}
              >
                Logout
              </button>
            </div>
          ) : (
            <></>
          )}
        </div>
      </div>
      {route == "home" ? (
        <Home
          loading={loading}
          setLoading={setLoading}
          myNfts={myNfts}
          setMyNfts={setMyNfts}
          connectToStoic={connectToStoic}
          loadActors={loadActors}
          loadCharacters={loadCharacters}
          setUsingPlug={setUsingPlug}
          setUsingStoic={setUsingStoic}
          usingPlug={usingPlug}
          usingStoic={usingStoic}
          setPrincipal={setPrincipal}
          principal={principal}
          setRoute={setRoute}
          loggedIn={loggedIn}
          setLoggedIn={setLoggedIn}
          selectNft={selectNft}
        />
      ) : route == "game" ? (
        <Game
          gameActorRef={gameActorRef}
          selectedNftIndexRef={selectedNftIndexRef}
        />
      ) : (
        <></>
      )}
    </>
  );
};

const root = createRoot(document.getElementById("app"));
root.render(<ObsidianTears />);
