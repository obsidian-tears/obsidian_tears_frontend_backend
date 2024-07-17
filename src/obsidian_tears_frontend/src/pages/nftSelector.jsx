import * as React from "react";
import PropTypes from "prop-types";
import ClipLoader from "react-spinners/ClipLoader";
import Navbar from "../components/navbar";
import { characterCanisterId, network } from "../env";
import principalToAccountIdentifier from "../utils";

const NftSelector = (props) => {
  const [loadingNft, setLoadingNft] = React.useState(false);
  const [clickIndex, setClickIndex] = React.useState(-1);
  const [loading, setLoading] = React.useState(true);
  const [myNfts, setMyNfts] = React.useState([]);
  const [showLoadCharacterError, setShowLoadCharacterError] =
    React.useState(false);

  // asset urls
  const backgroundImageWood2 = { backgroundImage: "url(button-wood-2.png)" };
  const nftBaseUrl =
    network == "local"
      ? `http://127.0.0.1:4943/?canisterId=${characterCanisterId}&index=`
      : `https://${characterCanisterId}.raw.icp0.io/?index=`;

  const loadCharacters = async () => {
    let registry;
    try {
      registry = await props.charActor.getRegistry();
    } catch (error) {
      console.error("Error in loadCharacters:", error);
      setShowLoadCharacterError(true);
      return;
    }

    const address = principalToAccountIdentifier(props.principal);
    console.log(`address: ${address}`);
    const nfts = registry.filter((val) => val[1] == address);
    console.log(`nfts: ${nfts}`);

    setMyNfts(nfts);
    setLoading(false);
  };

  const getCharacterData = async (nftIndex) => {
    const metadata = await props.charActor.getMetadata();
    const meta = metadata.filter((val) => val[0] == nftIndex);

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
    <div className="w-full h-full m-0 text-center">
      <Navbar logout={props.logout} />
      <div>
        {!loading ? (
          <>
            <div className="w-full p-2 m-0 relative text-center">
              <br></br>
              <h2 className="text-white font-raleway text-3xl mt-0 mr-0 ml-0 mb-6 text-center">
                Select a Hero to start the game
              </h2>
              <br></br>
            </div>

            {myNfts.length == 0 && (
              <div className="w-full p-2 m-0 relative text-center">
                <br></br>
                <h2
                  className="text-white font-raleway text-3xl mt-0 mr-0 ml-0 mb-6 text-center"
                  style={{ fontSize: "26px", fontWeight: 500 }}
                >
                  Oops... No NFTs found in this wallet.
                </h2>
              </div>
            )}
            <div className="w-full grid grid-cols-3 auto-rows-fr gap-20 h-full m-0 text-center pt-7">
              {myNfts.map((nft, i) => (
                <div key={i}>
                  <a
                    href={nftBaseUrl + nft[0]}
                    target="_blank"
                    rel="noreferrer"
                  >
                    <img
                      alt="nft"
                      src={nftBaseUrl + nft[0]}
                      className="h-56"
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
                      className="ml-2"
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
          <>
            <div className="w-full p-2 m-0 relative text-center">
              <h2 className="text-white font-raleway text-3xl mt-0 mr-0 ml-0 mb-6 text-center">
                Loading NFTs...
              </h2>
            </div>
            {showLoadCharacterError && (
              <div className="w-full flex justify-center">
                <div className="w-5/6 lg:w-1/2 max-w-96 h-full">
                  <div className="bg-red-500 text-white font-bold rounded-t px-4 py-2 flex flex-col">
                    There was an error with Stoic Wallet
                  </div>
                  <div className="border border-t-0 border-red-400 rounded-b bg-red-100 px-4 py-3 text-left text-red-700">
                    <p>
                      The most probable cause is due to a new feature in Chrome
                      that is incompatible with Stoic Wallet.
                    </p>
                    <br />
                    <p>
                      To fix this issue, follow the steps mention on their{" "}
                      <a
                        href="https://x.com/stoicwalletapp/status/1706317772194517482?s=46&t=4XqsIm2zxxeH9ADUYAWcfQ"
                        target="_blank"
                        className="text-blue-500 underline"
                        rel="noreferrer"
                      >
                        X post
                      </a>
                      :{" "}
                    </p>
                    <ul>
                      <li>1. Open a new tab.</li>
                      <li>
                        2. Go to{" "}
                        <strong>
                          <i>
                            chrome://flags/#third-party-storage-partitioning
                          </i>
                        </strong>
                        .
                      </li>
                      <li>3. Disable the feature and restart your browser.</li>
                    </ul>
                  </div>
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
};

// Define prop types
NftSelector.propTypes = {
  charActor: PropTypes.object,
  principal: PropTypes.string,
  setNftInfo: PropTypes.func,
  gameActor: PropTypes.object,
  logout: PropTypes.func,
};

export default NftSelector;
