import * as React from "react";
import Navbar from "../components/navbar";
import { connectToStoic } from "../providers/stoicProvider";
import { connectToPlug } from "../providers/plugProvider";

const Login = (props) => {
  const handlePlugButton = async () => {
    if (!window.ic || !window.ic.plug)
      window.open("https://plugwallet.ooo/", "_blank");
    else await connectToPlug(props.saveLogin, props.saveActors);
  };

  return (
    <div className="w-full h-full m-0 bg-regal-blue text-center">
      <Navbar />
      <div className="w-full h-full p-7 flex justify-center border">
        <div className="bg-[url('obelisk-large.png')] bg-no-repeat bg-contain bg-center rounded-2xl w-full h-full border">
          <div className="mt-24 mb-24 sm:mt-48 sm:mb-48 md:mt-60 md:mb-60 lg:mt-96 lg:mb-96 relative border border-transparent">
            <button className="absolute top-1/2 left-1/2">yeay</button>
          </div>
        </div>
      </div>
      <div>
        {/* <div className="w-full p-2 m-0 relative text-center flex justify-center">
          <img
            src="menu-big-logo.png"
            alt="menu logo"
            className="w-full max-w-2xl"
          ></img>
        </div> */}
        {/* <img alt="logo" src="icp-badge.png" className="h-12"></img> */}
        <div className="space50"></div>
        {/* <div className="w-full p-2 m-0 relative text-center">
          <button
            className="bg-button-brown h-12 w-56 items-center appearance-none text-white text-2xl font-semibold font-title pl-2 pr2 justify-center list-none overflow-hidden border-0 inline-flex leading-4 relative"
            onClick={async () => await handlePlugButton()}
          >
            Connect to Plug
          </button>
          <br></br>
        </div>
        <div className="w-full p-2 m-0 relative text-center">
          <button
            className="bg-button-brown h-12 w-56 items-center appearance-none text-white text-2xl font-semibold font-title pl-2 pr2 justify-center list-none overflow-hidden border-0 inline-flex leading-4 relative"
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
        </div> */}
      </div>
    </div>
  );
};

export default Login;
