package main

import (
	"fmt"
	"math/big"
)

func main() {
	var a0, a1 *big.Int
	a0 = big.NewInt(0)
	a1 = big.NewInt(1)
	for i := 2; i <= 10000; i++ {
		a0, a1 = a1, a0.Add(a0, a1)
	}
	modResult := a1.Mod(a1, big.NewInt(1<<32))
	fmt.Printf("%d", modResult)
}
