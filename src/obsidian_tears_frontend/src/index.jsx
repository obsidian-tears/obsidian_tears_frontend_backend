import * as React from "react";
import { createRoot } from "react-dom/client";

import Game from "./pages/game";
import Login from "./pages/login";
import NftSelector from "./pages/nftSelector";

import { StoicIdentity } from "ic-stoic-identity";
import { characterIdlFactory } from "../idl_factories/characterIdlFactory.did";
import { itemIdlFactory } from "../idl_factories/itemIdlFactory.did";
import { characterCanisterId, itemCanisterId } from "./env";
import { loadStoicActors } from "./providers/stoicProvider";

const ObsidianTears = () => {
  // loginInfo {identity, principal, loggedInWith ("plug", "stoic" or "" if not logged)}
  const [loginInfo, setLoginInfo] = React.useState({});
  const [route, setRoute] = React.useState("login"); // "login" -> "nftSelector" -> "game"
  const [gameActor, setGameActor] = React.useState(null);
  const [charActor, setCharActor] = React.useState(null);
  const [itemActor, setItemActor] = React.useState(null);
  const [selectedNftInfo, setSelectedNftInfo] = React.useState(null);

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
      characterActor = loadStoicActors(
        agent,
        setGameActor,
        setCharActor,
        setItemActor
      );
    }
    return characterActor;
  };

  // const verifyConnectionAndAgent = async () => {
  //   if (loginInfo.loggedInWith === "plug") {
  //     //verifyPlugConnectionAndAgent(identity, setPrincipal, setIdentity, setRoute);
  //   } else if (loginInfo.loggedInWith === "stoic")
  //     //verifyStoicConnectionAndAgent(loginInfo.identity, setLoginInfo, setRoute);
  // };

  const connectToPlug = async () => {
    setLoginInfo((prevState) => ({
      ...prevState,
      loggedInWith: "plug",
    }));
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

  const saveLogin = async () => {};

  const saveActors = async () => {};

  const logout = () => {
    if (loginInfo.loggedInWith === "plug") {
      window.ic.plug.disconnect();
    } else if (loginInfo.loggedInWith === "stoic") {
      StoicIdentity.disconnect();
    }

    setRoute("login");
    setLoginInfo((prevState) => ({
      ...prevState,
      loggedInWith: "",
    }));
  };

  // React.useEffect(() => {
  //   async function checkAndRecoverSession() {
  //     if (gameActor == null && itemActor == null && charActor == null) {
  //       await verifyConnectionAndAgent();
  //     }
  //   }
  //   checkAndRecoverSession();
  // }, [gameActor, itemActor, charActor]);

  return (
    <>
      {route === "login" && (
        <Login
          identity={loginInfo.identity}
          setLoginInfo={setLoginInfo}
          setRoute={setRoute}
          connectToPlug={connectToPlug}
          setGameActor={setGameActor}
          setCharActor={setCharActor}
          setItemActor={setItemActor}
        />
      )}
      {console.log(loginInfo.identity)}
      {route === "nftSelector" && (
        <NftSelector
          setNftInfo={setNftInfo}
          gameActor={gameActor}
          charActor={charActor}
          principal={loginInfo.principal}
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
