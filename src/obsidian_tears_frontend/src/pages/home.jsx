import PlugConnect from "@psychedelic/plug-connect";
import * as React from "react";
import ClipLoader from "react-spinners/ClipLoader";
import { characterCanisterId, network } from "./../env";

const Home = (props) => {
  const [loadingNft, setLoadingNft] = React.useState(false);
  const [clickIndex, setClickIndex] = React.useState(-1);

  // asset urls
  const backgroundImageWood2 = { backgroundImage: "url(button-wood-2.png)" };
  const backgroundImageWood3 = { backgroundImage: "url(button-wood-3.png)" };
  const nftBaseUrl =
    network == "local"
      ? `http://127.0.0.1:4943/?canisterId=${characterCanisterId}&index=`
      : `https://${characterCanisterId}.raw.icp0.io/?index=`;

  return (
    <div>
      <img src="menu-big-logo.png" alt="menu logo"></img>

      {props.loggedIn !== "" ? (
        !props.loading ? (
          <>
            <div className="centerMe">
              <h2 className="title2">Select a Hero to start the game</h2>
              <br></br>
            </div>

            <div className="container">
              {props.myNfts.map((nft, i) => (
                <div key={i}>
                  <a href={nftBaseUrl + nft[0]} target="_blank">
                    <img
                      alt="nft"
                      src={nftBaseUrl + nft[0]}
                      height="230px;"
                    ></img>
                  </a>
                  <button
                    className="buttonWoodGrid"
                    style={backgroundImageWood2}
                    onClick={async () => {
                      setLoadingNft(true);
                      setClickIndex(i);
                      await props.selectNft(nft[0]);
                      setLoadingNft(false);
                      setClickIndex(-1);
                    }}
                    disabled={loadingNft}
                  >
                    Select
                    <ClipLoader
                      className="spinner"
                      size={20}
                      loading={loadingNft && i == clickIndex}
                      color="gray"
                    />
                  </button>
                </div>
              ))}
            </div>
          </>
        ) : (
          <p className="whiteText">loading...</p>
        )
      ) : (
        <>
          <div className="space50"></div>
          {false && (
            <div className="centerMe">
              <PlugConnect
                whitelist={props.whitelist}
                onConnectCallback={async () => {
                  props.setLoggedIn("plug");
                  let p = await window.ic.plug.agent.getPrincipal();
                  props.setPrincipal(p.toText());
                  let charActor = await props.loadActors("plug", p.toText());
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
      )}
    </div>
  );
};

export default Home;
