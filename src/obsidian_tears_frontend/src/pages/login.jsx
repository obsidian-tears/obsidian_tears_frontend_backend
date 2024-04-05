import PlugConnect from "@psychedelic/plug-connect";
import * as React from "react";
import Navbar from "../components/navbar";

const Login = (props) => {
  // asset urls
  const backgroundImageWood3 = { backgroundImage: "url(button-wood-3.png)" };

  return (
    <div
      id="body"
      style={{ backgroundImage: "url(background-large-obelisk.jpg)" }}
    >
      <Navbar loggedInWith={props.loggedInWith} logout={props.logout} />

      <div>
        <img src="menu-big-logo.png" alt="menu logo"></img>
        <>
          <div className="space50"></div>
          {false && (
            <div className="centerMe">
              <PlugConnect
                whitelist={props.whitelist}
                onConnectCallback={props.connectToPlug}
              />
              <br></br>
            </div>
          )}
          <div className="centerMe">
            <button
              className={"buttonWoodGridXL"}
              style={backgroundImageWood3}
              onClick={async () => {
                await props.connectToStoic();
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
