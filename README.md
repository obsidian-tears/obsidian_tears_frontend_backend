# Obsidian Tears Frontend and Backend

Obsidian Tears is an RPG on the Internet Computer. This project contains the game backend and frontend canisters. The game is built in Unity, packaged in WebGL, and displayed via React.

The backend canister contains all game data. Loss of data will result in players losing saved progress, gold, xp, stats, non-nft items, etc. Proceed with caution.

These canisters interact with several other canisters, including the obsidian tears character nft canister and obsidian tears items nft canister. Be aware that if the interface of these nft canisters changes, it may break this canister as a result.

## How to update unity build

- 1 - On Unity Hub. File -> Build -> WebGL, double check if options make sense.
- 2 - Go to obsidian_tears repo (probably by opening VS Code), open terminal and write:
- 3 - "git status" (ensure no file was added, if so, do "git checkout .")
- 4 - "git pull origin main" (this will update your branch to most recent version of main)
- 5 - delete current build files (obsidian_tears -> src -> obsidian_tears_frontend -> assets -> unity)
- 6 - copy/move there the current build files
- 7 - commit and push to github (it will launch action to deploy the committed build)

Video showing these steps (no sound): https://www.loom.com/share/f107b84b9638409da4e176ed692ca49c

# Local Setup

- create a "parent" folder (like "obsidian")
- install git-lfs (see section below)
- git clone all 4 repos (see list below)
- on this repo, solve the Psychadelic Package issue (see section below)
- npm install & mops install on all that need
- on all env.mo files, add your dfx principal to the Admins array
- on this repo, scripts/deploy-all-local.sh file, add your account to the hero nft mint
- on this repo, do "npm run local"

## Install GIT Large File Storage (LFS) for OT Game

OT Game stores a lot of assets and builds in GIT directly, in order to properly clone / download repo you need to have installed the extension of git, called git-lfs. More info: https://git-lfs.com/

## How to solve the Psychedelic Package token issue

`npm install` won't work until you generate an access token to github. Go to this section and follow instructions: https://github.com/Psychedelic/plug-connect?tab=readme-ov-file

## Order of creation on local network

The IC is deterministic, so if the order of canisters created on a network (after `dfx start --clean`) is the same, it will end up with the same canister IDs.

The order is:

1. OT Frontend & Backend (bd3sg-teaaa-aaaaa-qaaba-cai, bkyz2-fmaaa-aaaaa-qaaaq-cai);
2. OT Hero NFT (br5f7-7uaaa-aaaaa-qaaca-cai);
3. OT Items NFT (b77ix-eeaaa-aaaaa-qaada-cai);
4. OT Game -> Webserver (avqkn-guaaa-aaaaa-qaaea-cai);

# Minting Roadmap

Desired "minting" UX:

1. User plays game, and every time a new item is added to inventory,
2. the "mintItem" (ReactController) call is sent to frontend.
3. Frontend does:

   - calls query to backend to know if ID has already been max minted or not.
   - if ID is unknown, console.error it (and allow Sentry to log it) and return error to game.
   - Only do update calls on items expected to be minted.

4. Backend does:

   - decrypt item id;
   - get MintItemRegistry(hero_id), check how many times id has been minted;
   - get max times it can be minted from MintItemReference;
   - if times it has been minted < max times, allow to proceed to mint (else return error with message)
   - for minting: call Item NFT Canister, request to mint (ID, Account ID).
   - on error, add to failedMintQueue to be retried later by timer.
   - update MintItemRegistry and always return success.

5. Backend confirms if more can be minted and returns success or error.
   - On success, show in game UI;
   - On error, don't show in game, to avoid bothering. Or show in grey, lower end, informing the error message ("item previously minted on this NFT (1/1)");

Other Requirements:

- It should not be possible to mint more than expected (Backend holds a record of IDs per hero NFT).
- It should not be easy to impersonate Unity game / React Controller (the token index should be encrypted with a private key that only unity and backend knows of).

Desired "consuming" UX:

1. User has items NFTs associated with same Account that holds HERO NFT (through minting or through purchasing on Entrepot Marketplace.)
2. After choosing an Hero NFT, if Items NFTs exist, a "Consume Items" UI will appear, showing all Item NFTs that exist on that account and therefore can be "consumed". A "consume" button appears below each Item NFT.
3. If user clicks on "Consume" button, it will "spin" and do the consume actions:

   - call backend "consumeItem(id)";
   - backend requests ItemNFT canister to burn NFT;
   - backend adds id to "consumedQueue" of that Hero NFT. Returns success.
   - Spinner stops and success message is shown ("Item consumed, it will be in Inventory when you load game.")
   - User can repeat action on other items;

4. If user clicks on "Continue to Game" button, it moves on to start the game.
5. When user clicks on LoadGame (on Menu or inside game):
   - After backend checks if a saved game exists, it will check if any items exist in "consumedQueue";
   - If no, move on. If yes, then parse string and find position of "inventory:", then add the each of the new ids to the beginning of the string;
   - return final string as the game load response;

Cards for Minting UX:

- Unity, add secret of Private Key added on build arg. Add encryption function;
- Unity, call "MintItem" (encryptedItemId, object) and listen for result;
- Unity, handle success with "minted notification" and "error" with greyed out notification.
- Backend, create MintItemRegistry(Hero ID) and allow it to be "get" with Max Items Reference.
- Backend, create failedMintQueue and add retry Timer and query call.
- Backend, create update call of MintItem(Hero NFT Index, encryptedItemId, auth token), full code.
- Frontend, handle MintItem call, do query, then update and handle error cases.

Cards for Consuming UX:

- TODO;

---

# Generic IC instructions

Welcome to your new obsidian_tears project and to the internet computer development community. By default, creating a new project adds this README and some template files to your project directory. You can edit these template files to customize your project and to include your own code to speed up the development cycle.

To get started, you might want to explore the project directory structure and the default configuration file. Working with this project in your development environment will not affect any production deployment or identity tokens.

To learn more before you start working with obsidian_tears, see the following documentation available online:

- [Quick Start](https://sdk.dfinity.org/docs/quickstart/quickstart-intro.html)
- [SDK Developer Tools](https://sdk.dfinity.org/docs/developers-guide/sdk-guide.html)
- [Motoko Programming Language Guide](https://sdk.dfinity.org/docs/language-guide/motoko.html)
- [Motoko Language Quick Reference](https://sdk.dfinity.org/docs/language-guide/language-manual.html)
- [JavaScript API Reference](https://erxue-5aaaa-aaaab-qaagq-cai.raw.ic0.app)

If you want to start working on your project right away, you might want to try the following commands:

```bash
cd obsidian_tears/
dfx help
dfx config --help
```

## Running the project locally

If you want to test your project locally, you can use the following commands:

```bash
# Starts the replica, running in the background
dfx start

# Deploys your canisters to the replica and generates your candid interface
dfx deploy
```

Once the job completes, your application will be available at `http://localhost:4943?canisterId={asset_canister_id}`.

Additionally, if you are making frontend changes, you can start a development server with

```bash
npm start
```

Which will start a server at `http://localhost:4943`, proxying API requests to the replica at port 4943.
