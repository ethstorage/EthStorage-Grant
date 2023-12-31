use wasm_bindgen::prelude::*;
use num_bigint::BigUint;

extern "C" {
    pub fn wasm_input(is_public: u32) -> u64;
    pub fn require(cond: bool);
}

#[wasm_bindgen]
pub fn zkmain() {
    unsafe {
        // let input = 100;
        let input = wasm_input(1);
        let _result = fibonacci(input as u32);
        // let expected = wasm_input(1);
        // require(expected as u64 == result[0]);
    }
}

pub fn fibonacci(n: u32) -> Vec<u64> {
    let mut f0: BigUint = BigUint::from(0u64);
    let mut f1: BigUint = BigUint::from(1u64);
    for _ in 0..n {
        let f2 = f0 + &f1;
        f0 = f1;
        f1 = f2;
    }
    let mod_result = f0 % BigUint::from(1u64 << 32);
    mod_result.to_u64_digits()
}