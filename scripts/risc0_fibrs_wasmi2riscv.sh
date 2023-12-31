#!/bin/bash

PWD=${PWD}
RISC0=${PWD}/risc0/

FIB_N=900
# raw, rust fib wasm
SCRIPT_DIR=${PWD}/data/zkvm-wasmi
RS_WASMI_FIB=${PWD}/bin/rs_wasmi_fib
RS_WASMI_FIB_CUDA=${PWD}/bin/rs_wasmi_fib_cuda

RS_FIB_WASM_NAME=rs_fib.wasm
RS_FIB_WASM_DIR=${PWD}/bin/pkg
RS_FIB_WASM=${RS_FIB_WASM_DIR}/${RS_FIB_WASM_NAME}

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
    ls ~/.cargo/bin
fi

echo "==build rust_fib to wasm"
if [ -f "$RS_FIB_WASM" ]; then
    echo "==$RS_FIB_WASM exists."
else
    echo "==$RS_FIB_WASM does not exist."
    cd $RUST_FIB
    wasm-pack build --release -d ${RS_FIB_WASM_DIR} --out-name ${RS_FIB_WASM_NAME}
fi

echo "==build rs_wasmi_fib"
export RUST_LOG=info
if [ -f "$RS_WASMI_FIB" ]; then
    echo "==$RS_WASMI_FIB and $RS_FIB_CUDA exist."
else
    echo "==$RS_WASMI_FIB does not exist."
    cd $SCRIPT_DIR
    cargo build --release
    mv $SCRIPT_DIR/target/release/wasm $RS_WASMI_FIB

    # Check if nvcc is installed
    if (($cuda_enabled==1)); then
        # cuda version
        cargo build --release -F cuda
        mv $SCRIPT_DIR/target/release/wasm $RS_WASMI_FIB_CUDA
    else
        echo "nvcc not installed"
    fi
fi

# rs_wasmi_fib dry-run, proving
echo -e "\n==rs_wasmi_fib dry-run: cpu"
$RS_WASMI_FIB --wasm $RS_FIB_WASM --public ${FIB_N}:i64 --method execute
echo -e "\n==CPU proving"
time $RS_WASMI_FIB --wasm $RS_FIB_WASM --public ${FIB_N}:i64 --method prove

# cuda
echo -e "\n==rs_wasmi_fib prove: cuda"
if (($cuda_enabled==1)); then
    time $RS_WASMI_FIB_CUDA --wasm $RS_FIB_WASM --public ${FIB_N}:i64 --method prove
else
    echo "nvcc not installed"
fi

echo -e "\n==Finish zkvm rs_wasmi_fib"