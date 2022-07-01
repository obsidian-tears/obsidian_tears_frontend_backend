import * as React from 'react'
import PlugConnect from '@psychedelic/plug-connect'
import '../../assets/main.css'

const Home = (props) => {
  return (
    <div id="body">
      <h2 className="title">Obsidian Tears</h2>

      {props.loggedIn ? (
        !props.loading ? (
          <>
            <button
              className="button-30"
              onClick={() =>
                window.open('https://entrepot.app/marketplace/obsidian-tears')
              }
            >
              Buy NFT for Game
            </button>
            <br></br>

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
                      height="100%"
                    ></img>
                  </a>
                  <button className="button-30" onClick={() => props.selectNft(nft[0])}>
                    select character
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
          <PlugConnect
            whitelist={props.whitelist}
            onConnectCallback={async () => {
              props.setUsingPlug(true)
              props.setUsingStoic(false)
              props.setLoggedIn(true)
              let p = await window.ic.plug.agent.getPrincipal()
              props.setPrincipal(p.toText())
              await props.loadActors(true, false, p.toText())
            }}
          />
          <br></br>
          <button
            className={'button-30'}
            onClick={async () => {
              await props.connectToStoic()
            }}
          >
            Connect to Stoic
          </button>
        </>
      )}
    </div>
  )
}

export default Home
