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

#![no_main]
#![allow(unused_imports)]

risc0_zkvm::guest::entry!(main);

use risc0_zkvm::guest::env;
use wasmi::{Caller, Engine, Func, Linker, Module, Store};

pub fn main() {
    let engine = Engine::default();

    let wasm: Vec<u8> = env::read();
    let pub_values: Vec<i64> = env::read();

    // Derived from the wasmi example: https://docs.rs/wasmi/0.29.0/wasmi/#example
    let module = Module::new(&engine, &mut &wasm[..]).expect("Failed to create module");
    type HostState = Vec<i64>;

    let mut store = Store::new(&engine, pub_values);
    let require = Func::wrap(&mut store, |cond: i32| {
        if cond == 0 {
            panic!(
                "require is not satisfied, which is a \
            false assertion in the wasm code. Please check \
            the logic of your image or input."
            )
        }
    });
    let wasm_input = Func::wrap(&mut store, |mut caller: Caller<'_, HostState>, is_public: i32| -> i64 {
        if is_public != 1 {
            panic!("Currently, only public variables are supported");
        }

        let host_state = caller.data_mut();
        if let Some(value) = host_state.pop() {
            value
        } else {
            panic!("No more values available in pub_values");
        }
    });
    // In order to create Wasm module instances and link their imports
    // and exports we require a `Linker`.
    let mut linker = <Linker<HostState>>::new(&engine);
    // Instantiation of a Wasm module requires defining its imports and then
    // afterwards we can fetch exports by name, as well as asserting the
    // type signature of the function with `get_typed_func`.
    //
    // Also before using an instance created this way we need to start it.
    linker.define("env", "require", require).expect("Failed to define require function");
    linker.define("env", "wasm_input", wasm_input).expect("Failed to define wasm_input function");
    let instance = linker
        .instantiate(&mut store, &module)
        .expect("failed to instantiate")
        .start(&mut store)
        .expect("Failed to start");

    let zkmain = instance
        .get_typed_func::<(),()>(&store, "zkmain")
        .expect("Failed to get typed_func");
    zkmain.call(&mut store, ()).expect("Failed to call");
    env::commit(&1);
}
