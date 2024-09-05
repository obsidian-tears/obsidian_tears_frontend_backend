import ReactGA from "react-ga4";

const TRACKING_ID = "G-CYYDPL4LLL";

export const initAnalytics = () => {
  ReactGA.initialize(TRACKING_ID);
};

export const loggedInEvent = (loggedInWith, principal) => {
  ReactGA.set({ userId: principal });
  ReactGA.event("login", { method: loggedInWith });
};

export const showedNFTsEvent = (nfts) => {
  if (nfts.length == 0) {
    ReactGA.event("generate_lead", { currency: "USD", value: 40 });
  } else {
    ReactGA.event("close_convert_lead", { currency: "USD", value: 40 });
    const parsedNfts = nfts.map((nft) => {
      return { item_id: nft[0] };
    });
    ReactGA.event("view_item_list", {
      item_list_id: "HERO NFT",
      items: parsedNfts,
    });
  }
};

export const downloadStartedEvent = () => {
  ReactGA.event("level_start", { level_name: "download" });
};

export const downloadEndedEvent = () => {
  ReactGA.event("level_start", { level_name: "chapter1" });
};

export const gameSavedEvent = () => {
  ReactGA.event("select_content", { content_type: "saved_game" });
};

export const gameLoadedEvent = () => {
  ReactGA.event("select_content", { content_type: "loaded_game" });
};
