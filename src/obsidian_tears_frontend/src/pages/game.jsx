import * as React from 'react'
import { useUnityContext } from 'react-unity-webgl'
import { Unity } from 'react-unity-webgl'

const Game = (props) => {
  const [loadingPercentage, setLoadingPercentage] = React.useState(0)

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
        window.saveData = gameData
        // sort through the data
        var gameDataParsed = JSON.parse(gameData)
        gameDataParsed['m_list'].find(
          (val, index) => val['key'] == 'player_inv_currInventoryCurrencySaver',
          // TODO preserve the equipped item data that is erased here ^
          // TODO save the equipped items in the server
        )['data'] = 'playerInvCurrData'
        gameDataParsed['m_list'].find(
          (val, index) => val['key'] == 'charStats_SaverCharStatsSaver',
        )['data'] = 'charStatsData'
        var preppedData = JSON.stringify(gameDataParsed)
        // call the actor function
        let result = await props.gameActorRef.current.saveGame(
          props.selectedNftIndexRef.current,
          preppedData,
        )
        if (result['Ok']) {
          window.saveGame = result['Ok']
          sendMessage(objectName, 'ListenSaveGame', result['Ok'])
        }
        if (result['Err']) {
          // TODO send message to display unity error
          window.saveGame = result['Err']
          console.log('Error in SaveGame')
          console.log(result['Err'])
        }
      })
      addEventListener('LoadGame', async function (objectName) {
        let result = await props.gameActorRef.current.loadGame(
          props.selectedNftIndexRef.current,
        )
        if (result['Ok']) {
          window.loadData = result['Ok']
          sendMessage(objectName, 'ListenLoadGame', result['Ok'])
        }
        if (result['Err']) {
          // TODO send message to display unity error
          window.loadData = result['Err']
          console.log('Error in LoadGame')
        }
      })
      addEventListener('BuyItem', async function (
        shopIndex,
        itemIndex,
        qty,
        objectName,
      ) {
        let result = await props.gameActorRef.current.buyItem(
          props.selectedNftIndexRef.current,
          shopIndex,
          qty,
          itemIndex,
        )
        //todo: check result, take action on error
        if (result['Ok']) {
          window.buyItemData = result['Ok']
          // bought items are given in game
        }
        if (result['Err']) {
          // TODO send message to display unity error
          window.buyItemData = result['Err']
          sendMessage(objectName, 'DisplayError', JSON.stringify(result['Err']))
          console.log('Error in LoadGame')
        }
      })
      addEventListener('OpenChest', async function (chestId, objectName) {
        let result = await props.gameActorRef.current.openChest(
          props.selectedNftIndexRef.current,
          chestId,
        )
        if (result['Ok']) {
          window.chestData = result['Ok']
          sendMessage(objectName, 'ListenOpenChest', JSON.stringify(result['Ok']))
        }
        if (result['Err']) {
          // TODO send message to display unity error
          window.chestData = result['Err']
          sendMessage(objectName, 'DisplayError', JSON.stringify(result['Err']))
          console.log('Error in OpenChest')
        }
        //todo: check result, take action on error, put the item in the game on success
      })
      addEventListener('EquipItems', async function (itemIndices, objectName) {
        let result = await props.gameActorRef.current.equipItems(
          props.selectedNftIndexRef.current,
          itemIndices,
        )
        //todo: check result, take action on error
        if (result['Ok']) {
          window.equipdata = result['Ok']
        }
        if (result['Err']) {
          // TODO send message to display unity error
          window.equipData = result['Err']
          sendMessage(objectName, 'DisplayError', result['Err'])
          console.log('Error in LoadGame')
        }
      })
      addEventListener('DefeatMonster', async function (
        monsterIndex,
        objectName,
      ) {
        let result = await props.gameActorRef.current.defeatMonster(
          props.selectedNftIndexRef.current,
          monsterIndex,
        )
        if (result['Ok']) {
          window.monsterData = result['Ok']
          sendMessage(objectName, 'ListenDefeatMonster', JSON.stringify(result['Ok']))
        }
        if (result['Err']) {
          // TODO send message to display unity error
          window.monsterData = result['Err']
          sendMessage(objectName, 'DisplayError', JSON.stringify(result['Err']))
          console.log('Error in LoadGame')
        }
      })
    }
  }, [isLoaded])

  React.useEffect(() => {
    setLoadingPercentage(Math.round(loadingProgression * 100))
  }, [loadingProgression])

  return (
    <>
      <div id="body" style={{ backgroundImage: "url(background-large-obelisk.jpg)" }}>
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
    </>
  )
}

export default Game
