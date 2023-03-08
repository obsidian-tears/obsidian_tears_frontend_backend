// update this whenever deploying to ic or staging
export const network = 'local';

// update this whenever canisters change in local
const canisterIds = {
    local: {
        itemCanister: 'renrk-eyaaa-aaaaa-aaada-cai',
        characterCanister: 'rkp4c-7iaaa-aaaaa-aaaca-cai',
        unityCanister: 'sp3hj-caaaa-aaaaa-aaajq-cai'
    },
    staging: {
        itemCanister: 'bavpk-lyaaa-aaaan-qc7bq-cai',
        characterCanister: 'bhuj6-gaaaa-aaaan-qc7ba-cai',
        unityCanister: 'dipqp-zyaaa-aaaan-qc7nq-cai'
    },
    ic: {
        itemCanister: 'goei2-daaaa-aaaao-aaiua-cai',
        characterCanister: 'dhyds-jaaaa-aaaao-aaiia-cai',
        unityCanister: 'wmq2b-baaaa-aaaal-acata-cai'
    }
}

const buildUnityUrls = () => {
    let host, query;
    if (network == 'local') {
        host = "http://127.0.0.1:4943/";
        query = "?canisterId=" + canisterIds[network]['unityCanister'];
    }
    else { // ic or staging
        host = "https://" + canisterIds[network]['unityCanister'] + ".ic0.app/";
        query = "";
    }

    return {
        loaderUrl: host + 'unity/Build/Desktop.loader.js' + query,
        dataUrl: host + 'unity/Build/Desktop.data' + query,
        frameworkUrl: host + 'unity/Build/Desktop.framework.js' + query,
        codeUrl: host + 'unity/Build/Desktop.wasm' + query
    };
}

export const itemCanisterId = canisterIds[network]['itemCanister'];
export const characterCanisterId = canisterIds[network]['characterCanister'];
export const unityUrls = buildUnityUrls();