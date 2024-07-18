import * as React from "react";
import { useState } from "react";
import Navbar from "../components/navbar";
import { connectToStoic } from "../providers/stoicProvider";
import { connectToPlug } from "../providers/plugProvider";

const backgroundImageWood2 = { backgroundImage: "url(button-wood-2.png)" };
const backgroundImageWood3 = { backgroundImage: "url(button-wood-3.png)" };

const Login = (props) => {
  const [openPlay, setPlay] = useState(true);
  const togglePlay = () => setPlay((prev) => !prev);

  const handlePlugButton = async () => {
    if (!window.ic || !window.ic.plug)
      window.open("https://plugwallet.ooo/", "_blank");
    else await connectToPlug(props.saveLogin, props.saveActors);
  };

  return (
    <div className="w-full h-full m-0 text-center">
      <Navbar />
      {/* HERO */}
      <div className="w-full h-full px-10 flex justify-center pb-8">
        <div className="bg-[url('obelisk-large.png')] bg-no-repeat bg-cover bg-center rounded-2xl w-full h-full flex flex-col items-center justify-center">
          <div className="h-24 w-full">{/* SPACER */}</div>
          {/* PLAY BUTTON */}
          {openPlay && (
            <div className="h-80 w-full bg-transparent flex justify-center">
              <div className="bg-transparent w-1/2 max-w-96 rounded-2xl flex flex-col items-center justify-center">
                <button
                  type="button"
                  className="text-white text-lg font-mochiy uppercase w-full max-w-[160px] sm:px-4 px-2 py-2 mr-5 border-0 bg-cover bg-center focus:outline-none focus:ring focus:ring-yellow-900 hover:transform hover:translate-y-[-2px]
          active:transform active:translate-y-[2px]"
                  style={backgroundImageWood2}
                  onClick={togglePlay}
                >
                  Play
                </button>
              </div>
            </div>
          )}
          {/* SIGN IN */}
          {!openPlay && (
            <div className="h-80 w-full bg-transparent flex justify-center">
              <div className="bg-card-gray w-5/6 lg:w-1/2 max-w-96 rounded-2xl flex flex-col items-center border">
                <h2 className="mt-4 mb-8 font-mochiy text-white text-2xl">
                  Sign In
                </h2>
                <button
                  className="text-white text-lg font-mochiy uppercase w-2/3 px-4 py-3 my-3 border-0 bg-cover bg-center focus:outline-none focus:ring focus:ring-yellow-900 hover:transform hover:translate-y-[-2px]
                  active:transform active:translate-y-[2px]"
                  style={backgroundImageWood3}
                  onClick={async () => await handlePlugButton()}
                >
                  NFID
                </button>
                <button
                  className="text-white text-lg font-mochiy uppercase w-2/3 px-4 py-3 my-3 border-0 bg-cover bg-center focus:outline-none focus:ring focus:ring-yellow-900 hover:transform hover:translate-y-[-2px]
                  active:transform active:translate-y-[2px]"
                  style={backgroundImageWood3}
                  onClick={async () => await handlePlugButton()}
                >
                  Plug
                </button>
                <button
                  className="text-white text-lg font-mochiy uppercase w-2/3 px-4 py-3 my-3 border-0 bg-cover bg-center focus:outline-none focus:ring focus:ring-yellow-900 hover:transform hover:translate-y-[-2px]
                  active:transform active:translate-y-[2px]"
                  style={backgroundImageWood3}
                  onClick={async () =>
                    await connectToStoic(props.saveLogin, props.saveActors)
                  }
                >
                  Stoic
                </button>
              </div>
            </div>
          )}
          <div className="h-24 w-full flex justify-start items-end">
            {/* SPACER + BLOCK CHAIN LOGO */}
            <img alt="logo" src="icp-badge.png" className="h-5 ml-4 mb-3"></img>
          </div>
        </div>
      </div>
      {/* TRAILER */}
      <div className="w-full h-full px-10 flex justify-center pb-8">
        <div className="bg-card-beige rounded-2xl w-full h-full flex flex-col items-center justify-center">
          <div className="h-96 w-full flex flex-col items-center justify-center lg:flex-row lg:pr-10">
            <h3 className="lg:w-1/2 h-1/4 flex items-center justify-center font-mochiy text-lg lg:text-4xl text-white">
              Watch Trailer
            </h3>
            <iframe
              className="w-10/12 lg:w-1/2 flex items-center justify-center rounded-2xl mb-8 lg:m-auto"
              width="560"
              height="315"
              src="https://www.youtube.com/embed/PqlVY9Qy74M?si=1xoMgW24S7MdmpME"
              title="Obsidian Tears Trailer"
              frameBorder="0"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              referrerPolicy="strict-origin-when-cross-origin"
              allowFullScreen
            ></iframe>
          </div>
        </div>
      </div>
      {/* 3 CARD INFO SECTION */}
      <div className="w-full h-full px-10 flex flex-col lg:flex-row justify-center pb-8">
        <div className="bg-card-beige rounded-2xl w-full h-full flex flex-col items-center justify-center">
          <div className="h-96 w-full flex flex-col items-center justify-center">
            <h4 className="h-12 flex items-center justify-center font-jura text-xl md:text-2xl text-white">
              I need an NFT hero?
            </h4>
            <p className="h-80 max-w-96 md:max-w-full flex items-top justify-center font-jura text-xs md:text-2xl lg:text-sm text-white px-4">
              Yes. Obsidian Tears is hosted 100% on a blockchain called the
              Internet Computer Blockchain. All of the game data is stored,
              saved, and runs on the blockchain. Each Hero NFT is like an access
              token to the game. Also, each NFT is unique in physical
              attributes, making each distinct from the others. They come in
              several classes—Fighters, Rangers, Mages, and more. Each class
              offers its own in-game advantages like buffed stats and exclusive
              access to certain items and abilities. Join our Discord for more
              Information!
            </p>
          </div>
        </div>
        <div className="bg-card-beige rounded-2xl w-full h-full flex flex-col items-center justify-center my-8 lg:my-0 lg:mx-8">
          <div className="h-96 w-full flex flex-col items-center justify-center">
            <h4 className="h-12 flex items-center justify-center font-jura text-xl md:text-2xl text-white">
              How do I get an NFT?
            </h4>
            <p className="h-80 max-w-96 md:max-w-full flex items-top justify-center font-jura text-xs md:text-2xl lg:text-sm text-white px-4">
              The Hero NFT can be purchased using the ICP Token on Entrepot.
              This will require you to have a crypto wallet specific to the IC
              Blockchain. For the best gameplay experience, we recommend signing
              in through NFID. Plug and Stoic both have issues related to the
              wallet themselves. To visit Entrepot, Please visit the link below.
            </p>
          </div>
        </div>
        <div className="bg-card-beige rounded-2xl w-full h-full flex flex-col items-center justify-center">
          <div className="h-96 w-full flex flex-col items-center justify-center">
            <h4 className="h-12 flex items-center justify-center font-jura text-xl md:text-2xl text-white">
              NFT ITEMS
            </h4>
            <p className="h-80 max-w-96 md:max-w-full flex items-top justify-center font-jura text-xs md:text-2xl lg:text-sm text-white px-4">
              In-Game Items are tradeable NFT’s. Weapons, spell scrolls, and
              consumeables are all yours once found and can be traded or sold on
              Entrepot.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;
