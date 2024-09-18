import * as React from "react";
import Navbar from "../components/navbar";
import StoicErrorCard from "../components/stoicErrorCard";
import LoginErrorCard from "../components/loginErrorCard";
import { characterCanisterId, network } from "../env";
import principalToAccountIdentifier from "../utils";
import { ObsidianButtonWithLoader } from "../components/obsidianButtons";
import { showedNFTsEvent } from "../libs/analytics";

const NftSelector = (props) => {
  const [clickIndex, setClickIndex] = React.useState(-1);
  const [loading, setLoading] = React.useState(true);
  const [myNfts, setMyNfts] = React.useState([]);
  const [showLoadCharacterError, setShowLoadCharacterError] =
    React.useState(false);

  // asset urls
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

    const address = principalToAccountIdentifier(props.loginInfo.principal);
    console.log(`address: ${address}`);
    const nfts = registry.filter((val) => val[1] == address);
    console.log(`nfts: ${nfts}`);

    showedNFTsEvent(nfts);

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
    if (authToken.err) {
      console.error(authToken.err);
      return;
    }

    let nftInfo = await getCharacterData(index);
    if (nftInfo == undefined) {
      console.error("Unable to get nft metadata");
      return;
    }
    nftInfo["authToken"] = authToken.ok;

    return nftInfo;
  };

  const handleNftSelect = async (nft, i) => {
    // TODO: remove once fully deployed to all hero NFTs
    if (network == "ic" && nft[0] > 123) {
      alert(
        "Game is only available to OG NFTs, full public release will come soon.",
      );
      return;
    }

    setClickIndex(i);
    await props.setNftInfo(await getNftInfo(nft[0]));
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
                <h2 className="text-white font-raleway text-3xl">
                  Oops... No NFTs found in this wallet.
                </h2>
                <br></br>
                <p className="text-white font-raleway text-xl">
                  Account ID:{" "}
                  {principalToAccountIdentifier(props.loginInfo.principal)}
                </p>
              </div>
            )}
            <div className="w-full grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 auto-rows-fr gap-10 sm:gap-12 md:gap-16 lg:gap-20 h-full m-0 text-center pt-7 px-5">
              {myNfts.map((nft, i) => (
                <div
                  key={i}
                  className="flex flex-col justify-between items-center"
                >
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
                  <ObsidianButtonWithLoader
                    buttonText="Select"
                    clickCallback={() => handleNftSelect(nft, i)}
                    extraClasses={"mt-5"}
                    isLoading={clickIndex == i}
                    disabled={clickIndex != -1}
                  ></ObsidianButtonWithLoader>
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
            {showLoadCharacterError &&
              props.loginInfo.loggedInWith == "stoic" && (
                <StoicErrorCard></StoicErrorCard>
              )}
            {showLoadCharacterError &&
              props.loginInfo.loggedInWith != "stoic" && (
                <LoginErrorCard></LoginErrorCard>
              )}
          </>
        )}
      </div>
    </div>
  );
};

export default NftSelector;
