import * as React from "react";
import ClipLoader from "react-spinners/ClipLoader";

export const ObsidianButton = ({ buttonText, clickCallback, extraClasses }) => {
  return (
    <button
      className={
        "text-white text-lg font-mochiy uppercase w-40 px-4 py-2 border-0 bg-cover bg-center focus:outline-none focus:ring focus:ring-yellow-900 hover:transform hover:translate-y-[-2px] active:transform active:translate-y-[2px] " +
        extraClasses
      }
      style={{ backgroundImage: "url(button-wood.png)" }}
      onClick={clickCallback}
    >
      {buttonText}
    </button>
  );
};

export const LargeObsidianButton = ({
  buttonText,
  clickCallback,
  extraClasses,
}) => {
  return (
    <button
      className={
        "text-white text-lg font-mochiy uppercase w-2/3 px-4 py-3 my-3 border-0 bg-cover bg-center focus:outline-none focus:ring focus:ring-yellow-900 hover:transform hover:translate-y-[-2px] active:transform active:translate-y-[2px] " +
        extraClasses
      }
      style={{ backgroundImage: "url(button-wood-large.png)" }}
      onClick={clickCallback}
    >
      {buttonText}
    </button>
  );
};

export const ObsidianButtonWithLoader = ({
  buttonText,
  clickCallback,
  extraClasses,
  isLoading,
  disabled,
}) => {
  return (
    <button
      className={
        "text-white text-lg font-mochiy uppercase w-40 px-4 py-2 border-0 bg-cover bg-center focus:outline-none focus:ring focus:ring-yellow-900 hover:transform hover:translate-y-[-2px] active:transform active:translate-y-[2px] " +
        extraClasses
      }
      style={{ backgroundImage: "url(button-wood.png)" }}
      onClick={clickCallback}
      disabled={disabled}
    >
      {buttonText}
      <ClipLoader className="ml-2" size={20} loading={isLoading} color="gray" />
    </button>
  );
};
