import * as React from "react";
import { createRoot } from "react-dom/client";

import Game from "./pages/game";
import Login from "./pages/login";
import NftSelector from "./pages/nftSelector";

import { StoicIdentity } from "ic-stoic-identity";

import "../assets/main.css";

const ObsidianTears = () => {
  // loginInfo {identity, principal, loggedInWith ("plug", "stoic" or "" if not logged)}
  const [loginInfo, setLoginInfo] = React.useState({});
  const [route, setRoute] = React.useState("login"); // "login" -> "nftSelector" -> "game"
  const [gameActor, setGameActor] = React.useState(null);
  const [charActor, setCharActor] = React.useState(null);
  const [selectedNftInfo, setSelectedNftInfo] = React.useState(null);

  const setNftInfo = async (nftInfo) => {
    setSelectedNftInfo(nftInfo);
    console.log("Selected NFT index: " + nftInfo.index);
    setRoute("game");
  };

  const saveLogin = async (loggedInWith, principal) => {
    setLoginInfo({
      loggedInWith,
      principal,
    });
  };

  const saveActors = async (gameActor, charActor) => {
    setGameActor(gameActor);
    setCharActor(charActor);

    setRoute("nftSelector");
  };

  const logout = async () => {
    if (loginInfo.loggedInWith === "plug") {
      await window.ic.plug.disconnect();
    } else if (loginInfo.loggedInWith === "stoic") {
      await StoicIdentity.disconnect();
    }

    setRoute("login");
    setLoginInfo({
      loggedInWith: "",
    });
  };

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
