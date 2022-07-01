import * as React from "react";
import { Unity } from "react-unity-webgl";
import "../../assets/main.css";

const Game = (props) => {
  const loadingPercentage = Math.round(props.loadingProgression * 100);

  return (
      <div className="unityContainer">
        {props.isLoaded === false && (
          // We'll conditionally render the loading overlay if the Unity
          // Application is not loaded.
          <div className="loading-overlay">
            <p>Loading... ({loadingPercentage}%)</p>
          </div>
        )}
        <Unity className="unity" unityProvider={props.unityProvider} />
      </div>
  );
};

export default Game;
