import React from 'react';
import { InjectedConnector, StarknetConfig } from '@starknet-react/core';
import { ChakraProvider, Container, Heading, SimpleGrid, Stack, Text } from '@chakra-ui/react';

import { GIT_REVISION } from './revision';
import './App.css';
import Deployer from './components/Deployer';
import Releaser from './components/Releaser';
import WalletBar from './components/WalletBar';


const AppDisplay = () => {
  const connectors = [
    new InjectedConnector({ options: { id: 'braavos' } }),
    new InjectedConnector({ options: { id: 'argentX' } }),
  ]

  return (
    <StarknetConfig autoConnect connectors={connectors}>
      <Stack>
        <Heading>Payment splitter</Heading>
        <WalletBar></WalletBar>
        <SimpleGrid columns={2}>
          <Deployer></Deployer>
          <Releaser></Releaser>
        </SimpleGrid>
      </Stack>
    </StarknetConfig>
  )
}

function App() {

  return (
    <>
      <ChakraProvider>
        <AppDisplay></AppDisplay>
        <Container>
          <Text>{GIT_REVISION}</Text>
        </Container>
      </ChakraProvider>
    </>
  );
}

export default App;
