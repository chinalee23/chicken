package main

import (
	"battle"
	"fmt"
	"network"
)

func main() {
	fmt.Println("main.start...")

	network.Start()
	battle.Start()
}
