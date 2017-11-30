package battle

import (
	"container/list"
	"fmt"
	"math/rand"
	"network/netdef"
	"sync"
	"time"

	"pb"

	"github.com/golang/protobuf/proto"
)

type stRoom struct {
	roomid  int
	nextid  int
	status  string
	players *list.List
	chFrame chan []byte

	mutex  sync.Mutex
	chexit chan bool
}

func newRoom(id int) *stRoom {
	room := &stRoom{
		roomid:  id,
		nextid:  0,
		status:  "wait",
		players: list.New(),
		chFrame: make(chan []byte, 1000),
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

	pb := &pb_battle.BattleStart{
		Players: make([]*pb_battle.PlayerInfo, 0),
		Npcs:    make([]*pb_battle.NpcInfo, 0),
		Weapons: make([]*pb_battle.WeaponInfo, 0),
		Seed:    proto.Int64(seed),
	}
	for i := 0; i < playerCount; i++ {
		pbPlayer := &pb_battle.PlayerInfo{
			Id: proto.Int(i),
			Pos: &pb_battle.Vector2{
				X: proto.Float32(float32(rand.Intn(100))),
				Y: proto.Float32(float32(rand.Intn(100))),
			},
		}
		pb.Players = append(pb.Players, pbPlayer)
	}
	for i := 0; i < 100; i++ {
		pbNpc := &pb_battle.NpcInfo{
			Id: proto.Int(i),
			Pos: &pb_battle.Vector2{
				X: proto.Float32(float32(rand.Intn(100))),
				Y: proto.Float32(float32(rand.Intn(100))),
			},
		}
		pb.Npcs = append(pb.Npcs, pbNpc)
	}
	for i := 0; i < 50; i++ {
		pbWeapon := &pb_battle.WeaponInfo{
			Id: proto.Int(rand.Intn(4) + 1),
			Pos: &pb_battle.Vector2{
				X: proto.Float32(float32(rand.Intn(100))),
				Y: proto.Float32(float32(rand.Intn(100))),
			},
		}
		pb.Weapons = append(pb.Weapons, pbWeapon)
	}
	data, err := proto.Marshal(pb)
	if err != nil {
		fmt.Println("marshal err:", err)
		return
	}
	p.sendToAllPlayer(int(pb_battle.MsgType_start), data)

	p.status = "start"
}

func (p *stRoom) noticePlayerEnter() {
	defer p.mutex.Unlock()
	p.mutex.Lock()

	pb := &pb_battle.PlayerCount{
		PlayerCount: proto.Int(p.players.Len()),
	}
	data, err := proto.Marshal(pb)
	if err != nil {
		fmt.Println("marshal playercount err:", err)
		return
	}
	p.sendToAllPlayer(int(pb_battle.MsgType_playercount), data)
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

	p.sendToAllPlayer(int(pb_battle.MsgType_fight), nil)

	go p.fight()
}

func (p *stRoom) playerFrame(player *stPlayer, frame []byte) {
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
		pb := &pb_battle.Frames{
			Data: frames,
		}
		data, err := proto.Marshal(pb)
		if err != nil {
			fmt.Println("marshal frames err:", err)
			continue
		}
		p.sendToAllPlayer(int(pb_battle.MsgType_frame), data)
	}
}

func (p *stRoom) getFrames() [][]byte {
	defer p.mutex.Unlock()
	p.mutex.Lock()

	frames := make([][]byte, 0)
	for {
		select {
		case frame := <-p.chFrame:
			frames = append(frames, frame)
		default:
			return frames
		}
	}
}

func (p *stRoom) sendToAllPlayer(msgType int, data []byte) {
	for e := p.players.Front(); e != nil; e = e.Next() {
		e.Value.(*stPlayer).conn.Write(msgType, data)
	}
}
