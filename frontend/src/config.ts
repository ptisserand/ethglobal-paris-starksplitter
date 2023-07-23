export const ENV_CLASS_HASH = process.env.REACT_APP_CLASS_HASH ?? '0x0507c819b71556106065fd4e02556ef1a35d6ff2af04e34fbf3d508d185077eb';
export const ENV_ERC20_ADDR = process.env.REACT_APP_ERC20_ADDR ?? '0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7';

let contractAddress = '';

export const updateContractAddress = (addr: string) => {
    contractAddress = addr;
}

export const getContractAddress = () => contractAddress;
