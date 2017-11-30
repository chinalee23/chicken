package battle

import (
	"fmt"
	"network"
	"network/netdef"
)

type stBattleConfig struct {
	PlayerCount int `json:"playerCount"`
}

var chConnection chan netdef.Connection
var currRoom *stRoom
var roomid int

func eh(err error) {

}

func initBattle() {
	chConnection = make(chan netdef.Connection, 1000)

	svr, err := network.NewTcpServer("192.168.10.238:12345", eh)
	if err != nil {
		return
	}
	svr.Start(chConnection)

	roomid = 1
	currRoom = newRoom(roomid)
	roomid++
}

func update() {
	for {
		conn := <-chConnection
		if currRoom.status == "start" {
			currRoom = newRoom(roomid)
			roomid++
		}
		currRoom.acceptConnection(conn)
	}
}

func Start() {
	fmt.Println("battle start...")
	initBattle()
	go update()
}
