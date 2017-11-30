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

type protoPlayerCount struct {
	MsgType     string `json:"msgType"`
	PlayerCount int    `json:"playerCount"`
}

type protoStart struct {
	MsgType string `json:"msgType"`
	Ids     []int  `json:"ids"`
	X       []int  `json:"x"`
	Y       []int  `json:"y"`
	Seed    int64  `json:"seed"`

	NX []int `json:"nx"`
	NY []int `json:"ny"`

	Ws []int `json:"ws"`
	WX []int `json:"wx"`
	WY []int `json:"wy"`
}

type protoFight struct {
	MsgType string `json:"msgType"`
}

type protoFrame struct {
	MsgType string             `json:"msgType"`
	Frames  []*json.RawMessage `json:"frames"`
}

//------------------------ room ------------------------------

type stRoom struct {
	roomid  int
	nextid  int
	status  string
	players *list.List
	chFrame chan *json.RawMessage

	mutex  sync.Mutex
	chexit chan bool
}

func newRoom(id int) *stRoom {
	room := &stRoom{
		roomid:  id,
		nextid:  0,
		status:  "wait",
		players: list.New(),
		chFrame: make(chan *json.RawMessage, 1000),
		chexit:  make(chan bool),
	}
	go room.update()
	return room
}

func (p *stRoom) update() {
	for {
		p.mutex.Lock()
		flag := false
		var next *list.Element
		for e := p.players.Front(); e != nil; e = next {
			next = e.Next()
			player := e.Value.(*stPlayer)
			if player.conn.Disconnected() {
				player.close()
				flag = true
				p.players.Remove(e)
			}
		}
		p.mutex.Unlock()
		if flag {
			if p.status == "wait" {
				p.noticePlayerEnter()
			} else {
				if p.players.Len() == 0 {
					fmt.Println("close room")
					p.chexit <- true
					return
				}
			}
		}
		time.Sleep(50 * time.Millisecond)
	}
}

func (p *stRoom) acceptConnection(conn netdef.Connection) {
	playerId := p.nextid
	p.nextid++
	player := newPlayer(playerId, conn, p)
	p.players.PushBack(player)
	player.start()
}

func (p *stRoom) start() {
	if p.status != "wait" {
		return
	}

	defer p.mutex.Unlock()
	p.mutex.Lock()

	var next *list.Element
	for e := p.players.Front(); e != nil; e = next {
		next = e.Next()

		player := e.Value.(*stPlayer)
		if player.status != "entered" {
			player.close()
			p.players.Remove(e)
		} else {
			player.status = "waitReady"
		}
	}

	playerCount := p.players.Len()
	fmt.Println("room start, player count:", playerCount)
	seed := time.Now().Unix()
	rand.Seed(seed)

	npcCount := 100
	weaponCount := 50
	jd := protoStart{
		MsgType: "start",
		Ids:     make([]int, playerCount),
		X:       make([]int, playerCount),
		Y:       make([]int, playerCount),
		NX:      make([]int, npcCount),
		NY:      make([]int, npcCount),
		Ws:      make([]int, weaponCount),
		WX:      make([]int, weaponCount),
		WY:      make([]int, weaponCount),
		Seed:    seed,
	}
	for i := 0; i < playerCount; i++ {
		jd.Ids[i] = i
		jd.X[i] = rand.Intn(100)
		jd.Y[i] = rand.Intn(100)
	}
	for i := 0; i < npcCount; i++ {
		jd.NX[i] = rand.Intn(100)
		jd.NY[i] = rand.Intn(100)
	}
	for i := 0; i < weaponCount; i++ {
		jd.Ws[i] = rand.Intn(4) + 1
		jd.WX[i] = rand.Intn(100)
		jd.WY[i] = rand.Intn(100)
	}
	data, err := json.Marshal(jd)
	if err != nil {
		fmt.Println("marshal startRsp err:", err)
		return
	}
	p.sendToAllPlayer(data)

	p.status = "start"
}

func (p *stRoom) noticePlayerEnter() {
	defer p.mutex.Unlock()
	p.mutex.Lock()

	jd := protoPlayerCount{
		MsgType:     "playerCount",
		PlayerCount: p.players.Len(),
	}
	data, err := json.Marshal(jd)
	if err != nil {
		fmt.Println("marshal playercount err:", err)
		return
	}
	p.sendToAllPlayer(data)
}

func (p *stRoom) playerReady(player *stPlayer) {
	defer p.mutex.Unlock()
	p.mutex.Lock()

	player.status = "fight"
	for e := p.players.Front(); e != nil; e = e.Next() {
		if e.Value.(*stPlayer).status != "fight" {
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
		select {
		case <-p.chexit:
			return
		default:
			break
		}
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
	for e := p.players.Front(); e != nil; e = e.Next() {
		e.Value.(*stPlayer).conn.Write(1, data)
	}
}
