import { Box, Button, Card, CardBody, CardHeader, Flex, Heading, Input, Text, VStack } from "@chakra-ui/react"
import { useAccount, useContractWrite } from "@starknet-react/core"
import { useMemo, useState } from "react";
import { getContractAddress } from "../config";

const Releaser = () => {
    const { account } = useAccount();
    const [address, setAddress] = useState<string>("");
    
    const calls = useMemo(() => {
        return {
            contractAddress: getContractAddress(),
            entrypoint: 'release',
            calldata: [address],
        }
    }, [address]);
    
    const {write } = useContractWrite({
        calls
    })

    const release = async () => {
        write();
    }

    return (
        <>
            <Card>
                <CardHeader>
                    <Box><Button disabled={account === undefined} onClick={release}>Release!</Button></Box>
                </CardHeader>
                <CardBody>
                    <VStack width="100%">
                        <Flex alignItems="center" wrap="wrap" width="100%">
                            <Box width="150px"><Heading alignSelf="center" size="sm">Address</Heading>
                            </Box>
                            <Box>
                                <Input type="string" value={address} onChange={(e) => setAddress(e.target.value)}></Input>
                            </Box>
                        </Flex>
                    </VStack>
                </CardBody>
            </Card></>
    )
}

export default Releaser;
