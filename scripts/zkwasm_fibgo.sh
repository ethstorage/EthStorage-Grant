#!/bin/bash
FIB_N=900
PWD=${PWD}
GOROOT=${PWD}/go
#ZKGO=${PWD}/bin/zkgo #can't move it out.
ZKGO=$GOROOT/bin/zkgo
# export GOROOT=${GOROOT}

FIB_FILENAME="fib_zkgo.go"
FIB_PATH=$GOROOT/data/fib_zkgo.go
GO_FIB_WASM=${PWD}/bin/go_fib.wasm

GEN_WITNESS=$GOROOT/zkgo_examples/fib/write_witness.py
FIB_INPUT=${PWD}/data/input.dat

WASMI_EXEC_NODE=$GOROOT/zkgo_examples/zkWasm-emulator/wasi/wasi_exec_node.js

ZKWASM=${PWD}/zkWasm/
OUTPUT=${PWD}/output
delphinus_cli=${PWD}/bin/delphinus-cli #can't move it out.
delphinus_cli_cuda=${PWD}/bin/delphinus-cli_cuda #can't move it out.

cuda_enabled=0
if command -v nvcc >/dev/null 2>&1; then
    echo "nvcc installed"
    cuda_enabled=1
else
    cuda_enabled=0
fi

# 1. build zkgo
rm -rf ${OUTPUT}
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

# 2. export zkgo's path
#echo "==Export zkgo to path"
#./export_path.sh
#which zkgo # test zkgo

# 3. compile `fib_go.go` into `fib.wasm`
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

# 4. compile gen witness
echo "==Compile gen witness"
if [ -f "$FIB_INPUT" ]; then
    echo -e "==$FIB_INPUT exists. \n"
else
  echo 0 | python3 $GEN_WITNESS > $FIB_INPUT
  echo 1 | python3 $GEN_WITNESS >> $FIB_INPUT
  echo 817770325994397771 | python3 $GEN_WITNESS >> $FIB_INPUT

  # Require node > 20
  echo -e "==Compile witness into wasm"
  time node $WASMI_EXEC_NODE $GO_FIB_WASM $FIB_INPUT
fi

# 5. build zkWasm
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

#echo "==Compile fib into riscv with zkgo"
#if [ -f "$FIB_RISCV" ]; then
#    echo -e "==$FIB_RISCV exists. \n"
#else
#  echo $GOROOT
#  cd $GOROOT
   # NOTE: MEET ERROR: zkgo_examples/fib/fib_zkgo.go:5:6: missing function body
#  GOOS=linux GOARCH=riscv64 $ZKGO build -gcflags=all=-d=softfloat -o $FIB_RISCV $FIB_PATH
#  echo -e "compiled \n"
#fi


# 4.1 zkgo fib: dry-run
echo -e "\n==zkwasm dry_run fib_go"
time $delphinus_cli -k 22 -o ${OUTPUT} -p ${OUTPUT} -w $GO_FIB_WASM  --function zkmain  dry-run --private ${FIB_N}:i64

# 4.2 zkgo fib: batch-prove cuda
# todo!
time $delphinus_cli -k 22 -o ${OUTPUT} -p ${OUTPUT} -w $GO_FIB_WASM  --function zkmain  single-prove --private ${FIB_N}:i64

echo -e "\n==echo "Finish running zkwasm_fibgo.""