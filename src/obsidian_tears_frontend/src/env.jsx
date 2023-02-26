
// update this whenever deploying to ic
export const network = 'local';

// update this whenever canisters change (especially in local)
const canisterIds = {
    local: {
        itemCanister: 'renrk-eyaaa-aaaaa-aaada-cai',
        characterCanister: 'rkp4c-7iaaa-aaaaa-aaaca-cai'
    },
    ic: {
        itemCanister: 'goei2-daaaa-aaaao-aaiua-cai',
        characterCanister: 'dhyds-jaaaa-aaaao-aaiia-cai'
    }
}

export const itemCanisterId = canisterIds[network]['itemCanister'];
export const characterCanisterId = canisterIds[network]['characterCanister'];