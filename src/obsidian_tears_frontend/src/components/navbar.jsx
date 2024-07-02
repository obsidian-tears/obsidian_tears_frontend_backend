import * as React from "react";

const Navbar = (props) => {
  return (
    <div className="flex justify-center items-center w-full pt-4 pb-4 pl-7 pr-7">
      <div className="flex justify-center lg:mr-4">
        <img alt="logo" src="header_logo.png" className="w-20"></img>
      </div>
      <div className="hidden lg:flex items-center">
        <img
          alt="logo"
          src="header_text_logo.png"
          className="h-7 xl:h-14"
        ></img>
      </div>
      <div className="flex last-of-type:ml-auto">
        <div className="flex flex-col lg:flex-row w-full">
          <button
            className="bg-button-brown uppercase text-white font-semibold text-md lg:text-lg font-title pl-2 pr-2 mb-1 rounded-2xl lg:mr-3 lg:pt-4 lg:pb-4 lg:pr-4 lg:pl-4"
            onClick={() => window.open("https://obsidiantears.xyz")}
          >
            Shop NFT Heroes
          </button>
          <button
            className="bg-button-brown uppercase text-white font-semibold text-md lg:text-lg font-title pl-2 pr-2 mb-1 rounded-2xl lg:mr-3 lg:pt-4 lg:pb-4 lg:pr-4 lg:pl-4"
            onClick={() =>
              window.open("https://entrepot.app/marketplace/obsidian-tears")
            }
          >
            Shop NFT Items
          </button>
          {props.logout && (
            <div className="float-right">
              <button
                className="bg-button-brown uppercase text-white font-semibold text-md lg:text-lg font-title pl-2 pr-2 mb-1 rounded-2xl lg:pt-4 lg:pb-4 lg:pr-4 lg:pl-4 lg:mr-8"
                onClick={async () => await props.logout()}
              >
                Logout
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Navbar;
