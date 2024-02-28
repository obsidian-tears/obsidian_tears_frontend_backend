import * as React from "react";
import PlugConnect from "@psychedelic/plug-connect";
import { characterCanisterId } from "./../env";
import "../connect2ic/styles/connect2ic.css";
const Home = (props) => {
  // asset urls
  const backgroundImageWood2 = { backgroundImage: "url(button-wood-2.png)" };
  const backgroundImageWood3 = { backgroundImage: "url(button-wood-3.png)" };

  return (
    <div>
      <img src="menu-big-logo.png" alt="menu logo"></img>

      {props.loggedIn ? (
        !props.loading ? ( //
          <>
            {/* todo esto es por si se puedo logear!!!! */}

            <div className="centerMe">
              <h2 className="title2">Select a Hero to start the game</h2>
              <br></br>
            </div>

            <div className="container">
              {props.myNfts.map((nft, i) => (
                <div key={i}>
                  {/* //creo que aca estan las imagenes que voy a poder elegir  */}
                  <a
                    href={`http://dhyds-jaaaa-aaaao-aaiia-cai.icp0.io/?canisterId=${characterCanisterId}&index=${nft[0]}`}
                    target="_blank"
                  >
                    <img
                      alt="nft"
                      src={`http://127.0.0.1:4943/?canisterId=${characterCanisterId}&index=${nft[0]}`}
                      height="230px;"
                    ></img>
                  </a>
                  <button
                    className="buttonWoodGrid"
                    style={backgroundImageWood2}
                    onClick={() => props.selectNft(nft[0])}
                  >
                    Select
                  </button>
                </div>
              ))}
            </div>
          </>
        ) : (
          <div>
            <div className="centerMe">
              <h2 className="title2">Select a Hero to start the game</h2>
              <br></br>
            </div>

            <div className="container">
              <div key="1">
                <a
                  href={`http://127.0.0.1:4943/?canisterId=${characterCanisterId}&index=${props.myNfts[0]}`}
                  target="_blank"
                >
                  <img
                    alt="nft"
                    // src={`http://127.0.0.1:4943/?canisterId=${characterCanisterId}&index=4`}
                    src={`https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGV_WGXFi48rf0w8QcNTWvJJtEe4iBVtYCFtgVxRSMG5WXZo0CMXEwtWJstn4zeAvAYIc&usqp=CAU`}
                    height="230px;"
                  ></img>
                </a>
                <button
                  className="buttonWoodGrid"
                  style={backgroundImageWood2}
                  onClick={() => props.selectNft(2)}
                >
                  Select
                </button>
              </div>
              {/* //creo que aca estan las imagenes que voy a poder elegir  */}
            </div>
          </div>

          /* <p className="whiteText">loading...</p> */
        )
      ) : (
        <>
          {/*  si no esta logeadooo  */}
          <div className="space50"></div>
          {false && (
            <div className="centerMe">
              <PlugConnect
                whitelist={props.whitelist}
                onConnectCallback={async () => {
                  props.setUsingPlug(true);
                  props.setUsingStoic(false);
                  props.setLoggedIn(true);
                  let p = await window.ic.plug.agent.getPrincipal();
                  props.setPrincipal(p.toText());
                  let charActor = await props.loadActors(
                    true,
                    false,
                    p.toText()
                  );
                  console.log("loaded actors from onconnectcallback");
                  await props.loadCharacters(charActor, p.toText());
                }}
              />
              <br></br>
            </div>
          )}
          <div className="centerMe">
            <button
              className={"buttonWoodGridXL"}
              style={backgroundImageWood3}
              onClick={async () => {
                console.log("estas apretando el boton connect with mail");
                props.connect2icNFID();
              }}
            >
              Connect to Email
            </button>
          </div>
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
          <div className="centerMe">
            <button
              className={"buttonWoodGridXL"}
              style={backgroundImageWood3}
              onClick={async () => {
                console.log("estas apretando el boton connect to ic");
                props.connect2ic();
              }}
            >
              Connect to Wallet
            </button>
          </div>
          <br></br>
          <div className="space50"></div>
          <div className="centerMe">
            <img src="menu-fighter.png" alt="fighter" height="200px"></img>
          </div>
        </>
      )}
    </div>
  );
};

export default Home;
