package battle

import (
	"encoding/json"
	"fmt"
	"network"
	"time"
)

type protoRecv struct {
	MsgType string           `json:"msgType"`
	Data    *json.RawMessage `json:"data"`
}

type protoEnterRsp struct {
	MsgType string `json:"msgType"`
	Id      int    `json:"id"`
}

type protoStart struct {
	MsgType string `json:"msgType"`
	Ids     []int  `json:"ids"`
	X       []int  `json:"x"`
	Y       []int  `json:"y"`
}

type protoFight struct {
	MsgType string `json:"msgType"`
}

type protoFrame struct {
	MsgType string             `json:"msgType"`
	Frames  []*json.RawMessage `json:"frames"`
}

const (
	playerCount = 2
)

var posConfig [2][3]int

var started bool
var players []int
var readyCount int

var frames []*json.RawMessage

func updateMessage() {
	for {
		select {
		case msg := <-network.ChMessage:
			var jd protoRecv
			err := json.Unmarshal(msg.Data, &jd)
			if err != nil {
				fmt.Println("unmarshal err:", err)
				return
			}
			handleMsg(msg.Id, jd)
		default:
			return
		}
	}

}

func handleMsg(connId int, jd protoRecv) {
	switch jd.MsgType {
	case "enter":
		players = append(players, connId)
		jd := protoEnterRsp{
			MsgType: "enterRsp",
			Id:      connId,
		}
		data, err := json.Marshal(jd)
		if err != nil {
			fmt.Println("marshal err:", err)
			return
		}
		network.Send(connId, data)
		fmt.Println("send enterRsp")

		count := len(players)
		if count == playerCount {
			jd := protoStart{
				MsgType: "start",
				Ids:     make([]int, count),
				X:       make([]int, count),
				Y:       make([]int, count),
			}
			for i := 0; i < count; i++ {
				jd.Ids[i] = players[i]
				jd.X[i] = posConfig[0][i]
				jd.Y[i] = posConfig[1][i]
			}
			data, err := json.Marshal(jd)
			if err != nil {
				fmt.Println("marshal start err:", err)
				return
			}
			for i := 0; i < count; i++ {
				network.Send(players[i], data)
			}
			fmt.Println("send start")
		}
	case "ready":
		readyCount++
		if readyCount == playerCount {
			jd := protoFight{
				MsgType: "fight",
			}
			data, err := json.Marshal(jd)
			if err != nil {
				fmt.Println("marshal fight err:", err)
				return
			}
			for i := 0; i < playerCount; i++ {
				network.Send(players[i], data)
			}
			fmt.Println("send fight")

			go fight()
		}
	case "frame":
		frames = append(frames, jd.Data)
		fmt.Println(frames)
	}
}

func fight() {
	for {
		time.Sleep(33 * time.Millisecond)

		jd := protoFrame{
			MsgType: "frame",
			Frames:  frames,
		}
		// fmt.Println(jd)

		data, err := json.Marshal(jd)
		if err != nil {
			fmt.Println("marshal frame err:", err)
		} else {
			for i := 0; i < playerCount; i++ {
				network.Send(players[i], data)
			}
		}

		frames = make([]*json.RawMessage, 0)
	}
}

func Start() {
	fmt.Println("battle.start...")

	players = make([]int, 0)
	started = false
	posConfig = [2][3]int{{0, 100, 200}, {0, 100, 200}}
	readyCount = 0
	frames = make([]*json.RawMessage, 0)

	go func() {
		for {
			updateMessage()
			time.Sleep(10 * time.Millisecond)
		}
	}()
}
