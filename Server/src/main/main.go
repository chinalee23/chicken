package main

import (
	"battle"
	"fmt"
	"time"

	"pb"

	"github.com/golang/protobuf/proto"
)

func test() {
	pos := &pb.Position{
		X: proto.Int32(1),
		Y: proto.Int32(1),
	}
	_, err := proto.Marshal(pos)
	if err != nil {
		fmt.Println("marshal err", err)
		return
	}

	var x int
	x = int(pb.MsgType_enter)

	fmt.Println("enter:", x)
}

func main() {
	fmt.Println("main.start...")

	//	test()

	battle.Start()

	for {
		time.Sleep(10 * time.Millisecond)
	}
}
