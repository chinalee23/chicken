package battle

import (
	"container/list"
	"encoding/json"
	"fmt"
	"network/message"
	"sync"
	"time"
)

//----------------------- proto -------------------------

type protoStart struct {
	MsgType string `json:"msgType"`
	Ids     []int  `json:"ids"`
	X       []int  `json:"x"`
	Y       []int  `json:"y"`
	Seed    int64  `json:"seed"`
}

type protoFight struct {
	MsgType string `json:"msgType"`
}

type protoFrame struct {
	MsgType string             `json:"msgType"`
	Frames  []*json.RawMessage `json:"frames"`
}

var posConfig [2][2]int

//------------------------ room ------------------------------

type stRoom struct {
	playerCount int
	players     []*stPlayer
	status      string

	chMsg   chan *message.Message
	chFrame chan *json.RawMessage

	mutex sync.Mutex
}

func newRoom(playerCount int) *stRoom {
	return &stRoom{
		playerCount: playerCount,
		players:     make([]*stPlayer, playerCount),
		chMsg:       make(*message.Message, 1000),
		chFrame:     make(chan *json.RawMessage, 1000),
	}
}

func (p *stRoom) start(conns *list.List) {
	i := 0
	for e := conns.Front(); e != nil; e = e.Next() {
		player := newPlayer(i, e.Value.(*connection))
		players = append(players, player)
		player.start()
		i++
	}
}

func (p *stRoom) playerEnter(player *stPlayer) {
	defer p.mutex.Unlock()

	player.status = "waitReady"
	p.mutex.Lock()
	for _, v := range players {
		if v.status != "waitReady" {
			return
		}
	}

	seed := time.Now().Unix()
	jd := protoStart{
		MsgType: "start",
		Ids:     make([]int, p.playerCount),
		X:       make([]int, p.playerCount),
		Y:       make([]int, p.playerCount),
		Seed:    seed,
	}
	for i := 0; i < p.playerCount; i++ {
		jd.Ids[i] = i
		jd.X[i] = posConfig[0][i]
		jd.Y[i] = posConfig[1][i]
	}
	data, err := json.Marshal(jd)
	if err != nil {
		fmt.Println("marshal startRsp err:", err)
		return
	}
	for _, v := range players {
		v.conn.Write(1, data)
	}
}

func (p *stRoom) playerReady(player *stPlayer) {
	defer p.mutex.Unlock()

	p.status = "fight"
	p.mutex.Lock()
	for _, v := range players {
		if v.status != "fight" {
			return
		}
	}

	jd := protoFight{
		MsgType: "fight",
	}
	data, err := json.Marshal(jd)
	if err != nil {
		fmt.Println("marshal fight err:", err)
		return
	}
	for _, v := range players {
		v.conn.Write(1, data)
	}

	go fight()
}

func (p *stRoom) playerFrame(player *stPlayer, frame *json.RawMessage) {
	defer p.mutex.Unlock()
	p.mutex.Lock()
	p.chFrame <- frame
}

func (p *stRoom) fight() {
	for {
		time.Sleep(66 * time.Millisecond)
		frames := p.getFrames()
		jd := protoFrame{
			MsgType: "frame",
			Frames:  frames,
		}
		for _, v := range players {
			v.conn.Write(1, data)
		}
	}
}

func (p *stRoom) getFrames() []*json.RawMessage {
	frames := make([]*json.RawMessage, 0)
	for {
		select {
		case msg := <-p.chMsg:
			frames = append(frames, msg)
		default:
			return frames
		}
	}
}
