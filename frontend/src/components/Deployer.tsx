import { AddIcon, DeleteIcon } from "@chakra-ui/icons";
import { Box, Button, Card, CardBody, CardHeader, Flex, Heading, IconButton, Input, Link, VStack } from "@chakra-ui/react"
import { useAccount, useProvider } from "@starknet-react/core";
import { useState } from "react";
import { ENV_CLASS_HASH, ENV_ERC20_ADDR } from "../config";

type _Payee = {
    address: string;
    shares: number;
}

interface PayeeProp {
    payee: _Payee,
    onClick: () => void
}

const PayeeDisplay: React.FC<PayeeProp> = ({ payee, onClick }) => {
    return (
        <>
            <Flex alignItems="center" wrap="wrap" width="100%">
                <Box width="200px"><Heading alignSelf="center" size="sm">{`${payee.address.slice(0, 6)}...${payee.address.slice(-4)}`}</Heading>
                </Box>
                <Box width="50px">
                    <Heading size="sm">{payee.shares}</Heading>
                </Box>
                <Box>
                    <IconButton aria-label="Remove" onClick={onClick}><DeleteIcon></DeleteIcon></IconButton>
                </Box>
            </Flex>
        </>
    )
}

const Deployer = () => {
    const { account } = useAccount();
    const { provider } = useProvider();

    const [payees, setPayees] = useState<_Payee[]>([]);
    const [address, setAddress] = useState<string>("");
    const [shares, setShares] = useState<number>(0);
    const [lastAddress, setLastAddress] = useState("");

    const deploy = async () =>  {
        if (account === undefined) {
            return;
        }
        let addressData = payees.map((e) => e.address);
        let sharesData = payees.map((e) => e.shares);
        try {
        const deployedResponse = await account.deployContract({
            classHash: ENV_CLASS_HASH,
            constructorCalldata: [ENV_ERC20_ADDR, addressData.length, ...addressData, sharesData.length, ...sharesData],
        });
        await provider.waitForTransaction(deployedResponse.transaction_hash);
        setLastAddress(deployedResponse.contract_address);

    } catch(e) {
        console.error(e);
    }
    }

    const handleAdd = () => {
        setPayees(oldList => [...oldList, { address: address, shares: shares }]);
    }

    const handleRemove = (address: String) => {
        setPayees(oldList => oldList.filter((e) => e.address !== address));
    }

    return (
        <>
            <Card>
                <CardHeader>
                    <Box><Button disabled={account === undefined} onClick={deploy}>Deploy!</Button></Box>
                    <Heading size="sm">
                        <Link isExternal={true}
                        href={`https://testnet.starkscan.co/contract/${lastAddress}`}
                        >{lastAddress}</Link>
                        </Heading>
                </CardHeader>
                <CardBody>
                    <VStack width="100%">
                        {payees.map((elem) => {
                            return (
                                <PayeeDisplay key={elem.address} payee={elem} onClick={() => handleRemove(elem.address)}></PayeeDisplay>
                            )
                        })}
                        <Flex alignItems="center" wrap="wrap" width="100%">
                            <Box width="150px"><Heading alignSelf="center" size="sm">Address</Heading>
                            </Box>
                            <Box>
                                <Input type="string" value={address} onChange={(e) => setAddress(e.target.value)}></Input>
                            </Box>
                        </Flex>
                        <Flex alignItems="center" wrap="wrap" width="100%">
                            <Box width="150px">
                                <Heading alignSelf="center" size="sm">Shares</Heading>
                            </Box>
                            <Box>
                                <Input type="number" value={shares} onChange={(e) => setShares(parseInt(e.target.value))}></Input>
                            </Box>
                        </Flex>
                        <IconButton aria-label="Add"
                            onClick={() => handleAdd()}
                            icon={<AddIcon />} />
                    </VStack>
                </CardBody>
            </Card></>
    )
}

export default Deployer;
