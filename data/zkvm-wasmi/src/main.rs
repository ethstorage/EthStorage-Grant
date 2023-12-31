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

use risc0_zkvm::{default_prover, default_executor, ExecutorEnv};
use std::env;
use std::fs;
use std::process;
use std::str::FromStr;
use wasm_methods::{WASM_INTERP_ELF, WASM_INTERP_ID};

fn run_guest(method: &str, wasm: Vec<u8>, public_values: &[String]) {
    let mut parsed_values: Vec<i64> = Vec::new();
    for val in public_values {
        let parts: Vec<&str> = val.split(':').collect();
        if parts.len() != 2 {
            eprintln!("Invalid public value format: {}", val);
            process::exit(1);
        }

        if parts[1] != "i64" {
            eprintln!(
                "Unsupported type: {}. Currently, only 'i64' is supported.",
                parts[1]
            );
            process::exit(1);
        }

        let parsed_val = i64::from_str(parts[0]).unwrap_or_else(|_| {
            eprintln!("Invalid integer value: {}", parts[0]);
            process::exit(1);
        });

        parsed_values.push(parsed_val);
    }
    let env = ExecutorEnv::builder()
        .write(&wasm)
        .unwrap()
        .write(&parsed_values)
        .unwrap()
        .build()
        .unwrap();

    if method == "execute" {
        let executor = default_executor();
        let session_info = executor.execute_elf(env, WASM_INTERP_ELF).unwrap();
        let _result: i32 = session_info.journal.decode().unwrap();
    } else {
        let prover = default_prover();
        let receipt = prover.prove_elf(env, WASM_INTERP_ELF).unwrap();
        receipt.verify(WASM_INTERP_ID).expect(
            "Code you have proven should successfully verify; did you specify the correct image ID?",
        );
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!(
            "Usage: {} --wasm <file> [--public <value>:<type>...]",
            args[0]
        );
        process::exit(1);
    }
    let mut wasm_file_path = String::new();
    let mut public_values = Vec::new();
    let mut current_arg = 1;
    let mut method = "execute";
    while current_arg < args.len() {
        match args[current_arg].as_str() {
            "--wasm" => {
                current_arg += 1;
                if current_arg >= args.len() {
                    eprintln!("Expected wasm file path after --wasm");
                    process::exit(1);
                }
                wasm_file_path = args[current_arg].clone();
            }
            "--public" => {
                current_arg += 1;
                if current_arg >= args.len() {
                    eprintln!("Expected value after --public");
                    process::exit(1);
                }
                public_values.push(args[current_arg].clone());
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
    // 读取WASM文件
    let wasm = match fs::read(&wasm_file_path) {
        Ok(contents) => contents,
        Err(e) => {
            eprintln!("Failed to read file '{}': {}", wasm_file_path, e);
            process::exit(1);
        }
    };
    run_guest(method, wasm, &public_values);
}
