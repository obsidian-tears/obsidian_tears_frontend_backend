// Sentry initialization should be imported first!
import "./libs/sentry";
import * as React from "react";
import { createRoot } from "react-dom/client";

import Game from "./pages/game";
import Login from "./pages/login";
import NftSelector from "./pages/nftSelector";
import { initAnalytics, loggedInEvent } from "./libs/analytics";
import { network } from "./env.jsx";

import { StoicIdentity } from "ic-stoic-identity";
import { AuthClient } from "@dfinity/auth-client";

import "../assets/main.css";

const ObsidianTears = () => {
  // loginInfo {identity, principal, loggedInWith ("plug", "stoic", "nfid" or "" if not logged)}
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
    loggedInEvent(loggedInWith, principal);
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
    } else if (loginInfo.loggedInWith === "nfid") {
      let client = await AuthClient.create();
      client.logout();
    }

    setRoute("login");
    setLoginInfo({
      loggedInWith: "",
    });
  };

  return (
    <>
      {network == "ic" && initAnalytics()}
      {route === "login" && (
        <Login saveLogin={saveLogin} saveActors={saveActors} />
      )}
      {route === "nftSelector" && (
        <NftSelector
          setNftInfo={setNftInfo}
          gameActor={gameActor}
          charActor={charActor}
          loginInfo={loginInfo}
          logout={logout}
        />
      )}
      {route === "game" && <Game selectedNftInfo={selectedNftInfo} />}
    </>
  );
};

const root = createRoot(document.getElementById("app"));
root.render(<ObsidianTears />);
