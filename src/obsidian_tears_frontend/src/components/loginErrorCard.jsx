import * as React from "react";

const LoginErrorCard = () => {
  return (
    <div className="w-full flex justify-center">
      <div className="w-5/6 lg:w-1/2 max-w-96 h-full">
        <div className="bg-red-500 text-white font-bold rounded-t px-4 py-2 flex flex-col">
          Unexpected Login Error
        </div>
        <div className="border border-t-0 border-red-400 rounded-b bg-red-100 px-4 py-3 text-left text-red-700">
          <p>An unexpected error ocurred while trying to fetch your NFTs.</p>
          <br />
          <p>
            Kindly reach out to our team in{" "}
            <a
              href="https://discord.gg/YSVjpTtGHq"
              target="_blank"
              className="text-blue-500 underline"
              rel="noreferrer"
            >
              Discord
            </a>{" "}
            for support.
          </p>
        </div>
      </div>
    </div>
  );
};

export default LoginErrorCard;
