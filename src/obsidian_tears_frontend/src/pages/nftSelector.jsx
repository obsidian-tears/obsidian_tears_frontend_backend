import * as React from "react";
import ClipLoader from "react-spinners/ClipLoader";
import { characterCanisterId, network } from "../env";

const NftSelector = (props) => {
  const [loadingNft, setLoadingNft] = React.useState(false);
  const [clickIndex, setClickIndex] = React.useState(-1);

  // asset urls
  const backgroundImageWood2 = { backgroundImage: "url(button-wood-2.png)" };
  const nftBaseUrl =
    network == "local"
      ? `http://127.0.0.1:4943/?canisterId=${characterCanisterId}&index=`
      : `https://${characterCanisterId}.raw.icp0.io/?index=`;

  const handleNftSelect = async (nft, i) => {
    setLoadingNft(true);
    setClickIndex(i);
    await props.selectNft(nft[0]);
    setLoadingNft(false);
    setClickIndex(-1);
  };

  return (
    <div>
      <img src="menu-big-logo.png" alt="menu logo"></img>

      {!props.loading ? (
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
                  onClick={() => handleNftSelect(nft, i)}
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
      )}
    </div>
  );
};

export default NftSelector;
