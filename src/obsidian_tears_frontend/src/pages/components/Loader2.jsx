import "./Loader2.scss";

import React from "react";

import image from "./obsidian2d.jpg";
import logo_icp from "./icp_white.png";

const selectedImage =image ;

console.log(selectedImage);

const Loader2 = ({ loadingProgression }) => {
  const percentage = () => Math.round(loadingProgression * 100);

  return (
    <div
      style={{
        backgroundImage: `url(${selectedImage})`,
        backgroundSize: "cover",
        
        width: "100%",
        height: "100%",
        zIndex: 10000,
      }}className="body"
    >
      <article className="loader_container">
        <div className="loader-wrapper">
          <div className="loader">
            <div className="roller r1"></div>
            <div className="roller r2"></div>
          </div>

          <div id="loader2" className="loader">
            <div className="roller r3"></div>
            <div className="roller r4"></div>
          </div>

          <div id="loader3" className="loader">
            <div className="roller r5"></div>
            <div className="roller r6"></div>
          </div>
        </div>
        <span className="percent">{percentage()}%</span>
      </article>
      <div className="logos">
        <div className="tbfz img-container">
        </div>
      </div>
      <div className="footer">
        <p>POWERED BY</p>
        <img src={logo_icp} alt="" />
      </div>  
    </div>
  );
};

export default Loader2;
