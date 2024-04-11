import React from "react";
import { Unity, useUnityContext } from "react-unity-webgl";
import { unityUrls } from "../env";
import { isMobileOrTablet } from "../utils";

const Game = (props) => {
  const [loadingPercentage, setLoadingPercentage] = React.useState(0);

  const { unityProvider, isLoaded, addEventListener, sendMessage } =
    useUnityContext(unityUrls);

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

  React.useEffect(() => {
    if (isLoaded) {
      checkMobile();
      initDataUnity();

      // register unity functions
      addEventListener("SaveGame", async function (gameData, objectName) {
        window.saveData = gameData;
        // call the actor function
        let result = await props.gameActor.saveGame(
          props.selectedNftInfo.index,
          gameData,
          props.selectedNftInfo.authToken
        );
        if (result["Ok"]) {
          window.saveGame = result["Ok"];
          sendMessage(objectName, "ListenSaveGame", result["Ok"]);
        }
        if (result["Err"]) {
          // TODO send message to display unity error
          window.saveGame = result["Err"];
          console.log("Error in SaveGame");
          console.log(result["Err"]);
        }
      });
      addEventListener("LoadGame", async function (objectName) {
        let result = await props.gameActor.loadGame(
          props.selectedNftInfo.index,
          props.selectedNftInfo.authToken
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
            console.log("Error in LoadGame");
            console.log(result["Err"]);
          }
        }
      });
      addEventListener(
        "BuyItem",
        async function (shopIndex, itemIndex, qty, objectName) {
          // TODO: please remove once Unity has removed it
          console.log("Frontend - Event BuyItem deprecated");
        }
      );
      addEventListener("OpenChest", async function (chestId, objectName) {
        let result = await props.gameActor.openChest(
          props.selectedNftInfo.index,
          chestId,
          props.selectedNftInfo.authToken
        );
        if (result["Ok"]) {
          window.chestData = result["Ok"];
          sendMessage(
            objectName,
            "ListenOpenChest",
            JSON.stringify(result["Ok"])
          );
        }
        if (result["Err"]) {
          // TODO send message to display unity error
          window.chestData = result["Err"];
          sendMessage(
            objectName,
            "DisplayError",
            JSON.stringify(result["Err"])
          );
          console.log("Error in OpenChest");
        }
        //todo: check result, take action on error, put the item in the game on success
      });
      addEventListener("EquipItems", async function (itemIndices, objectName) {
        // TODO: please remove once Unity has removed it
        console.log("Frontend - Event EquipItems deprecated");
      });
      addEventListener(
        "DefeatMonster",
        async function (monsterIndex, objectName) {
          let result = await props.gameActor.defeatMonster(
            props.selectedNftInfo.index,
            monsterIndex,
            props.selectedNftInfo.authToken
          );
          if (result["Ok"]) {
            window.monsterData = result["Ok"];
            sendMessage(
              objectName,
              "ListenDefeatMonster",
              JSON.stringify(result["Ok"])
            );
          }
          if (result["Err"]) {
            // TODO send message to display unity error
            window.monsterData = result["Err"];
            sendMessage(
              objectName,
              "DisplayError",
              JSON.stringify(result["Err"])
            );
            console.log("Error in LoadGame");
          }
        }
      );
    }

    updateLoadingPercentage(0);
  }, [isLoaded]);

  const getRandomInt = (max) => {
    return Math.floor(Math.random() * max);
  };

  const updateLoadingPercentage = (percent) => {
    if (percent < 99) {
      let nextPercent = percent + getRandomInt(4);
      setLoadingPercentage(nextPercent);
      setTimeout(updateLoadingPercentage, 800, nextPercent);
    }
  };

  return (
    <>
      <div>
        {!document.fullscreenElement && (
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
        <div className="unityContainer">
          {isLoaded === false && (
            // We'll conditionally render the loading overlay if the Unity
            // Application is not loaded.
            <div className="loading-overlay">
              <p>Downloading... ({loadingPercentage}%)</p>
            </div>
          )}
          <Unity ref={ref} className="unity" unityProvider={unityProvider} />
        </div>
      </div>
    </>
  );
};

export default Game;
