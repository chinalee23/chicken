package battle

import (
	"container/list"
	"fmt"
	"network"
	"time"
)

var waitQueue *list.List
var playerCount int
var chConnection chan *network.Connection

func init() {
	waitQueue = list.New()
	chConnection = make(chan *connection, 1000)
	playerCount = 1
}

func acceptConnection(conn *network.Connection) {
	waitQueue.PushBack(conn)
	if waitQueue.Len() < playerCount {
		return
	}

	room := newRoom(playerCount)
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
			if e.Value.(*connection).Disconnected() {
				waitQueue.Remove(e)
			}
		}

		time.Sleep(1 * time.Millisecond)
	}
}

func Start() {
	init()
}
