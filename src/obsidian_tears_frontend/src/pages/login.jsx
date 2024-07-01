import * as React from "react";
import Navbar from "../components/navbar";
import { connectToStoic } from "../providers/stoicProvider";
import { connectToPlug } from "../providers/plugProvider";

const Login = (props) => {
  // asset urls
  const backgroundImageWood3 = { backgroundImage: "url(button-wood-3.png)" };
  const heroPattern = { backgroundImage: "url(obelisk-large.jpg)" };

  const handlePlugButton = async () => {
    if (!window.ic || !window.ic.plug)
      window.open("https://plugwallet.ooo/", "_blank");
    else await connectToPlug(props.saveLogin, props.saveActors);
  };

  return (
    <div
      className="w-full h-full m-0 bg-no-repeat bg-fixed bg-cover pt-20 pb-20 text-center"
      style={heroPattern}
    >
      <Navbar />
      <div>
        <div className="w-full p-2 m-0 relative text-center flex justify-center">
          <img
            src="menu-big-logo.png"
            alt="menu logo"
            className="w-full max-w-2xl"
          ></img>
        </div>
        <div className="space50"></div>
        <div className="w-full p-2 m-0 relative text-center">
          <button
            className="h-12 w-56 items-center appearance-none text-white text-2xl font-semibold font-title pl-2 pr2 justify-center list-none overflow-hidden border-0 inline-flex leading-4 relative"
            style={backgroundImageWood3}
            onClick={async () => await handlePlugButton()}
          >
            Connect to Plug
          </button>
          <br></br>
        </div>
        <div className="w-full p-2 m-0 relative text-center">
          <button
            className="h-12 w-56 items-center appearance-none text-white text-2xl font-semibold font-title pl-2 pr2 justify-center list-none overflow-hidden border-0 inline-flex leading-4 relative"
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
        <div className="w-full p-2 m-0 relative text-center flex justify-center">
          <img
            src="menu-fighter.png"
            alt="fighter"
            className="h-48 text-center"
          ></img>
        </div>
      </div>
    </div>
  );
};

export default Login;
