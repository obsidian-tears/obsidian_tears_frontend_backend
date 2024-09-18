import React from "react";
import { Unity, useUnityContext } from "react-unity-webgl";
import { Actor, HttpAgent } from "@dfinity/agent";
import {
  canisterId as backendCanisterId,
  idlFactory as backendIdlFactory,
} from "../../../declarations/obsidian_tears_backend";
import { unityUrls, network } from "../env";
import { isMobileOrTablet } from "../utils";
import {
  downloadStartedEvent,
  downloadEndedEvent,
  gameSavedEvent,
  gameLoadedEvent,
} from "../libs/analytics";

const Game = (props) => {
  const [loadingPercentage, setLoadingPercentage] = React.useState(0);
  const [loaderErrored, setLoaderErrored] = React.useState(false);

  // TODO: improve cache
  // It worked on .data, but not on .wasm
  // An error happened due to file name not changing on new version.
  // const handleCacheControl = (url) => {
  //  if (url.match(/\.data/) || url.match(/\.wasm/)) {
  //    return "must-revalidate"; // "must-revalidate" || "immutable"
  //  }
  //  return "no-store";
  // };

  const unityContextArgs = {
    ...unityUrls,
    productName: "Obsidian Tears",
    productVersion: "1.0.0",
    companyName: "Obsidian Tears LLC",
    // cacheControl: handleCacheControl,
  };

  const { unityProvider, isLoaded, addEventListener, sendMessage } =
    useUnityContext(unityContextArgs);

  const ref = React.useRef();
  const handleRequestFullscreen = () => ref.current?.requestFullscreen();

  const initDataUnity = () => {
    const initData = {
      CharacterClass: props.selectedNftInfo.class,
      CharacterUrl: props.selectedNftInfo.url,
    };
    console.log("InitDataUnity:");
    console.log(JSON.stringify(initData));
    sendMessage("ICConnect", "InitData", JSON.stringify(initData));
  };

  const checkMobile = () => {
    const isTabletOrMobile = isMobileOrTablet();

    console.log("CheckMobile:");
    console.log(isTabletOrMobile);
    sendMessage("CheckMobile", "CheckMobilePlatform", isTabletOrMobile ? 1 : 0);
  };

  // always generate new actors to avoid
  // outdated sessions due to lengthy game play
  const getAnonGameActor = async () => {
    let options = { shouldFetchRootKey: network === "local" };
    const agent = await HttpAgent.create(options);

    return Actor.createActor(backendIdlFactory, {
      agent,
      canisterId: backendCanisterId,
    });
  };

  React.useEffect(() => {
    if (isLoaded) {
      checkMobile();
      initDataUnity();
      downloadEndedEvent();

      // register unity functions
      addEventListener("SaveGame", async function (gameData, objectName) {
        gameSavedEvent();
        window.saveData = gameData;
        // call the actor function
        const gameActor = await getAnonGameActor();
        let result = await gameActor.saveGame(
          props.selectedNftInfo.index,
          gameData,
          props.selectedNftInfo.authToken,
        );
        if (result["Ok"]) {
          window.saveGame = result["Ok"];
          sendMessage(objectName, "ListenSaveGame", result["Ok"]);
        }
        if (result["Err"]) {
          // TODO send message to display unity error
          window.saveGame = result["Err"];
          console.error("Error in SaveGame");
          console.error(result["Err"]);
        }
      });
      addEventListener("LoadGame", async function (objectName) {
        gameLoadedEvent();
        const gameActor = await getAnonGameActor();
        let result = await gameActor.loadGame(
          props.selectedNftInfo.index,
          props.selectedNftInfo.authToken,
        );
        if (result["Ok"]) {
          window.loadData = result["Ok"];
          sendMessage(objectName, "ListenLoadGame", result["Ok"]);
        }
        if (result["Err"]) {
          // TODO send message to display unity error
          window.loadData = result["Err"];
          if (result["Err"]["Other"] == "No save data")
            sendMessage(objectName, "ListenLoadGame", "{}");
          else {
            console.error("Error in LoadGame");
            console.error(result["Err"]);
          }
        }
      });
      addEventListener(
        "BuyItem",
        // eslint-disable-next-line no-unused-vars
        async function (shopIndex, itemIndex, qty, objectName) {
          // TODO: please remove once Unity has removed it
          console.error("Frontend - Event BuyItem deprecated");
        },
      );
      /**
      addEventListener("MintItem", async function (encryptedToken, objectName) {
        const gameActor = await getAnonGameActor();
        let result = await gameActor.mintItem(
          props.selectedNftInfo.index,
          encryptedToken,
          props.selectedNftInfo.authToken,
        );
        if (result["Ok"]) {
          sendMessage(
            objectName,
            "ListenMintItem",
            JSON.stringify(result["Ok"]),
          );
        }
        if (result["Err"]) {
          sendMessage(
            objectName,
            "ListenMintItem",
            JSON.stringify(result["Err"]),
          );
          console.log("Error in Mint Item");
        }
        // TODO: check result, take action on error, handle the success on game
      });
      */
      // eslint-disable-next-line no-unused-vars
      addEventListener("OpenChest", async function (chestId, objectName) {
        // TODO: please remove once Unity has removed it
        console.error("Frontend - Event OpenChest deprecated");
      });
      // eslint-disable-next-line no-unused-vars
      addEventListener("EquipItems", async function (itemIndices, objectName) {
        // TODO: please remove once Unity has removed it
        console.error("Frontend - Event EquipItems deprecated");
      });
      addEventListener(
        "DefeatMonster",
        // eslint-disable-next-line no-unused-vars
        async function (monsterIndex, objectName) {
          // TODO: please remove once Unity has removed it
          console.error("Frontend - Event DefeatMonster deprecated");
        },
      );
    }

    updateLoadingPercentage(0);
  }, [isLoaded]);

  const getRandomInt = (max) => {
    return Math.floor(Math.random() * max);
  };

  const hasLoaderErrored = () => {
    let script = window.document.querySelector(
      'script[src="'.concat(unityContextArgs.loaderUrl, '"]'),
    );
    return script.getAttribute("data-status") === "error";
  };

  const updateLoadingPercentage = (percent) => {
    if (hasLoaderErrored()) {
      setLoaderErrored(true);
      return;
    }

    if (percent < 97) {
      let nextPercent = percent + getRandomInt(4);
      setLoadingPercentage(nextPercent);
      setTimeout(updateLoadingPercentage, 800, nextPercent);
    } else {
      setLoadingPercentage(100);
    }
  };

  React.useEffect(() => {
    downloadStartedEvent();

    // Override console.error
    // Assume any error level in this component means
    // failed fetching of Unity files
    const originalConsoleError = console.error;
    console.error = function (...args) {
      setLoaderErrored(true);
      originalConsoleError.apply(console, args);
    };

    return () => {
      // Restore original console.error when component is unmounted
      console.error = originalConsoleError;
    };
  }, []);

  return (
    <>
      <div>
        {!document.fullscreenElement && isLoaded === true && (
          // Full Screen
          <div
            style={{
              width: "100vw",
              height: "100vh",
              zIndex: 100,
              position: "absolute",
            }}
            onClick={handleRequestFullscreen}
          ></div>
        )}
        <div className="absolute w-full h-full">
          {isLoaded === false && (
            <>
              {loaderErrored === false && (
                // We'll conditionally render the loading overlay if the Unity
                // Application is not loaded.
                <div className="absolute top-0 left-0 w-full h-full bg-sky-700 text-white flex justify-center items-center">
                  <p>Downloading... ({loadingPercentage}%)</p>
                </div>
              )}
              {loaderErrored === true && (
                <div className="absolute top-0 left-0 w-full h-full bg-sky-700 text-white flex justify-center items-center">
                  <p>
                    Game failed to download. Please attempt to refresh page or
                    contact us in Discord.
                  </p>
                </div>
              )}
            </>
          )}
          <Unity
            ref={ref}
            className="w-full h-full"
            unityProvider={unityProvider}
          />
        </div>
      </div>
    </>
  );
};

export default Game;
