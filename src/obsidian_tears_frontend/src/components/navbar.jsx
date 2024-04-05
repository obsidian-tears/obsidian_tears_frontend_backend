import * as React from "react";

const backgroundImageWood2 = { backgroundImage: "url(button-wood-2.png)" };

const Navbar = (props) => {
  return (
    <div id="header">
      <div className="leftHeader">
        <img alt="logo" src="icp-badge.png" height="50"></img>
      </div>
      <div className="rightHeader">
        <button
          className="buttonWood"
          style={backgroundImageWood2}
          onClick={() => window.open("https://obsidiantears.xyz")}
        >
          Website
        </button>

        <button
          className="buttonWood"
          style={backgroundImageWood2}
          onClick={() =>
            window.open("https://entrepot.app/marketplace/obsidian-tears")
          }
        >
          Shop NFTs
        </button>

        {props.loggedInWith !== "" && (
          <div className="rightHeader2">
            <button
              className="buttonWood"
              style={backgroundImageWood2}
              onClick={() => props.logout()}
            >
              Logout
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default Navbar;
