#!/bin/bash
# run it in the root directory
export HALO2_PROOF_GPU_EVAL_CACHE=20 # for cuda 4090
# export CUDA_VISIBLE_DEVICES=0 # for enable only one device
FIB_N=900 # 
# FIB_N=1800 # 1M instructions

cuda_enabled=0
if command -v nvcc >/dev/null 2>&1; then
    echo "nvcc installed"
    cuda_enabled=1
else
    cuda_enabled=0
fi

# directories
PWD=${PWD}
ZKWASM=${PWD}/zkWasm/
ZKWASMCLI=${PWD}/zkWasm/crates/cli/
RUST_FIB=${PWD}/data/fib-wasm/
OUTPUT=${PWD}/output
#delphinus_cli=$ZKWASM/target/release/delphinus-cli
delphinus_cli=${PWD}/bin/delphinus-cli #can't move it out.
delphinus_cli_cuda=${PWD}/bin/delphinus-cli_cuda #can't move it out.


# data: rust_fib
RS_FIB_WASM_NAME=rs_fib.wasm
RS_FIB_WASM_DIR=${PWD}/bin/pkg
RS_FIB_WASM=${RS_FIB_WASM_DIR}/${RS_FIB_WASM_NAME}

# data: zkgo_fib
GO_FIB_WASM=${PWD}/data/go_fib.wasm


# 2. build
rm -rf ${OUTPUT}
echo "==build rust_fib to wasm"
if [ -f "$RS_FIB_WASM" ]; then
    echo "==$RS_FIB_WASM exists."
else
    echo "==$RS_FIB_WASM does not exist."
    cd $RUST_FIB
    wasm-pack build --release -d ${RS_FIB_WASM_DIR} --out-name ${RS_FIB_WASM_NAME}
fi

echo "==build zkwasm"
if [ -f "$delphinus_cli" ]; then
    echo "==$delphinus_cli and $delphinus_cli_cuda exist."
else
    echo "==$delphinus_cli does not exist."
    cd $ZKWASM
    cargo build --release
    mv $ZKWASM/target/release/delphinus-cli $delphinus_cli

    # Check if nvcc is installed
    if (($cuda_enabled==1)); then
        # cuda version
        cargo build --release --features cuda
        mv $ZKWASM/target/release/delphinus-cli $delphinus_cli_cuda
    else
        echo "nvcc not installed"
    fi
fi

# 3.1 rust_fib: dry-run, single-prove, cuda
echo -e "\n==zkwasm dry_run rs_fib"
time $delphinus_cli -k 22 -o ${OUTPUT} -p ${OUTPUT} -w $RS_FIB_WASM  --function zkmain  dry-run --public ${FIB_N}:i64 
# echo -e "\n==zkwasm single-prove rs_fib"
# time $delphinus_cli -k 22 -o ${OUTPUT} -w $RS_FIB_WASM  --function zkmain  single-prove --public ${FIB_N}:i64 
echo -e "\n==zkwasm single-prove cuda rs_fib"
if (($cuda_enabled==1)); then
    $delphinus_cli_cuda -k 22 -o ${OUTPUT} -p ${OUTPUT} -w $RS_FIB_WASM  --function zkmain  setup
    $delphinus_cli_cuda -k 22 -o ${OUTPUT} -p ${OUTPUT} -w $RS_FIB_WASM  --function zkmain  single-prove --public ${FIB_N}:i64 
else
    echo "nvcc not installed"
fi

# 3.2 rust_fib: dry-run, single-prove, cpu
echo -e "\n==zkwasm dry_run cpu rs_fib" 
time $delphinus_cli -k 22 -o ${OUTPUT} -p ${OUTPUT} -w $RS_FIB_WASM  --function zkmain  single-prove --public ${FIB_N}:i64 
# delphinus-cli -k 22 --wasm fib_with_input.wasm  --function zkmain dry-run --public 0:i64 --public 1:i64 --public 817770325994397771:i64

echo -e "\n==echo "Finish running zkwasm_fibrs.""