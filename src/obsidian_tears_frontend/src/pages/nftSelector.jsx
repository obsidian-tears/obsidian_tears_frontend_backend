import * as React from "react";
import ClipLoader from "react-spinners/ClipLoader";
import Navbar from "../components/navbar";
import { characterCanisterId, network } from "../env";
import principalToAccountIdentifier from "../utils";

const NftSelector = (props) => {
  const [loadingNft, setLoadingNft] = React.useState(false);
  const [clickIndex, setClickIndex] = React.useState(-1);
  const [loading, setLoading] = React.useState(true);
  const [myNfts, setMyNfts] = React.useState([]);

  // asset urls
  const backgroundImageWood2 = { backgroundImage: "url(button-wood-2.png)" };
  const nftBaseUrl =
    network == "local"
      ? `http://127.0.0.1:4943/?canisterId=${characterCanisterId}&index=`
      : `https://${characterCanisterId}.raw.icp0.io/?index=`;

  const loadCharacters = async () => {
    const registry = await props.charActor.getRegistry();
    const address = principalToAccountIdentifier(props.principal);
    console.log(`address: ${address}`);
    const nfts = registry.filter((val, _i, _arr) => val[1] == address);
    console.log(`nfts: ${nfts}`);
    setMyNfts(nfts);
    setLoading(false);
  };

  const getCharacterData = async (nftIndex) => {
    const metadata = await props.charActor.getMetadata();
    const meta = metadata.filter((val, _i, _arr) => val[0] == nftIndex);

    const nft = meta[0][1];
    const index = meta[0][0];
    if (nft.nonfungible == undefined) return;

    const metadataArray = nft.nonfungible.metadata;
    if (metadataArray.length == 0) return;

    const value = metadataArray[0][1];
    let nftClass;

    switch (value) {
      case 0:
        nftClass = "RANGER";
        break;
      case 1:
        nftClass = "MAGE";
        break;
      case 2:
        nftClass = "FIGHTER";
        break;
      default:
        nftClass = "FIGHTER";
        break;
    }

    console.log("NFT Class: " + nftClass);
    return {
      index: nftIndex,
      class: nftClass,
      url: `https://${characterCanisterId}.raw.icp0.io/?index=${index}&battle=true`,
    };
  };

  const getNftInfo = async (index) => {
    const authToken = await props.gameActor.getAuthToken(index);
    if (authToken.Err) {
      console.error(authToken.Err);
      return;
    }

    const nftInfo = await getCharacterData(index);
    if (nftInfo == undefined) {
      console.error("Unable to get nft metadata");
      return;
    }
    nftInfo["authToken"] = authToken.ok;

    return nftInfo;
  };

  const handleNftSelect = async (nft, i) => {
    setLoadingNft(true);
    setClickIndex(i);
    await props.setNftInfo(await getNftInfo(nft[0]));
    setLoadingNft(false);
    setClickIndex(-1);
  };

  React.useEffect(() => {
    loadCharacters();
  }, []);

  return (
    <div id="body">
      <Navbar logout={props.logout} />
      <div>
        <img src="menu-big-logo.png" alt="menu logo"></img>

        {!loading ? (
          <>
            <div className="centerMe">
              <br></br>
              <h2 className="title">Select a Hero to start the game</h2>
              <br></br>
            </div>

            {myNfts.length == 0 && (
              <div className="centerMe">
                <br></br>
                <h2
                  className="title"
                  style={{ fontSize: "26px", fontWeight: 500 }}
                >
                  Oops... No NFTs found in this wallet.
                </h2>
              </div>
            )}
            <div className="container">
              {myNfts.map((nft, i) => (
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
          <div className="centerMe">
            <h2 className="title">Loading NFTs...</h2>
          </div>
        )}
      </div>
    </div>
  );
};

export default NftSelector;
