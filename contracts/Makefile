.PHONY: contract clean

CONTRACT=src/splitter.cairo
CONTRACT_SIERRA=target/dev/splitter_Splitter.sierra.json

contract: ${CONTRACT_SIERRA}

${CONTRACT_SIERRA}: ${CONTRACT}
	scarb build

clean:
	-rm -rf ./target
