package main

import (
	"battle"
	"fmt"
	"time"
)

func main() {
	fmt.Println("main.start...")

	battle.Start()

	for {
		time.Sleep(10 * time.Millisecond)
	}
}
