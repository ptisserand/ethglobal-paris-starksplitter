import { useMemo } from 'react';
import { useAccount, useConnectors } from '@starknet-react/core';
import { Box, Button, Card, CardBody, CardHeader, Flex, Heading } from '@chakra-ui/react';

const WalletConnected = () => {
    const { address } = useAccount()
    const { disconnect } = useConnectors()

    const shortenedAddress = useMemo(() => {
        if (!address) return ''
        return `${address.slice(0, 6)}...${address.slice(-4)}`
    }, [address])

    return (
        <div>
            <Flex alignItems="center" wrap="wrap" width="100%">
                <Card>
                    <CardHeader>
                        <Heading size="sm">Connected: {shortenedAddress}</Heading>
                    </CardHeader>
                    <CardBody>
                        <Button onClick={disconnect}>Disconnect</Button>
                    </CardBody>
                </Card>
            </Flex>
        </div>
    )
}

function ConnectWallet() {
    const { connectors, connect } = useConnectors()

    return (
        <div>
            <Flex alignItems="center" wrap="wrap" width="100%">
                {connectors.map((connector) => {
                    return (
                        <Box width="100px">
                            <Button key={connector.id} onClick={() => connect(connector)}>
                                {connector.id}
                            </Button>
                        </Box>
                    )
                })}
            </Flex>
        </div>
    )
}

export default function WalletBar() {
    const { address } = useAccount();
    return address ? <WalletConnected /> : <ConnectWallet />
}
