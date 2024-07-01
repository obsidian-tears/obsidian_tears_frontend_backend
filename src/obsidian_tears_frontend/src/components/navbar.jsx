import * as React from "react";

const backgroundImageWood2 = { backgroundImage: "url(button-wood-2.png)" };

const Navbar = (props) => {
  return (
    <div className="w-full h-20 absolute top-0 pt-3">
      <div className="float-left pt-2 pr-2 pb-2 pl-5">
        <img alt="logo" src="icp-badge.png" className="h-12"></img>
      </div>
      <div className="float-right p-2">
        <button
          className="h-12 w-40 items-center appearance-none text-white text-2xl font-semibold font-title pl-2 pr-2 mr-5 justify-center list-none overflow-hidden border-0 inline-flex leading-4 relative"
          style={backgroundImageWood2}
          onClick={() => window.open("https://obsidiantears.xyz")}
        >
          Website
        </button>
        <button
          className="h-12 w-40 items-center appearance-none text-white text-2xl font-semibold font-title pl-2 pr-2 mr-5 justify-center list-none overflow-hidden border-0 inline-flex leading-4 relative"
          style={backgroundImageWood2}
          onClick={() =>
            window.open("https://entrepot.app/marketplace/obsidian-tears")
          }
        >
          Shop NFTs
        </button>
        {props.logout && (
          <div className="float-right">
            <button
              className="h-12 w-40 items-center appearance-none text-white text-2xl font-semibold font-title pl-2 pr-2 mr-5 justify-center list-none overflow-hidden border-0 inline-flex leading-4 relative"
              style={backgroundImageWood2}
              onClick={async () => await props.logout()}
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
