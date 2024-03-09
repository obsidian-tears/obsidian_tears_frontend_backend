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

// connect 2 ic imports

import {
  ConnectDialog,
  useCanister,
  useConnect,
  useDialog,
} from "@connect2ic/react";
import { canisterIds, canisters } from "./connect2ic/utils/canister";
import { createClient } from "@connect2ic/core";
import { defaultProviders } from "@connect2ic/core/providers";
import { Connect2ICProvider } from "@connect2ic/react";

// <----- client CONNECT2IC
const client = createClient({
  canisters,
  providers: defaultProviders,
  globalProviderConfig: {
    whitelist: canisterIds,
    appName: "Obsidian Tears",
    // host: "https://a5x2a-vyaaa-aaaam-ab7qq-cai.icp0.io/",
    host: "http://localhost:8080",
    dev: false,
    autoConnect: false,
  },
});
// client CONNECT2IC ----->

const ObsidianTears = () => {
  const [loggedIn, setLoggedIn] = React.useState(false);
  const [principal, setPrincipal] = React.useState("");
  const [expandHeader, setExpandHeader] = React.useState(false);
  const [route, setRoute] = React.useState("game");
  // const [route, setRoute] = React.useState("game");
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

  // <-------- connect2ic
  const {
    isConnected,
    principal: connect2icPrincipal,
    disconnect,
    connect,
  } = useConnect({
    onConnect: () => {
      console.log("hi");
    },
    onDisconnnect: () => {
      console.log("the user has logged out correctly");
    },
  });
  const [characterData, setCharacterData] = React.useState("");
  const [characterSelected, setCharacterSelected] = React.useState("");
  const [initLogin, setInitLogin] = React.useState(false);
  const { open, isOpen } = useDialog();
  const [characterActor] = useCanister("character", { mode: "anonymous" });

  const handleRequestFullscreen = () => ref.current?.requestFullscreen();
  const handleExitFullscreen = () =>
    document.fullscreenElement && document.exitFullscreen();

  //functions
  const LoginIc = async () => {
    handleExitFullscreen();
    setInitLogin(true);
    isConnected && disconnect();
    open();
  };

  const LoginNfID = async () => {
    handleExitFullscreen();
    setInitLogin(true);
    isConnected && disconnect();
    connect("nfid");
  };

  // obtain the principal
  React.useEffect(() => {
    if (isConnected && connect2icPrincipal && initLogin) {
      console.log("tu principal es: " + connect2icPrincipal);
      console.log({ characterActor });
      console.log([charActor.getRegistry]);
      const testPrincipal =
        "awmdx-onrpv-kzwjt-jggtq-t3idz-sbrq2-72c6r-7ajlg-5txoj-4ifwe-dqe";
      loadCharacters(characterActor, connect2icPrincipal);
      // loadCharacters(characterActor, testPrincipal);
    }
  }, [isConnected, connect2icPrincipal]);

  // Modify styles when the dialog is open
  React.useEffect(() => {
    if (isOpen) {
      const btnBitfinity = document.querySelector(".infinity-styles");
      const span = btnBitfinity?.querySelector(".button-label");
      span && (span.textContent = "Bitfinity Wallet");

      const btnAstrox = document.querySelector(".astrox-styles");
      const img = btnAstrox.querySelector(".img-styles");
      if (img) {
        img.style.backgroundColor = "#545454";
        img.style.borderRadius = "50px";
      }
    }
  }, [isOpen]);

  // connect2ic ---------->

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
    // const myTestAccount = "eba83bed8769d8323eb3077c2d8b404cdd34da0314fce3f3ecee3225577b5017" // this is a address with tokens
    console.log(`nfts: ${nfts}`);
    setMyNfts(nfts);
    setLoading(false);

    setCharacterData(getCharacterData(characterActor, nfts));
  };

  const selectCharacter = (index) => {
    characterData.forEach((character, arrayIndex) => {
      if (
        nft.hasOwnProperty("characterIndex") &&
        character.characterIndex == index
      ) {
        setCharacterSelected(character);
      }
    });
  };

  const getCharacterData = async (characterActor, nfts) => {
    const metadata = await characterActor.getMetadata();

    const newMetadata = [];

    nfts.forEach(function (elemento, indice) {
      console.log(`${elemento} es el elemento de ${indice}`);
      let meta = metadata.filter((val, i, arr) => val[0] == elemento[0]);
      newMetadata.push(meta);
    });

    const characterNfts = newMetadata
      .map((subArray) => {
        const objeto = subArray[0][1];
        const index = subArray[0][0];
        if (objeto.nonfungible) {
          const metadataArray = objeto.nonfungible.metadata;
          if (metadataArray.length > 0) {
            const valor = metadataArray[0][1];
            let clase;

            switch (valor) {
              case 0:
                clase = "archer";
                break;
              case 1:
                clase = "wizard";
                break;
              case 2:
                clase = "warrior";
                break;
              default:
                clase = "unknown";
                break;
            }

            return {
              characterIndex: index,
              characterClass: clase,
              characterUrl: `https://dhyds-jaaaa-aaaao-aaiia-cai.raw.icp0.io/?index=${index}`,
            };
          }
        }
        return null;
      })
      .filter((nft) => nft !== null);
    console.log("this are your nfts : " + characterNfts);
    return characterNfts;
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
    //<-IDS->
    selectCharacter(index);
    //<-IDS->

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
      {route == "game" && (
        <Game
          gameActorRef={gameActorRef}
          selectedNftIndexRef={selectedNftIndexRef}
        />
      )}
      {route == "home" && (
        <div
          id="body"
          style={{ backgroundImage: "url(background-large-obelisk.jpg)" }}
        >
          <div id="header">
            <div className="leftHeader">
              <img alt="logo" src="icp-badge.png" height="50"></img>
            </div>
            <div className="rightHeader">
              <button
                className="buttonWood"
                style={backgroundImageWood2}
                onClick={() => window.open("https://obsidiantears.xyz")}
              >
                Website
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

              {loggedIn && (
                <div className="rightHeader2">
                  <button
                    className="buttonWood"
                    style={backgroundImageWood2}
                    onClick={() => logout()}
                  >
                    Logout
                  </button>
                </div>
              )}
            </div>
          </div>

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
            connect2ic={LoginIc}
            connect2icNFID={LoginNfID}
            characterSelected={characterSelected}
          />
          <ConnectDialog />
        </div>
      )}
    </>
  );
};

const root = createRoot(document.getElementById("app"));
// root.render(<ObsidianTears />);
root.render(
  <Connect2ICProvider client={client}>
    <ObsidianTears />
  </Connect2ICProvider>
);
