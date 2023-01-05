
import * as React from 'react'
import { render } from 'react-dom'

import Home from './pages/home'
import Game from './pages/game'

import '../assets/main.css'

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
  const [identity, setIdentity] = React.useState(null)
  const [gameActor, _setGameActor] = React.useState(null)
  const [charActor, _setCharActor] = React.useState(null)
  const [itemActor, _setItemActor] = React.useState(null)
  const [stoicHttpAgent, setStoicHttpAgent] = React.useState(null)
  const [selectedNftIndex, _setSelectedNftIndex] = React.useState(null)
  const gameActorRef = React.useRef(gameActor)
  const itemActorRef = React.useRef(itemActor)
  const charActorRef = React.useRef(charActor)
  const selectedNftIndexRef = React.useRef(selectedNftIndex)
  const setSelectedNftIndex = (data) => {
    selectedNftIndexRef.current = data
    _setSelectedNftIndex(data)
  }
  const setItemActor = (data) => {
    itemActorRef.current = data
    _setItemActor(data)
  }
  const setGameActor = (data) => {
    gameActorRef.current = data
    _setGameActor(data)
  }
  const setCharActor = (data) => {
    charActorRef.current = data
    _setCharActor(data)
  }

  const gameCanister = 'gagfs-yqaaa-aaaao-aaiva-cai'
  const itemCanister = 'goei2-daaaa-aaaao-aaiua-cai'
  const characterCanister = 'dhyds-jaaaa-aaaao-aaiia-cai'
  // const gameCanister = 'r7inp-6aaaa-aaaaa-aaabq-cai'
  // const itemCanister = 'goei2-daaaa-aaaao-aaiua-cai'
  // const characterCanister = 'ryjl3-tyaaa-aaaaa-aaaba-cai'
  const whitelist = [gameCanister, itemCanister, characterCanister]
  // const host = 'http://127.0.0.1:8000'
  const host = 'https://mainnet.dfinity.network'

  const loadActors = async (plug, stoic, a) => {
    console.log('loading actors')
    let characterActor
    if (plug) {
      setItemActor(
        await window.ic.plug.createActor({
          canisterId: itemCanister,
          interfaceFactory: itemIdlFactory,
        }),
      )
      characterActor = await window.ic.plug.createActor({
        canisterId: characterCanister,
        interfaceFactory: characterIdlFactory,
      })
      setCharActor(characterActor)
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
      characterActor = Actor.createActor(characterIdlFactory, {
        agent: a,
        canisterId: characterCanister,
      })
      setCharActor(characterActor)
      setItemActor(
        Actor.createActor(itemIdlFactory, {
          agent: a,
          canisterId: itemCanister,
        }),
      )
    }
    return characterActor
  }

  const loadCharacters = async (characterActor, p) => {
    setLoading(true)
    console.log(`load characters`);
    let registry = await characterActor.getRegistry()
    const address = principalToAccountIdentifier(p)
    console.log(`address: ${address}`);
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
      console.log('using stoic');
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

      console.log('about to load actors');
      let characterActor = await loadActors(usingPlug, usingStoic, agent)
      console.log('finished loading actors. now load characters');
      await loadCharacters(characterActor, p.toText())
      console.log(
        `loaded actors: c,i,g: ${charActor}, ${itemActor}, ${gameActor}`,
      )
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
    let characterActor = await loadActors(false, true, agent)
    await loadCharacters(characterActor, p.toText())
  }

  const selectNft = async (index) => {
    setSelectedNftIndex(index)
    // TODO load player save data from game canister
    const verifiedNfts = await gameActor.verify()
    console.log(`verifiedNfts: ${verifiedNfts}`)
    if (!verifiedNfts['Ok']) {
    }
    const loginData = await gameActor.loadGame(index)
    console.log(`loginData ${loginData + ', index: ' + index}`)
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


  const logout = () => {
    window.ic.plug.disconnect()
    setRoute('home')
    setLoggedIn(false)
  }

  React.useEffect(async () => {
    // connect
    console.log(`actors: ${gameActor}, ${itemActor}, ${charActor}`)
    if (gameActor == null && itemActor == null && charActor == null ) {
      await verifyConnectionAndAgent()
    }
  }, [gameActor, itemActor, charActor])


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
          loadCharacters={loadCharacters}
          setUsingPlug={setUsingPlug}
          setUsingStoic={setUsingStoic}
          usingPlug={usingPlug}
          usingStoic={usingStoic}
          setPrincipal={setPrincipal}
          principal={principal}
          setRoute={setRoute}
          loggedIn={loggedIn}
          setLoggedIn={setLoggedIn}
          selectNft={selectNft}
        />
      ) : route == 'game' ? (
        <Game
          gameActorRef={gameActorRef}
          selectedNftIndexRef={selectedNftIndexRef}
        />
      ) : (
        <></>
      )}
    </>
  )
}

render(<ObsidianTears />, document.getElementById('app'))
