
import * as React from 'react'
import { render } from 'react-dom'

import Home from './pages/home'
import Game from './pages/game'

import '../assets/main.css'

import { useUnityContext } from 'react-unity-webgl'
import { idlFactory } from '../../declarations/obsidian_tears'
import { itemIdlFactory, characterIdlFactory } from './types'
import principalToAccountIdentifier from './utils'
import { Principal } from '@dfinity/principal'
import { Actor, HttpAgent } from '@dfinity/agent'
import { StoicIdentity } from 'ic-stoic-identity'

const ObsidianTears = () => {
  const [loggedIn, setLoggedIn] = React.useState(false)
  const [principal, setPrincipal] = React.useState('')
  const [expandHeader, setExpandHeader] = React.useState(false)
  const [route, setRoute] = React.useState('home')
  const [usingPlug, setUsingPlug] = React.useState(false)
  const [usingStoic, setUsingStoic] = React.useState(false)
  const [loading, setLoading] = React.useState(false)
  const [myNfts, setMyNfts] = React.useState([])
  const [characterActor, setCharacterActor] = React.useState(null)
  const [itemActor, setItemActor] = React.useState(null)
  const [gameActor, setGameActor] = React.useState(null)
  const [identity, setIdentity] = React.useState(null)
  const [stoicHttpAgent, setStoicHttpAgent] = React.useState(null)
  const [selectedNftIndex, setSelectedNftIndex] = React.useState(null)

  const gameCanister = 'gagfs-yqaaa-aaaao-aaiva-cai'
  const itemCanister = 'goei2-daaaa-aaaao-aaiua-cai'
  const characterCanister = 'dhyds-jaaaa-aaaao-aaiia-cai'
  const whitelist = [gameCanister, itemCanister, characterCanister]
  const host = 'https://mainnet.dfinity.network'

  const loadActors = async (plug, stoic, p, a) => {
    let charActor
    if (plug) {
      setItemActor(
        await window.ic.plug.createActor({
          canisterId: itemCanister,
          interfaceFactory: itemIdlFactory,
        }),
      )
      charActor = await window.ic.plug.createActor({
        canisterId: characterCanister,
        interfaceFactory: characterIdlFactory,
      })
      setGameActor(
        await window.ic.plug.createActor({
          canisterId: gameCanister,
          interfaceFactory: idlFactory,
        }),
      )
    } else if (stoic) {
      setGameActor(
        Actor.createActor(idlFactory, {
          agent: a,
          canisterId: gameCanister,
        }),
      )
      charActor = Actor.createActor(characterIdlFactory, {
        agent: a,
        canisterId: characterCanister,
      })
      setItemActor(
        Actor.createActor(itemIdlFactory, {
          agent: a,
          canisterId: itemCanister,
        }),
      )
    }
    await loadCharacters(charActor, p)
  }

  const loadCharacters = async (charActor, p) => {
    setLoading(true)
    let registry = await charActor.getRegistry()
    const address = principalToAccountIdentifier(p)
    let nfts = registry.filter((val, i, arr) => val[1] == address)
    console.log(`nfts: ${nfts}`)
    setMyNfts(nfts)
    setLoading(false)
  }

  const verifyConnectionAndAgent = async () => {
    var connected
    if (usingPlug) {
      connected = await window.ic.plug.isConnected()
    } else if (usingStoic) {
      StoicIdentity.load().then(async (id) => {
        connected = id !== false
      })
    }
    // connect to wallet if not connected
    let agent
    let p
    if (connected) {
      if (usingPlug) {
        p = await window.ic.plug.getPrincipal().toText()
        setPrincipal(p)
        if (!window.ic.plug.agent) {
          window.ic.plug.createAgent({ whitelist, host })
        }
      } else if (usingStoic) {
        p = identity.getPrincipal()
        setPrincipal(p.toText())
        agent = new HttpAgent({ identity, host })
        setStoicHttpAgent(agent)
      }
    } else {
      connected = await tryToConnect()
    }
    if (connected) {
      await loadActors(usingPlug, usingStoic, p.toText(), agent)
    }
    // setLoggedIn(connected)
  }

  const connectToStoic = async () => {
    let i = await StoicIdentity.connect()
    let p = i.getPrincipal()
    setIdentity(i)
    setPrincipal(p.toText())
    let agent = new HttpAgent({ identity: i, host })
    setStoicHttpAgent(agent)
    setLoggedIn(true)
    setUsingStoic(true)
    await loadActors(false, true, p.toText(), agent)
  }

  const selectNft = async (index) => {
    setSelectedNftIndex(index)
    // TODO load player save data from game canister
    const verifiedNfts = await gameActor.verify()
    if (!verifiedNfts['Ok']) {
    }
    const loginData = await gameActor.login(index)
    setRoute('game')
  }

  const tryToConnect = async () => {
    var connected = false
    if (usingPlug) {
      await window.ic.plug.requestConnect({ whitelist, host })
      connected = await window.ic.plug.isConnected()
    } else if (usingStoic) {
      let id = await StoicIdentity.connect()
      setIdentity(id)
      connected = id !== false
    }
    return connected
  }

  const { unityProvider, isLoaded, loadingProgression, addEventListener, removeEventListener  } = useUnityContext({
    loaderUrl: '../../icp-webgl/Build/Desktop.loader.js',
    dataUrl: '../../icp-webgl/Build/Desktop.data',
    frameworkUrl: '../../icp-webgl/Build/Desktop.framework.js',
    codeUrl: '../../icp-webgl/Build/Desktop.wasm',
  })

  const logout = () => {
    window.ic.plug.disconnect()
    setRoute('home')
    setLoggedIn(false)
  }

  React.useEffect(async () => {
    // connect
    verifyConnectionAndAgent()
    // register unity functions
    addEventListener('GameOver', async function () {
      setRoute('home')
    })
    addEventListener('SaveGame', async function (gameData) {
      let result = gameActor.saveGame(selectedNftIndex, gameData)
      //todo: check result, take action on error
    })
    addEventListener('BuyNftItem', async function (metadata) {
      let result = gameActor.buyItem(selectedNftIndex, metadata)
      //todo: check result, take action on error
    })
    addEventListener('OpenChest', async function () {
      let result = gameActor.openChest(selectedNftIndex)
      //todo: check result, take action on error, put the item in the game on success
    })
    addEventListener('EquipItems', async function (itemIndices) {
      let result = gameActor.equipItems(selectedNftIndex, itemIndices)
      //todo: check result, take action on error
    })
    addEventListener('GiveGold', async function (goldAmount) {})
  }, [])

  return (
    <>
    
      <div id="header">
        <div className="leftHeader">
          <img
            alt="logo"
            src="https://rbmwowza3.s3.amazonaws.com/uofu-vod/icpbadge100d.png"
            height="50"
          ></img>
        </div>
          <div className="rightHeader">

              <button className="buttonWood" onClick={() => setRoute('home')}>
                Home
              </button>

              <button
                  className="buttonWood"
                  onClick={() => window.open('https://entrepot.app/marketplace/obsidian-tears')}>
                  Shop NFTs
              </button>

              {loggedIn ? (
                <div className="rightHeader2">

                  <button className="buttonWood">
                    {principal.slice(0, 5)}
                  </button>   

                  <button className="buttonWood" onClick={() => logout()}>
                    Logout
                  </button>


              </div>
            ) : (
              <></>
            )}
          </div>
      </div>
      {route == 'home' ? (
        <Home
          loading={loading}
          setLoading={setLoading}
          myNfts={myNfts}
          setMyNfts={setMyNfts}
          connectToStoic={connectToStoic}
          loadActors={loadActors}
          setUsingPlug={setUsingPlug}
          setUsingStoic={setUsingStoic}
          usingPlug={usingPlug}
          usingStoic={usingStoic}
          setPrincipal={setPrincipal}
          principal={principal}
          setRoute={setRoute}
          loggedIn={loggedIn}
          setLoggedIn={setLoggedIn}
          characterActor={characterActor}
          selectNft={selectNft}
        />
      ) : route == 'game' ? (
        <Game
          unityProvider={unityProvider}
          isLoaded={isLoaded}
          loadingProgression={loadingProgression}
        />
      ) : (
        <></>
      )}
    </>
  )
}

render(<ObsidianTears />, document.getElementById('app'))
