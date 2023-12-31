#!/bin/bash

PWD=${PWD}
RISC0=${PWD}/risc0/

FIB_N=900
# raw, rust fib wasm
SCRIPT_DIR=${PWD}/data/zkvm-fib
RS_FIB=${PWD}/bin/rs_fib
RS_FIB_CUDA=${PWD}/bin/rs_fib_cuda

cuda_enabled=0
if command -v nvcc >/dev/null 2>&1; then
    echo "nvcc installed"
    cuda_enabled=1
else
    cuda_enabled=0
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
    rustup toolchain list --verbose | grep risc0
fi

export RUST_LOG=info

echo "==build rs_fib"
if [ -f "$RS_FIB" ]; then
    echo "==$RS_FIB and $RS_FIB_CUDA exist."
else
    echo "==$RS_FIB does not exist."
    cd $SCRIPT_DIR
    cargo build --release
    mv $SCRIPT_DIR/target/release/fib $RS_FIB

    # Check if nvcc is installed
    if (($cuda_enabled==1)); then
        # cuda version
        cargo build --release -F cuda
        mv $SCRIPT_DIR/target/release/fib $RS_FIB_CUDA
    else
        echo "nvcc not installed"
    fi
fi

# 100
echo -e "\n==rs_fib dry-run: cpu"
$RS_FIB --iterations $FIB_N --method execute
echo -e "\n==CPU proving time"
time $RS_FIB --iterations $FIB_N --method prove

# cuda
echo -e "\n==rs_fib prove: cuda"
if (($cuda_enabled==1)); then
    $RS_FIB_CUDA --iterations $FIB_N --method prove
else
    echo "nvcc not installed"
fi

echo -e "\n==Finish zkvm rs_fib"