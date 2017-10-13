package battle

import (
	"encoding/json"
	"fmt"
	"network"
	"time"
)

type protoRecv struct {
	MsgType string             `json:"msgType"`
	Data    []*json.RawMessage `json:"data"`
}

const (
	playerCount = 2
)

var started bool

func start() {
	handleMessage()
}

func handleMessage() {
	for {
		select {
		case msg := <-network.ChMessage:
			var jd protoRecv
			err := json.Unmarshal(msg.Data, &jd)
			if err != nil {
				fmt.Println("unmarshal err:", err)
				return
			}
		default:
			return
		}
	}

}

func Start() {
	fmt.Println("battle.start...")

	started = false

	go func() {
		for {
			handleMessage()
			time.Sleep(10 * time.Millisecond)
		}
	}()
}
