help: ## Display this help screen
	@grep -h \
		-E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

pull: ## Pull all the recursive submodule
	@git submodule update --init --recursive

clean_data: ## clean the cached data
	@rm data/*

clean_bin: ## clean the cached bin
	@rm go/bin/*
	@rm bin/*

prepare: ## libs and tools on ubuntu
	@sudo apt install libssl-dev
	@sudo apt install pkg-config
	@curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sudo sh
	@cargo install cargo-binstall
	@cargo binstall cargo-risczero@0.19.1
	@cargo risczero install


path: ## Export bin to env path.
	@bash export_path.sh



.PHONY: clippy doc fmt test test_benches test-all evm_bench state_bench circuit_benches help
