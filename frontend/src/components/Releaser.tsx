import { Button, Card, CardBody, CardHeader, Heading, Text, VStack } from "@chakra-ui/react"

const Releaser = () => {
    return (
        <>
            <Card>
                <CardHeader>
                    <Heading>Release</Heading>
                </CardHeader>
                <CardBody>
                    <VStack>
                        <Text>ADDRESS</Text>
                        <Button>Release</Button>
                    </VStack>
                </CardBody>
            </Card>
        </>
    )
}

export default Releaser;
