EthStorage will launch a developer bounty program to incentivize everyone to apply their acquired zk knowledge to solve real-world problems related to zk fraud proof based on [zkGo](https://github.com/ethstorage/go/tree/zkGo) and [zkWasm](https://github.com/ethstorage/zkWasm/tree/dev). Each prize accepts up to two teams, and  each accepted team will be rewarded at least **$1,000 USD**, with a development period of approximately two weeks. Currently, there are two main grants as follows:

# Grant 1

## Summary
This track primarily focuses on benchmarking wasm performance on[ Risc0’s ZKVM](https://github.com/risc0/risc0/tree/main) and[ Delphinuslab’s zkWasm](https://github.com/ethstorage/zkWasm/tree/dev). The benchmark program required for this task is a Go Fibonacci program, designed to calculate the N-th Fibonacci number (N = 100,000 ). The specific target benchmark program is [fib_go.go](https://github.com/ethstorage/go/blob/zkGo/zkgo_examples/fib/fib_go.go).

## Objective
1. **Create a summary table** detailing the time required for two specific operations—dry_run (simply running the wasm binary) and  (optionally) generating a witness (producing the necessary witness to fill in the circuit)—on both zkVMs. Please note that the program's current size prevents it from being proven at once, necessitating chunking and continuation to achieve a full proof. This aspect is actively under development, and thus, we will defer benchmarking for full proof to a future iteration.
2. Share insights and experience from using these tools and **prepare a talk on this topic.**

## Details
* Compile the wasm binary using [zkGo](https://github.com/ethstorage/go/tree/zkGo).
* Utilize the `dry_run` option in zkWasm's command line. Investigate how to perform this action in Risc0.
* Comprehensive documentation must accompany the implementation.
* Relevant resources are available in the [Resources](#resources-for-grant-1) section.
* Please submit your repository containing all relevant code and documentation.

## Hardware Requirements
* 4 cores, 128 GB RAM. We can provide a test machine if needed.

## Timeline & Contact
* Application Deadline: November 30, 2023, at 24:00 (UTC+8).
* Submission Deadline: Submissions are expected within 2 weeks from the acceptance of your application.
* Please refer to the [Contact](#contact) section to reach us and apply.

## Resources for Grant 1
* [Video: What is zkGo and how to use it [CN]](https://www.youtube.com/watch?v=272hvhwYP4U (CN))
* [How to build op-program-client and do zkWasm dry_run](https://github.com/ethstorage/optimism/blob/js-io/op-program/README.md#op-program-zkwasm)
* [Risc0’s wasm example](https://github.com/risc0/risc0/blob/main/examples/wasm/README.md)
* [zkWasm command line](https://github.com/ethstorage/zkWasm/tree/dev#command-line)


# Grant 2

## Summary
This track is dedicated to enhancing [zkGo](https://github.com/ethstorage/go/tree/zkGo) and [zkWasm ](https://github.com/DelphinusLab/zkWasm)optimization by incorporating a **customized keccak256 circuit**. Within our [zkWasm-based zk fraud proof](https://ethstorage.medium.com/advancing-towards-zk-fraud-proof-zkgo-compiling-l2-geth-into-zk-compatible-wasm-a03319bec935), `keccak256` serves as a key component, currently implemented using Golang and compiled into wasm opcodes. However, this implementation is not zk-friendly and imposes significant overhead on zkWasm circuits. Our aim is to substitute Golang's `keccak256` with its zkWasm host circuit.


## Objective
1. Evaluate the prover cost benchmark by comparing the performance of the `keccak256` wasm binary compiled via a Rust program against the utilization of zkWasm's native host circuit. Summarize the findings in a table detailing circuit rows, proving time, and related metrics.
2. Integrate zkWasm's `keccak256` host circuit with the <code>[op-program-client](https://github.com/ethstorage/optimism/blob/js-io/op-program/README.md#op-program-zkwasm)</code>. Provide a unit test ensuring identical <code>keccak256</code> hash results between Golang and zkWasm host functions, demonstrating the correctness of the implementation.
3. Compare the time costs between two implementations of the op-program client (specifically, the smoke_test) for two operations—dry_run (executing the wasm binary) and (optionally) generating a witness (generating the necessary witness for the circuit)—on zkWasm.

## Details
* Utilize the `keccak256` Rust implementation from [this repository](https://github.com/taikoxyz/zkevm-circuits/blob/main/keccak256/src/keccak_arith.rs).
* Use zkWasm's host circuit in this [pull request](https://github.com/DelphinusLab/zkWasm-host-circuits/pull/70).
* Replace the `keccak256` function in Golang using go build hints. Here is [an example](https://github.com/ethstorage/go/blob/ec275ab21658df61b73bc070640c41f8a391f18a/zkgo_examples/fib/fib_zkgo.go#L7).
* Refer to [this documentation](https://github.com/ethstorage/optimism/blob/js-io/op-program/README.md) for guidance on building the op-program client and executing the smoke_test.
* Other relevant resources can be accessed in the [Resources](#resources-for-grant-2) section.
* Please submit your repository containing all relevant code and documentation.


## Timeline & Contact
* Application Deadline: November 30, 2023, at 24:00 (UTC+8).
* Submission Deadline: Submissions are expected within 2 weeks from the acceptance of your application.
* Please refer to the [Contact](#contact) section to reach us and apply.

## Resources for Grant 2
* [Video: What is zkGo and how to use it [CN]](https://www.youtube.com/watch?v=272hvhwYP4U (CN))
* [How to build op-program-client and do zkWasm dry_run](https://github.com/ethstorage/optimism/blob/js-io/op-program/README.md#op-program-zkwasm)
* [zkWasm command line](https://github.com/ethstorage/zkWasm/tree/dev#command-line)

# Contact
The application process is straightforward. If you're interested in participating in this bounty program competition, kindly send an email to **[chenjunfeng@ethstorage.io](mailto:chenjunfeng@ethstorage.io)** with the subject line 'Your name: EthStorage Grant 1(or 2) Application'. In the email, describe your background and reasons for your interest in this program. Please include your WeChat account at the end of the email for contact purposes. The final selected candidates will be announced by December 2, 2023, at 24:00 (UTC+8).
