import * as React from 'react'
import { useUnityContext } from 'react-unity-webgl'
import { Unity } from 'react-unity-webgl'
import '../../assets/main.css'

const Game = (props) => {
  const [loadingPercentage, setLoadingPercentage] = React.useState(0);

  const {
    unityProvider,
    isLoaded,
    loadingProgression,
    addEventListener,
    removeEventListener,
    sendMessage,
  } = useUnityContext({
    loaderUrl: 'unity/Build/Desktop.loader.js',
    dataUrl: 'unity/Build/Desktop.data',
    frameworkUrl: 'unity/Build/Desktop.framework.js',
    codeUrl: 'unity/Build/Desktop.wasm',
  })

  React.useEffect(() => {
    if (isLoaded) {
      // register unity functions
      addEventListener('SaveGame', async function (gameData, objectName) {
        window.saveData = gameData;
        // sort through the data
        var gameDataParsed = JSON.parse(gameData);
        gameDataParsed['m_list'].find((val, index) => val["key"] == "player_inv_curr")['data'] = "playerInvCurrData"
        gameDataParsed['m_list'].find((val, index) => val["key"] == "charStats_SaverCharStatsSaver")['data'] = "charStatsData"
        var preppedData = JSON.stringify(gameDataParsed)
        // call the actor function
        let result = await props.gameActorRef.current.saveGame(
          props.selectedNftIndexRef.current,
          preppedData,
        )
        if (result['Ok']) {
          window.result = result['Ok']
          sendMessage(objectName, 'ListenSaveGame', result['Ok'])
        }
        if (result['Err']) {
          // TODO send message to display unity error
          console.log('Error in SaveGame')
        }
      })
      addEventListener('LoadGame', async function (objectName) {
        let result = await props.gameActorRef.current.loadGame(
          props.selectedNftIndexRef.current,
        )
        if (result['Ok']) {
          window.loadData = result['Ok'];
          sendMessage(objectName, 'ListenLoadGame', result['Ok'])
        }
        if (result['Err']) {
          // TODO send message to display unity error
          window.loadData = result['Err'];
          console.log('Error in LoadGame')
        }
      })
      addEventListener('BuyItem', async function (metadata, objectName) {
        let result = await props.gameActorRef.current.buyItem(
          props.selectedNftIndexRef.current,
          metadata,
        )
        //todo: check result, take action on error
        sendMessage(objectName, 'Bought', result)
      })
      addEventListener('OpenChest', async function (chestId, objectName) {
        let result = await props.gameActorRef.current.openChest(
          props.selectedNftIndexRef.current,
          chestId,
        )
        //todo: check result, take action on error, put the item in the game on success
        sendMessage(objectName, 'LoadTreasure', result)
      })
      addEventListener('EquipItems', async function (itemIndices, objectName) {
        let result = await props.gameActorRef.current.equipItems(
          props.selectedNftIndexRef.current,
          itemIndices,
        )
        //todo: check result, take action on error
        sendMessage(objectName, 'Equipped', result)
      })
      addEventListener('DefeatMonster', async function (monsterId, objectName) {
        let result = await props.gameActorRef.current.defeatMonster(
          props.selectedNftIndexRef.current,
          monsterId,
        )
        sendMessage(objectName, 'DefeatMonster', result)
      })
    }
  }, [isLoaded])

  React.useEffect(() => {
    setLoadingPercentage(Math.round(loadingProgression * 100))
  }, [loadingProgression])

  const test = () => {
    sendMessage('ReactController', 'ListenSaveGame', '{test: 1}')
  }

  return (
    <>
      <div id="body">
        <div className="centerMe">
          <div className="unityContainer">
            {isLoaded === false && (
              // We'll conditionally render the loading overlay if the Unity
              // Application is not loaded.
              <div className="loading-overlay">
                <p>Loading... ({loadingPercentage}%)</p>
              </div>
            )}
            <Unity className="unity" unityProvider={unityProvider} />
          </div>
        </div>
      </div>
      <div>
        <button onClick={test}>Spawn Enemies</button>
      </div>
    </>
  )
}

export default Game
