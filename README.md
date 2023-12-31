# EthStorage-Grant
Metrics specification:
- Risc0: Risc0 instructions typically consist of 1-2 cycles each. The `total cycles` logged in the stdout might be misleading as it refers to `segment_cycles`, which actually measures the entirety of cycles in the guest program's execution trace. It's worth noting that segment_cycles needs adjustment by **subtracting 1<<20**, as Risc0's default implementation inadvertently adds an extra segment.
- zkWasm: Cycles are measured by total wasm instructions.

## timing profile
> zkWasm OS: Mem: 512G	 AMD Ryzen Threadripper PRO 5975WX 32-Cores, GPU: 4090*2, Cuda 12.2
> Risc0  OS: Mem: 128G	 AMD Ryzen 9 7950X 16-Core Processor,	GPU: 4090, Cuda 12.2

* N=900

| Metrics              | cycles           | dry_run(s) | gen_witness(s) | gen_proof(s) | e2e(s)       | 
|----------------------|------------------|------------|----------------|--------------|--------------|
| zkWasm(raw_wasm) CPU | 369891           | -          | -              | 362          |              | 
| zkWasm(raw_wasm) GPU | Same as above    | -          | -              | 31.3         | -            | 
| zkWasm(zkgo/wasm) CPU| >> 1M            | pending    | -              | -            | -            | 
| zkWasm(zkgo/wasm) GPU| Same as above    | pending    | -              | -            | -            | 
| rics0(raw_wasm)      | 24867989         | -          | -              | -            |              | 
| rics0(raw_wasm) GPU  | Same as above    | -          | -              |              |              |
| rics0(riscv)         | 236397           | -          |                | 22.0         |              | 
| rics0(riscv) GPU     | Same as above    | -          | -              | 6.0          |              | 
| rics0(zkgo/wasm)     | >> 1M            | time out   | -              |              |              | 
| rics0(zkgo/wasm) GPU | Same as above    | time out   | -              |              |              | 
| rics0(zkgo/riscv)    | Unsupported      | -          | -              |              |              | 
| rics0(zkgo/riscv) GPU| Same as above    | -          | -              |              |              | 

* N=1800

| Metrics              | cycles           | dry_run(s) | gen_witness(s) | gen_proof(s) | e2e(s)       | 
|----------------------|------------------|------------|----------------|--------------|--------------|
| zkWasm(raw_wasm) CPU | 1019334          | -          | -              | >> 60        |              | 
| zkWasm(raw_wasm) GPU | Same as above    | -          | -              | 38.2         | -            | 
| zkWasm(zkgo/wasm) CPU| >> 1M            | pending    | -              | -            | -            | 
| zkWasm(zkgo/wasm) GPU| Same as above    | pending    | -              | -            | -            | 
| rics0(raw_wasm)      | 24867989         | -          | -              | _            |              | 
| rics0(raw_wasm) GPU  | Same as above    | -          | -              |              |              |
| rics0(riscv)         | 681145           | -          |                | 80.7         |              | 
| rics0(riscv) GPU     | Same as above    | -          | -              | 12.0         |              | 
| rics0(zkgo/wasm)     | >> 1M            | time out   | -              |              |              | 
| rics0(zkgo/wasm) GPU | Same as above    | time out   | -              |              |              | 
| rics0(zkgo/riscv)    | Unsupported      | -          | -              |              |              | 
| rics0(zkgo/riscv) GPU| Same as above    | -          | -              |              |              | 

## Structure

### bin
All the binary file (cli tools and generated wasm files) will gather here in `./bin` directory.

### data
All the generated benchmark cases are store in the `./data` directory.


## How to run:
* prepare enviroment and pull submodule
```bash
make prepare
make pull
```
> change FIB_N in the following bash files to change benchmark's number of instructions

* profile fib_rs in zkWasm 
```bash
bash scripts/zkwasm_fibrs.sh
```

* profile fib_zkgo in zkWasm 
```bash
bash scripts/zkwasm_fibgo.sh
```

* profile fib_rs compiled to riscv in Risc0 
```bash
bash scripts/risc0_fibrs_riscv.sh
```

* profile fib_rs compiled to wasm, then interpreted with wasmi, then compiled to riscv in Risc0 
```bash
bash scripts/risc0_fibrs_wasmi2riscv.sh
```

* profile fib_go compiled to wasm, then interpreted with wasmi, then compiled to riscv in Risc0 
```bash
bash scripts/risc0_fibgo_wasmi2riscv
```


## Reference
https://github.com/ethstorage/Ethstorage-Grant