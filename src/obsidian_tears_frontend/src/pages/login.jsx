import * as React from "react";
import { useState } from "react";
import Navbar from "../components/navbar";
import { connectToStoic } from "../providers/stoicProvider";
import { connectToPlug } from "../providers/plugProvider";
import { connectToNFID } from "../providers/nfidProvider";
import {
  ObsidianButton,
  LargeObsidianButton,
} from "../components/obsidianButtons";

const Login = (props) => {
  const [openLogin, setLogin] = useState(true);
  const toggleLogin = () => setLogin((prev) => !prev);

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
          {/* LOGIN BUTTON */}
          {openLogin && (
            <div className="h-80 w-full bg-transparent flex justify-center">
              <div className="bg-transparent w-1/2 max-w-96 rounded-2xl flex flex-col items-center justify-center">
                <ObsidianButton
                  buttonText="Login"
                  clickCallback={toggleLogin}
                  extraClasses={"ml-5"}
                ></ObsidianButton>
              </div>
            </div>
          )}
          {/* SIGN IN */}
          {!openLogin && (
            <div className="h-80 w-full bg-transparent flex justify-center">
              <div className="bg-card-beige w-5/6 lg:w-1/2 max-w-96 rounded-2xl flex flex-col items-center border border-regal-blue">
                <h2 className="mt-4 mb-8 font-mochiy text-white text-2xl">
                  Sign In
                </h2>
                <LargeObsidianButton
                  buttonText="NFID"
                  clickCallback={async () =>
                    await connectToNFID(props.saveLogin, props.saveActors)
                  }
                ></LargeObsidianButton>
                <LargeObsidianButton
                  buttonText="Plug"
                  clickCallback={async () => await handlePlugButton()}
                ></LargeObsidianButton>
                <LargeObsidianButton
                  buttonText="Stoic"
                  clickCallback={async () =>
                    await connectToStoic(props.saveLogin, props.saveActors)
                  }
                ></LargeObsidianButton>
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
      {/* 1 CARD INFO SECTION */}
      <div className="w-full h-full px-10 flex">
        <div className="bg-card-beige rounded-2xl w-full h-full flex flex-col">
          <div className="w-full flex flex-col items-center">
            <h3 className="flex items-center justify-center font-mochiy text-xl text-white pt-8">
              I need an Hero NFT?
            </h3>
            <div className="max-w-96 md:max-w-full text-start font-jura text-white p-8">
              <p>
                <strong>Yes.</strong> Obsidian Tears is hosted 100% on a
                blockchain called the Internet Computer. All of the game assets,
                website frontend and backend, saved data and nfts are stored and
                retrieved from the blockchain, allowing 100% of the game to be
                decentralized and to{" "}
                <strong>exist in many years to come</strong>.
                <br />
                <br />
                Each Hero NFT is much more than an access token to the game:
              </p>
              <ul className="list-disc pl-6">
                <li>It unlocks the associated save data</li>
                <li>
                  Soon, it will allow to mint items in limited quantities per
                  Hero NFT
                </li>
                <li>
                  Each has different physical attributes and belongs to a class
                </li>
              </ul>
              <br />
              <p>
                They come in three different classes:{" "}
                <strong>Fighters, Rangers and Mages</strong>. Each offers its
                own in-game advantages like buffed stats and exclusive access to
                certain items and abilities.
              </p>
            </div>
          </div>
        </div>
      </div>
      {/* 2 CARD INFO SECTION */}
      <div className="w-full h-full px-10 flex flex-col lg:flex-row justify-center pb-8">
        <div className="bg-card-beige rounded-2xl w-full h-full items-center justify-center mt-8 lg:mr-8">
          <div className="w-full flex flex-col items-center">
            <h4 className="flex items-center justify-center font-mochiy text-xl text-white pt-8">
              How do I get a Hero NFT?
            </h4>
            <p className="max-w-96 md:max-w-full text-start font-jura text-white p-8">
              The Hero NFT can be purchased with ICP on{" "}
              <strong>Entrepot</strong>.
              <br />
              <br />
              This will require you to setup a crypto wallet specific to the IC,
              like{" "}
              <a
                href="https://plugwallet.ooo/"
                target="_blank"
                className="text-blue-700 underline font-bold"
                rel="noreferrer"
              >
                Plug
              </a>{" "}
              and transfer ICP to it from an Exchange (Binance, Coinbase, OKX,
              ...). You can also top-up from credit card directly with{" "}
              <a
                href="https://checkout.banxa.com/?fiatAmount=60&fiatType=USD&coinType=ICP&lockFiat=true&orderMode=BUY&backgroundColor=2a1a47&primaryColor=9b6ef7&secondaryColor=8b55f6&textColor=ffffff"
                target="_blank"
                className="text-blue-700 underline font-bold"
                rel="noreferrer"
              >
                Banxa
              </a>
              .
              <br />
              <br />
              For the best gameplay experience, we recommend signing in through
              NFID with Gmail, but would require you to later transfer the NFT
              to it.
              <br />
              <br />
              Stoic is unmaintained and unless you already have been using it,
              we don&apos;t recommend setting it up.
              <br />
            </p>
          </div>
        </div>
        <div className="bg-card-beige rounded-2xl w-full min-h-full items-center justify-center mt-8">
          <div className="w-full flex flex-col items-center">
            <h4 className="flex items-center justify-center font-mochiy text-xl text-white pt-8">
              How do I get Items NFT?
            </h4>
            <p className="max-w-96 md:max-w-full text-start font-jura text-white p-8">
              <strong>Note:</strong> In order to avoid exploits and to improve
              item&apos;s economy,{" "}
              <strong>this feature is not yet published in production.</strong>
              <br />
              <br />
              In-Game Items are tradeable NFTs. Weapons, spell scrolls and
              consumables are all yours once found in-game and can be traded or
              sold on Entrepot.
              <br />
              <br />
              Each Hero NFT will only be able to mint a limited number of items
              and items will have a limited number of times that can be
              purchased and consumed into a game.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;
