package battle

import (
	"config"
	"container/list"
	"fmt"
	"network"
	"network/netdef"
)

type stBattleConfig struct {
	PlayerCount int `json:"playerCount"`
}

var cfgBattle stBattleConfig

var waitQueue *list.List
var chConnection chan netdef.Connection

func eh(err error) {

}

func initBattle() {
	config.LoadBattle("../config/battle_config", &cfgBattle)
	fmt.Println(cfgBattle)

	waitQueue = list.New()
	chConnection = make(chan netdef.Connection, 1000)

	svr, err := network.NewTcpServer("192.168.142.140:12345", eh)
	if err != nil {
		return
	}
	svr.Start(chConnection)
}

func acceptConnection(conn netdef.Connection) {
	waitQueue.PushBack(conn)
	if waitQueue.Len() < cfgBattle.PlayerCount {
		return
	}

	room := newRoom(cfgBattle.PlayerCount)
	room.start(waitQueue)

	waitQueue.Init()
}

func update() {
	for {
		select {
		case conn := <-chConnection:
			acceptConnection(conn)
			break
		default:
			break
		}
		var next *list.Element
		for e := waitQueue.Front(); e != nil; e = next {
			next = e.Next()
			if e.Value.(netdef.Connection).Disconnected() {
				fmt.Println("one client disconnect")
				waitQueue.Remove(e)
			}
		}
	}
}

func Start() {
	fmt.Println("battle start...")
	initBattle()
	go update()
}
