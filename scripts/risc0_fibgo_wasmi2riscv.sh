#!/bin/bash

PWD=${PWD}
RISC0=${PWD}/risc0/

FIB_N=10
# raw, rust fib wasm
SCRIPT_DIR=${PWD}/data/zkvm-wasmi
ZKVM_WASMI=${PWD}/bin/zkvm_wasmi
ZKVM_WASMI_CUDA=${PWD}/bin/zkvm_wasmi_cuda

GOROOT=${PWD}/go
ZKGO=$GOROOT/bin/zkgo
FIB_FILENAME="fib_zkgo.go"
FIB_PATH=$GOROOT/data/fib_zkgo.go
GO_FIB_WASM=${PWD}/bin/go_fib.wasm

cuda_enabled=0
if command -v nvcc >/dev/null 2>&1; then
    echo "nvcc installed"
    cuda_enabled=1
else
    cuda_enabled=0
fi


# 1. build zkgo
echo "==Build zkgo"
if [ -f "$ZKGO" ]; then
    echo -e "==$ZKGO exists. \n"
else
    echo "$ZKGO does not exist."
    cd $GOROOT/src
    git fetch
    git checkout feat/eths-grant-1 # try to remote it.
    ./all.bash
    mv $GOROOT/bin/go $ZKGO # The zkgo binary: go/bin/zkgo
    echo -e "built \n"
fi

# 2. compile `fib_go.go` into `fib.wasm`
echo -e "\n==Compile fib_go into fib.wasm by zkgo"
if [ -f "$GO_FIB_WASM" ]; then
    echo -e "==$GO_FIB_WASM exists. \n"
else
  echo $GOROOT
  export GOROOT=${GOROOT}
  cd ${PWD}/data
  GO111MODULE=off GOOS=wasip1 GOARCH=wasm $ZKGO build -gcflags=all=-d=softfloat -o $GO_FIB_WASM $FIB_FILENAME
  echo -e "compiled \n"
fi


cd $RISC0
#git reset --hard v0.19.1
git checkout feat/eths-grant-1
git pull

# 1. check and install risc0 toolchain
echo -e "\n==check risc0 toolchain"

result=$(ls ~/.cargo/bin | grep cargo-risczero)
#echo $result
if [ -z "$result" ]; then
    echo "Start install risczero toolchain"
    cargo install cargo-binstall
    cargo binstall cargo-risczero
    cargo risczero install
else
    echo "Already install risczero toolchain"
    ls ~/.cargo/bin
fi

echo "==build zkvm_wasmi"
export RUST_LOG=info
if [ -f "$ZKVM_WASMI" ]; then
    echo "==$ZKVM_WASMI and $ZKVM_WASMI_CUDA exist."
else
    echo "==$ZKVM_WASMI does not exist."
    cd $SCRIPT_DIR
    cargo build --release
    mv $SCRIPT_DIR/target/release/wasm $ZKVM_WASMI

    # Check if nvcc is installed
    if (($cuda_enabled==1)); then
        # cuda version
        cargo build --release -F cuda
        mv $SCRIPT_DIR/target/release/wasm $ZKVM_WASMI_CUDA
    else
        echo "nvcc not installed"
    fi
fi

# rs_wasmi_fib dry-run, proving
echo -e "\n==rs_wasmi_fib dry-run: cpu"
$ZKVM_WASMI --wasm $GO_FIB_WASM --public ${FIB_N}:i64 --method execute
echo -e "\n==CPU proving time"
time $ZKVM_WASMI --wasm $GO_FIB_WASM --public ${FIB_N}:i64 --method prove

# cuda
echo -e "\n==rs_wasmi_fib prove: cuda"
if (($cuda_enabled==1)); then
    $ZKVM_WASMI_CUDA --iterations $FIB_N --method prove
else
    echo "nvcc not installed"
fi

echo -e "\n==Finish zkvm rs_wasmi_fib"