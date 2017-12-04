package battle

import (
	"config"
	"fmt"
	"network"
	"network/netdef"
)

type stBattleConfig struct {
	Ip   string `json:"ip"`
	Port int    `json:"port"`
}

var chConnection chan netdef.Connection
var currRoom *stRoom
var roomid int

func eh(err error) {

}

func initBattle() {
	bcfg := &stBattleConfig{}
	config.LoadBattle("config/battle_config", bcfg)

	chConnection = make(chan netdef.Connection, 1000)

	// svr, err := network.NewTcpServer("192.168.10.231:12345", eh)
	svr, err := network.NewTcpServer(fmt.Sprintf("%s:%d", bcfg.Ip, bcfg.Port), eh)
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
