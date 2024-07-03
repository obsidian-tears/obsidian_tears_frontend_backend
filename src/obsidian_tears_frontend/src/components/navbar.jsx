import * as React from "react";
import { useRef, useState } from "react";
import { GiHamburgerMenu } from "react-icons/gi";
import { AnimatePresence, motion } from "framer-motion";
import { useClickAway } from "react-use";
import { AiOutlineRollback } from "react-icons/ai";
import { CgLogOut } from "react-icons/cg";
import { FiShoppingCart } from "react-icons/fi";

const Navbar = (props) => {
  const [open, setOpen] = useState(false);
  const ref = useRef(null);
  useClickAway(ref, () => setOpen(false));
  const toggleSidebar = () => setOpen((prev) => !prev);

  return (
    <nav className="flex justify-start w-full py-4 px-10 overflow-hidden">
      {/* LOGO */}
      <img alt="logo" src="header_logo.png" className="w-20 h-20"></img>
      <h1 className="uppercase font-mochiy hidden sm:flex items-center pl-4 text-4xl lg:text-xl xl:text-4xl text-white">
        obsidian tears
      </h1>
      {/* MOBILE UI WITH SIDEBAR & HAMBURGER MENU */}
      <button
        onClick={toggleSidebar}
        className="last-of-type:ml-auto lg:hidden"
        aria-label="toggle sidebar"
      >
        <GiHamburgerMenu className="text-white" size={30} />
      </button>
      <AnimatePresence mode="wait" initial={false}>
        {open && (
          <>
            <motion.div
              {...framerSidebarPanel}
              className="fixed top-0 bottom-0 right-0 z-50 w-full h-screen max-w-xs border-l-2 border-white bg-regal-blue"
              ref={ref}
              aria-label="Sidebar"
            >
              <div className="flex items-center justify-between p-5 border-b-2 border-white text-white bg-regal-blue">
                <span className="text-white font-mochiy">Welcome</span>
                <button
                  onClick={toggleSidebar}
                  className="p-3 border-2 border-white rounded-xl text-white"
                  aria-label="close sidebar"
                >
                  <AiOutlineRollback />
                </button>
              </div>
              <ul>
                {items.map((item, idx) => {
                  const { title, href, Icon } = item;
                  if (item.title === "Logout" && !props.logout) return;
                  return (
                    <li key={title}>
                      <a
                        onClick={toggleSidebar}
                        href={href}
                        className="flex items-center justify-between gap-5 p-5 transition-all border-b-2 hover:bg-zinc-900 border-white text-white font-mochiy"
                      >
                        <motion.span {...framerText(idx)}>{title}</motion.span>
                        <motion.div {...framerIcon}>
                          <Icon className="text-2xl" />
                        </motion.div>
                      </a>
                    </li>
                  );
                })}
              </ul>
            </motion.div>
          </>
        )}
      </AnimatePresence>
      {/* DESKTOP UI WITH BUTTONS */}
      <div className="ml-auto my-auto hidden lg:block">
        <button
          className="bg-button-brown hover:bg-yellow-900 active:bg-yellow-950 focus:outline-none focus:ring focus:ring-yellow-900 uppercase text-white text-lg font-mochiy px-4 py-2 rounded-2xl"
          onClick={() =>
            window.open("https://entrepot.app/marketplace/obsidian-tears")
          }
        >
          Shop NFT Heroes
        </button>
        <button
          className="bg-button-brown hover:bg-yellow-900 active:bg-yellow-950 focus:outline-none focus:ring focus:ring-yellow-900 uppercase text-white text-lg font-mochiy px-4 py-2 mx-4 rounded-2xl"
          onClick={() =>
            window.open("https://entrepot.app/marketplace/obsidian-tears")
          }
        >
          Shop NFT Items
        </button>
        {props.logout && (
          <div className="float-right">
            <button
              className="bg-button-brown hover:bg-yellow-900 active:bg-yellow-950 focus:outline-none focus:ring focus:ring-yellow-900 uppercase text-white text-lg font-mochiy px-4 py-2 rounded-2xl"
              onClick={async () => await props.logout()}
            >
              Logout
            </button>
          </div>
        )}
      </div>
    </nav>
  );
};

const items = [
  {
    title: "Shop NFT Heroes",
    Icon: FiShoppingCart,
    href: "https://entrepot.app/marketplace/obsidian-tears",
  },
  {
    title: "Shop NFT Items",
    Icon: FiShoppingCart,
    href: "https://entrepot.app/marketplace/obsidian-tears",
  },
  { title: "Logout", Icon: CgLogOut },
];

const framerSidebarPanel = {
  initial: { x: "100%" },
  animate: { x: 0 },
  exit: { x: "100%" },
  transition: { duration: 0.3 },
};

const framerText = (delay) => {
  return {
    initial: { opacity: 0, x: -50 },
    animate: { opacity: 1, x: 0 },
    transition: {
      delay: 0.5 + delay / 10,
    },
  };
};

const framerIcon = {
  initial: { scale: 0 },
  animate: { scale: 1 },
  transition: {
    type: "spring",
    stiffness: 260,
    damping: 20,
    delay: 1.5,
  },
};

export default Navbar;
