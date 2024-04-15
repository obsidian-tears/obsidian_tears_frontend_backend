import * as React from "react";
import { createRoot } from "react-dom/client";

import Game from "./pages/game";
import Login from "./pages/login";
import NftSelector from "./pages/nftSelector";

import { StoicIdentity } from "ic-stoic-identity";

const ObsidianTears = () => {
  // loginInfo {identity, principal, loggedInWith ("plug", "stoic" or "" if not logged)}
  const [loginInfo, setLoginInfo] = React.useState({});
  const [route, setRoute] = React.useState("login"); // "login" -> "nftSelector" -> "game"
  const [gameActor, setGameActor] = React.useState(null);
  const [charActor, setCharActor] = React.useState(null);
  const [itemActor, setItemActor] = React.useState(null);
  const [selectedNftInfo, setSelectedNftInfo] = React.useState(null);

  // const verifyConnectionAndAgent = async () => {
  //   if (loginInfo.loggedInWith === "plug") {
  //     //verifyPlugConnectionAndAgent(identity, setPrincipal, setIdentity, setRoute);
  //   } else if (loginInfo.loggedInWith === "stoic")
  //     //verifyStoicConnectionAndAgent(loginInfo.identity, setLoginInfo, setRoute);
  // };

  const setNftInfo = async (nftInfo) => {
    setSelectedNftInfo(nftInfo);
    console.log("Selected NFT index: " + nftInfo.index);
    setRoute("game");
  };

  const saveLogin = async (loggedInWith, identity) => {
    if (loggedInWith === "stoic") {
      setLoginInfo({
        loggedInWith,
        identity,
        principal: identity.getPrincipal().toText(),
      });
    } else if (loggedInWith === "plug") {
      let principal = await window.ic.plug.getPrincipal(true);
      setLoginInfo((prevState) => ({
        ...prevState,
        loggedInWith,
        principal,
      }));
    }
  };

  const saveActors = async (gameActor, charActor, itemActor) => {
    setGameActor(gameActor);
    setCharActor(charActor);
    setItemActor(itemActor);

    setRoute("nftSelector");
  };

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
        <Login saveLogin={saveLogin} saveActors={saveActors} />
      )}
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
