
// update this whenever deploying to ic or staging
export const network = 'local';

// update this whenever canisters change in local
const canisterIds = {
    local: {
        itemCanister: 'renrk-eyaaa-aaaaa-aaada-cai',
        characterCanister: 'rkp4c-7iaaa-aaaaa-aaaca-cai'
    },
    staging: {
        itemCanister: 'bavpk-lyaaa-aaaan-qc7bq-cai',
        characterCanister: 'bhuj6-gaaaa-aaaan-qc7ba-cai'
    },
    ic: {
        itemCanister: 'goei2-daaaa-aaaao-aaiua-cai',
        characterCanister: 'dhyds-jaaaa-aaaao-aaiia-cai'
    }
}

export const itemCanisterId = canisterIds[network]['itemCanister'];
export const characterCanisterId = canisterIds[network]['characterCanister'];