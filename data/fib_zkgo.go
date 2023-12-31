package main

//go:wasmimport env wasm_input
//go:noescape
func wasm_input(isPublic uint32) uint64

//go:wasmimport env require
//go:noescape
func require(uint32)

func main() {
	var a0, a1 uint64
	a0 = 0
	a1 = 1
	
	var n int
	n = (int)(wasm_input(0))

	var p uint64
	p = 1<<32

	for i := 2; i <= n; i++ {
		a0, a1 = a1, (a0  + a1) % p
	}
// 	an := wasm_input(1)
// 	if an != a1 {
// 		require(1)
// 	}
}
