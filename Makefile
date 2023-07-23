.PHONY: contracts setup

setup: contracts
	./scripts/setup.bash

contracts:
	make -C contracts

