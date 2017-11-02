package battle

import (
	"encoding/json"
	"fmt"
	"network"
)

//--------------------- proto ----------------------
type protoRecv struct {
	MsgType string           `json:"msgType"`
	Data    *json.RawMessage `json:"data"`
}

type protoEnterRsp struct {
	MsgType string `json:"msgType"`
	Id      int    `json:"id"`
}

//------------------------------------------------------

type stPlayer struct {
	id     int
	conn   *network.Connection
	chMsg  chan *network.Message
	status string
	room   *stRoom
}

func newPlayer(id int, conn *network.Connection, room *stRoom) *stPlayer {
	return &stPlayer{
		id:     id,
		conn:   conn,
		chMsg:  make(chan *network.Message),
		status: "waitEnter",
		room:   room,
	}
}

func (p *stPlayer) start() {
	p.conn.Start(p.chMsg)
	go func() {
		for {
			msg := <-p.chMsg
			jd := decode(msg)
			switch p.status {
			case "waitEnter":
				if jd.MsgType == "enter" {
					onEnter()
					room.playerEnter(p)
				}
			case "waitReady":
				if jd.MsgType == "ready" {
					room.playerReady(p)
				}
			case "fight":
				if jd.MsgType == "frame" {
					room.playerFrame(p, jd.Data)
				}
			}
		}
	}()
}

func (p *stPlayer) decode(msg *network.Message) {
	var jd protoRecv
	err := json.Unmarshal(msg.Data, &jd)
	if err != nil {
		fmt.Println("unmarshal err:", err)
		return nil
	} else {
		return jd
	}
}

func (p *stPlayer) onEnter() {
	jd := protoEnterRsp{
		MsgType: "enterRsp",
		Id:      p.id,
	}
	data, err := json.Marshal(jd)
	if err != nil {
		fmt.Println("marshal err:", err)
		return
	}
	p.conn.Write(1, data)
	fmt.Println("send enterRsp")
}
