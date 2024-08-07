import * as React from "react";

const StoicErrorCard = () => {
  return (
    <div className="w-full flex justify-center">
      <div className="w-5/6 lg:w-1/2 max-w-96 h-full">
        <div className="bg-red-500 text-white font-bold rounded-t px-4 py-2 flex flex-col">
          There was an error with Stoic Wallet
        </div>
        <div className="border border-t-0 border-red-400 rounded-b bg-red-100 px-4 py-3 text-left text-red-700">
          <p>
            The most probable cause is due to a new feature in Chrome that is
            incompatible with Stoic Wallet.
          </p>
          <br />
          <p>
            To fix this issue, follow the steps mention on their{" "}
            <a
              href="https://x.com/stoicwalletapp/status/1706317772194517482?s=46&t=4XqsIm2zxxeH9ADUYAWcfQ"
              target="_blank"
              className="text-blue-500 underline"
              rel="noreferrer"
            >
              X post
            </a>
            :{" "}
          </p>
          <ul>
            <li>1. Open a new tab.</li>
            <li>
              2. Go to{" "}
              <strong>
                <i>chrome://flags/#third-party-storage-partitioning</i>
              </strong>
              .
            </li>
            <li>3. Disable the feature and restart your browser.</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default StoicErrorCard;
