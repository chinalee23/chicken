package battle

import (
	"container/list"
	"encoding/json"
	"fmt"
	"math/rand"
	"network/netdef"
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

	NX []int `json:"nx"`
	NY []int `json:"ny"`
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

	chFrame chan *json.RawMessage

	mutex sync.Mutex
}

func newRoom(playerCount int) *stRoom {
	posConfig = [2][2]int{
		{0, 50},
		{0, 50},
	}
	return &stRoom{
		playerCount: playerCount,
		players:     make([]*stPlayer, playerCount),
		chFrame:     make(chan *json.RawMessage, 1000),
	}
}

func (p *stRoom) start(conns *list.List) {
	i := 0
	for e := conns.Front(); e != nil; e = e.Next() {
		player := newPlayer(i, e.Value.(netdef.Connection), p)
		p.players[i] = player
		player.start()
		i++
	}
}

func (p *stRoom) playerEnter(player *stPlayer) {
	defer p.mutex.Unlock()
	p.mutex.Lock()

	player.status = "waitReady"
	for _, v := range p.players {
		if v.status != "waitReady" {
			return
		}
	}

	seed := time.Now().Unix()
	rand.Seed(seed)
	jd := protoStart{
		MsgType: "start",
		Ids:     make([]int, p.playerCount),
		X:       make([]int, p.playerCount),
		Y:       make([]int, p.playerCount),
		NX:      make([]int, 100),
		NY:      make([]int, 100),
		Seed:    seed,
	}
	for i := 0; i < p.playerCount; i++ {
		jd.Ids[i] = i
		jd.X[i] = rand.Intn(100) - 50
		jd.Y[i] = rand.Intn(100) - 50
	}
	for i := 0; i < 100; i++ {
		jd.NX[i] = rand.Intn(100) - 50
		jd.NY[i] = rand.Intn(100) - 50
	}
	data, err := json.Marshal(jd)
	if err != nil {
		fmt.Println("marshal startRsp err:", err)
		return
	}
	p.sendToAllPlayer(data)
}

func (p *stRoom) playerReady(player *stPlayer) {
	defer p.mutex.Unlock()
	p.mutex.Lock()

	player.status = "fight"
	for _, v := range p.players {
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
	p.sendToAllPlayer(data)

	go p.fight()
}

func (p *stRoom) playerFrame(player *stPlayer, frame *json.RawMessage) {
	defer p.mutex.Unlock()
	p.mutex.Lock()
	p.chFrame <- frame
}

func (p *stRoom) fight() {
	for {
		time.Sleep(100 * time.Millisecond)
		frames := p.getFrames()
		jd := protoFrame{
			MsgType: "frame",
			Frames:  frames,
		}
		data, err := json.Marshal(jd)
		if err != nil {
			fmt.Println("marshal frames err:", err)
			continue
		}
		p.sendToAllPlayer(data)
	}
}

func (p *stRoom) getFrames() []*json.RawMessage {
	frames := make([]*json.RawMessage, 0)
	for {
		select {
		case frame := <-p.chFrame:
			frames = append(frames, frame)
		default:
			return frames
		}
	}
}

func (p *stRoom) sendToAllPlayer(data []byte) {
	for _, v := range p.players {
		v.conn.Write(1, data)
	}
}
