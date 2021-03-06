package battle

import (
	"fmt"
	"network/message"
	"network/netdef"

	"sgio"

	"github.com/golang/protobuf/proto"
)

type stPlayer struct {
	id     int
	conn   netdef.Connection
	chMsg  chan *message.Message
	status string
	room   *stRoom
	chexit chan bool
}

func newPlayer(id int, conn netdef.Connection, room *stRoom) *stPlayer {
	return &stPlayer{
		id:     id,
		conn:   conn,
		chMsg:  make(chan *message.Message),
		status: "idle",
		room:   room,
		chexit: make(chan bool),
	}
}

func (p *stPlayer) start() {
	p.conn.Start(p.chMsg)
	go func() {
		for {
			select {
			case <-p.chexit:
				return
			case msg := <-p.chMsg:
				switch p.status {
				case "idle":
					if msg.MsgType == int(sgio_battle.MsgType_enter) {
						p.onEnter()
						p.room.noticePlayerEnter()
					}
				case "entered":
					if msg.MsgType == int(sgio_battle.MsgType_start) {
						fmt.Println("receive start...")
						p.room.start()
					}
				case "waitReady":
					if msg.MsgType == int(sgio_battle.MsgType_ready) {
						p.room.playerReady(p)
					}
				case "fight":
					if msg.MsgType == int(sgio_battle.MsgType_frame) {
						frame := &sgio_battle.Frame{}
						err := proto.Unmarshal(msg.Data, frame)
						if err != nil {
							fmt.Println("unmarshal err:", err)
						} else {
							p.room.playerFrame(p, frame)
						}
					}
				}
			default:
				break
			}
		}
	}()
}

func (p *stPlayer) onEnter() {
	fmt.Println("player enter")
	pb := &sgio_battle.Enter{
		Playerid: proto.Int(p.id),
		Roomid:   proto.Int(p.room.roomid),
	}
	data, err := proto.Marshal(pb)
	if err != nil {
		fmt.Println("marshal err:", err)
	}
	p.conn.Write(int(sgio_battle.MsgType_enter), data)
	p.status = "entered"
}

func (p *stPlayer) close() {
	p.conn.Close()
	p.chexit <- true
}
