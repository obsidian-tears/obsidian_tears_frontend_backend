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
# mint dfx local account
dfx canister call obsidian_tears_nft _mintAndTransferDevHero $(dfx ledger account-id)
dfx canister call obsidian_tears_nft _mintAndTransferDevHero $(dfx ledger account-id)
# mint tiago's stoic account
# dfx canister call obsidian_tears_nft _mintAndTransferDevHero a765d8880dfe17261497cfa6fef5d0a7cdd29272c45277b9ef07f72540d04e82
# dfx canister call obsidian_tears_nft _mintAndTransferDevHero a765d8880dfe17261497cfa6fef5d0a7cdd29272c45277b9ef07f72540d04e82
# mint davids/jackons plug account
dfx canister call obsidian_tears_nft _mintAndTransferDevHero 75bf6cd4a359ab4ff8a082801f7423e82559f85dd03bf027d8adc5480e2431ce
dfx canister call obsidian_tears_nft _mintAndTransferDevHero 75bf6cd4a359ab4ff8a082801f7423e82559f85dd03bf027d8adc5480e2431ce
cd ..
cd obsidian_tears_items_nft
dfx deploy
cd ..
cd obsidian_tears_game/Webserver
dfx deploy

echo ""
echo "Finished Deploy Local Script"
echo ""