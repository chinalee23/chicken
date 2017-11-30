package battle

import (
	"encoding/json"
	"fmt"
	"network/message"
	"network/netdef"
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
	conn   netdef.Connection
	chMsg  chan *message.Message
	status string
	room   *stRoom
}

func newPlayer(id int, conn netdef.Connection, room *stRoom) *stPlayer {
	return &stPlayer{
		id:     id,
		conn:   conn,
		chMsg:  make(chan *message.Message),
		status: "waitEnter",
		room:   room,
	}
}

func (p *stPlayer) start() {
	p.conn.Start(p.chMsg)
	go func() {
		for {
			msg := <-p.chMsg
			jd, err := p.decode(msg)
			if err != nil {
				continue
			}
			switch p.status {
			case "waitEnter":
				if jd.MsgType == "enter" {
					p.onEnter()
					p.room.playerEnter(p)
				}
			case "waitReady":
				if jd.MsgType == "ready" {
					p.room.playerReady(p)
				}
			case "fight":
				if jd.MsgType == "frame" {
					p.room.playerFrame(p, jd.Data)
				}
			}
		}
	}()
}

func (p *stPlayer) decode(msg *message.Message) (protoRecv, error) {
	var jd protoRecv
	err := json.Unmarshal(msg.Data, &jd)
	if err != nil {
		fmt.Println("unmarshal err:", err)
		return jd, err
	} else {
		return jd, nil
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
}
