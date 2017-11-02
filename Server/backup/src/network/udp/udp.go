package udp

import (
	"net"
	"network/message"
	"network/rudp"
	"sync"
	"time"
)

type stUdp struct {
	id     uint32
	addr   net.Addr
	u      *rudp.Rudp
	chsend chan *stSendPackage
	chmsg  chan *message.Message
	chexit chan bool
	wg     sync.WaitGroup
}

func newUdp(id uint32, addr net.Addr, chsend chan *stSendPackage, chmsg chan *message.Message) *stUdp {
	return &stUdp{
		id:     id,
		addr:   addr,
		u:      rudp.New(),
		chsend: chsend,
		chmsg:  chmsg,
		chexit: make(chan bool),
	}
}

func (p *stUdp) start() {
	p.wg.Add(1)
	go func() {
		defer p.wg.Done()
		for {
			select {
			case <-p.chexit:
				return
			default:
				pkgs := p.u.Update()
				for e := pkgs.Front(); e != nil; e = e.Next() {
					data := e.Value.([]byte)
					p.chsend <- &stSendPackage{
						addr: p.addr,
						data: data,
					}
				}
				time.Sleep(10 * time.Millisecond)
			}
		}
	}()
}

func (p *stUdp) close() {
	close(p.chexit)
	p.wg.Wait()
}

func (p *stUdp) write(msgType int, msg []byte) {
	data := p.pack(msgType, msg)
	p.u.Send(data, len(data))
}

func (p *stUdp) recv(data []byte) {
	p.u.Unpack(data, len(data))
	for {
		data = p.u.Recv()
		if data == nil {
			break
		}
		p.unpack(data)
	}
}

func (p *stUdp) pack(msgType int, msg []byte) []byte {
	data := make([]byte, 0)
	data = append(data, message.ToBytes(msgType)...)
	data = append(data, msg...)
	return data
}

func (p *stUdp) unpack(data []byte) {
	msgType := message.ToInt(data[:2])
	data = data[2:]
	msg := &message.Message{
		ConnId:  p.id,
		MsgType: msgType,
		Data:    data,
	}
	p.chmsg <- msg
}
