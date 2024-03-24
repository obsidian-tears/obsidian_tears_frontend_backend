#!/bin/sh

# REQUIREMENTS
# - on another tab you already did "dfx start" (--clean)
# - you have a parent folder (like "obsidian")
# - and the children are all the dependent repos (like game, hero, item, frontend/backend).

# SCRIPT SUMMARY
# - go through all folders / repo
# - on each, do dfx deploy

dfx deploy
cd ..
cd obsidian_tears_hero_nft
dfx deploy
dfx canister call obsidian_tears_nft _mintAndTransferDevHero $(dfx identity get-principal)
dfx canister call obsidian_tears_nft _mintAndTransferDevHero $(dfx identity get-principal)
cd ..
cd obsidian_tears_items_nft
dfx deploy
cd ..
cd obsidian_tears_game/Webserver
dfx deploy

echo ""
echo "Finished Deploy Local Script"
echo ""