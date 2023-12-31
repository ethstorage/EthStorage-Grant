// Copyright 2023 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

use fib_methods::{FIB_INTERP_ELF, FIB_INTERP_ID};
use risc0_zkvm::{default_executor, default_prover, ExecutorEnv};
use std::env;
use std::process;

fn run_guest(method: &str, iterations: u32) {
    let env = ExecutorEnv::builder()
        .write(&iterations)
        .unwrap()
        .build()
        .unwrap();

    if method == "execute" {
        let executor = default_executor();
        let session_info = executor.execute_elf(env, FIB_INTERP_ELF).unwrap();
        let result: u64 = session_info.journal.decode().unwrap();
        println!("Fibonacci({}) = {}", iterations, result);
    } else {
        let prover = default_prover();
        let receipt = prover.prove_elf(env, FIB_INTERP_ELF).unwrap();
        let result: u64 = receipt.journal.decode().unwrap();
        println!("Fibonacci({}) = {}", iterations, result);
        receipt.verify(FIB_INTERP_ID).expect(
            "Code you have proven should successfully verify; did you specify the correct image ID?",
        );
        println!("Proof verified successfully");
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: {} --iterations 4 [--method execute]", args[0]);
        process::exit(1);
    }
    let mut iterations: u32 = 1;
    let mut current_arg = 1;
    let mut method = "execute";
    while current_arg < args.len() {
        match args[current_arg].as_str() {
            "--iterations" => {
                current_arg += 1;
                if current_arg >= args.len() {
                    eprintln!("Expected value after --iterations");
                    process::exit(1);
                }
                iterations = args[current_arg].parse().unwrap_or_else(|_| {
                    eprintln!("Invalid value for --iterations: {}", args[current_arg]);
                    process::exit(1);
                });
            }
            "--method" => {
                current_arg += 1;
                if current_arg >= args.len() {
                    eprintln!("Expected method after --method");
                    process::exit(1);
                }
                method = args[current_arg].as_str();
                if method != "execute" && method != "prove" {
                    eprintln!("Unknown method: {}", method);
                    process::exit(1);
                }
            }
            _ => {
                eprintln!("Unknown option: {}", args[current_arg]);
                process::exit(1);
            }
        }
        current_arg += 1;
    }
    run_guest(method, iterations);
}
