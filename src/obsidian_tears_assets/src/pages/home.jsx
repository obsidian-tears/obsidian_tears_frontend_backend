import * as React from 'react'
import PlugConnect from '@psychedelic/plug-connect'
import '../../assets/main.css'

const Home = (props) => {
  return (
    <div id="body">
      <img src="https://rbmwowza3.s3.amazonaws.com/uofu-vod/BigLogo2.png"></img>

      {props.loggedIn ? (
        !props.loading ? (
          <>
            <div className="centerMe">
              <h2 className="title2">Select a Character to Start the Game</h2>
              <br></br>
            </div>

            <div className="container">
              {props.myNfts.map((nft, i) => (
                <div key={i}>
                  <a
                    href={`https://dhyds-jaaaa-aaaao-aaiia-cai.raw.ic0.app/?index=${nft[0]}`}
                    target="_blank"
                  >
                    <img
                      alt="nft"
                      src={`https://dhyds-jaaaa-aaaao-aaiia-cai.raw.ic0.app/?index=${nft[0]}`}
                      height="230px;"
                    ></img>
                  </a>
                  <button
                    className="buttonWoodGrid"
                    onClick={() => props.selectNft(nft[0])}
                  >
                    Select
                  </button>
                </div>
              ))}
            </div>
          </>
        ) : (
          <p className="whiteText">loading...</p>
        )
      ) : (
        <>
          <div className="space50"></div>
          <div className="centerMe">
            <PlugConnect
              whitelist={props.whitelist}
              onConnectCallback={async () => {
                props.setUsingPlug(true)
                props.setUsingStoic(false)
                props.setLoggedIn(true)
                let p = await window.ic.plug.agent.getPrincipal()
                props.setPrincipal(p.toText())
                let charActor = await props.loadActors(true, false, p.toText())
                console.log('loaded actors from onconnectcallback')
                await props.loadCharacters(charActor, p.toText())
              }}
            />
            <br></br>
          </div>
          <div className="centerMe">
            <button
              className={'buttonWoodGridXL'}
              onClick={async () => {
                await props.connectToStoic()
              }}
            >
              Connect to Stoic
            </button>
          </div>
          <br></br>
          <div className="space50"></div>
          <div className="centerMe">
            <img
              src="https://rbmwowza3.s3.amazonaws.com/uofu-vod/menu-fighter1a.png"
              alt="fighter1"
              height="200px"
            ></img>
          </div>
        </>
      )}
    </div>
  )
}

export default Home
