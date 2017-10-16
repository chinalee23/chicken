package main

import (
	"battle"
	"fmt"
	"network"
	"time"
)

func main() {
	fmt.Println("main.start...")

	network.Start()
	battle.Start()

	for {
		time.Sleep(10 * time.Millisecond)
	}
}
