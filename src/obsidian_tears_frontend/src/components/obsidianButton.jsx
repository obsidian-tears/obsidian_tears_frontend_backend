import * as React from "react";

const ObsidianButton = ({ buttonText, clickCallback, extraClasses }) => {
  return (
    <button
      className={
        "text-white text-lg font-mochiy uppercase w-40 px-4 py-2 border-0 bg-cover bg-center focus:outline-none focus:ring focus:ring-yellow-900 hover:transform hover:translate-y-[-2px] active:transform active:translate-y-[2px] " +
        extraClasses
      }
      style={{ backgroundImage: "url(button-wood-2.png)" }}
      onClick={clickCallback}
    >
      {buttonText}
    </button>
  );
};

export default ObsidianButton;
