import * as React from "react";
import Navbar from "../components/navbar";
import { connectToStoic } from "../providers/stoicProvider";
import { connectToPlug, connectToPlugMobile } from "../providers/plugProvider";
import { PlugMobileProvider } from "@funded-labs/plug-mobile-sdk";

const Login = (props) => {
  // asset urls
  const backgroundImageWood3 = { backgroundImage: "url(button-wood-3.png)" };

  const handlePlugButton = async () => {
    if (window.ic?.plug) await connectToPlug(props.saveLogin, props.saveActors);
    else if (PlugMobileProvider.isMobileBrowser())
      await connectToPlugMobile(props.saveLogin, props.saveActors);
    else window.open("https://plugwallet.ooo/", "_blank");
  };

  return (
    <div
      id="body"
      style={{ backgroundImage: "url(background-large-obelisk.jpg)" }}
    >
      <Navbar />
      <div>
        <img src="menu-big-logo.png" alt="menu logo"></img>
        <>
          <div className="space50"></div>
          <div className="centerMe">
            <button
              className={"buttonWoodGridXL"}
              style={backgroundImageWood3}
              onClick={async () => await handlePlugButton()}
            >
              Connect to Plug
            </button>
            <br></br>
          </div>
          <div className="centerMe">
            <button
              className={"buttonWoodGridXL"}
              style={backgroundImageWood3}
              onClick={async () => {
                await connectToStoic(props.saveLogin, props.saveActors);
              }}
            >
              Connect to Stoic
            </button>
          </div>
          <br></br>
          <div className="space50"></div>
          <div className="centerMe">
            <img src="menu-fighter.png" alt="fighter" height="200px"></img>
          </div>
        </>
      </div>
    </div>
  );
};

export default Login;
