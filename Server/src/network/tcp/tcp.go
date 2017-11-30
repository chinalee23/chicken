package tcp

import (
	"fmt"
	"net"
	"network/message"
	"sync"
)

type stTcp struct {
	conn         *net.TCPConn
	disconnected bool
	buff         []byte
	chsend       chan []byte
	chexit       chan bool
	wg           sync.WaitGroup
	chmsg        chan *message.Message
}

func newTcp(conn *net.TCPConn) *stTcp {
	return &stTcp{
		conn:         conn,
		disconnected: false,
		buff:         make([]byte, 0),
		chsend:       make(chan []byte),
		chexit:       make(chan bool),
	}
}

func (p *stTcp) Start(chmsg chan *message.Message) {
	p.chmsg = chmsg

	p.wg.Add(2)
	go func() {
		defer p.wg.Done()
		p.recv()
	}()

	go func() {
		defer p.wg.Done()
		p.send()
	}()
}

func (p *stTcp) Close() {
	close(p.chexit)
	p.conn.Close()
	p.wg.Wait()
}

func (p *stTcp) Write(msgType int, msg []byte) {
	data := p.pack(msgType, msg)
	p.chsend <- data
}

func (p *stTcp) Disconnected() bool {
	return p.disconnected
}

func (p *stTcp) recv() (err error) {
	defer func() {
		if err != nil {
			select {
			case <-p.chexit:
				err = nil
			default:
				p.disconnected = true
			}
		}
	}()

	for {
		select {
		case <-p.chexit:
			return
		default:
			data := make([]byte, 1024)
			sz, err := p.conn.Read(data)
			if err != nil {
				fmt.Println("tcp read err:", err)
				return err
			}
			p.buff = append(p.buff, data[:sz]...)
			p.unpack()
		}
	}
}

func (p *stTcp) send() {
	for {
		select {
		case <-p.chexit:
			return
		case data := <-p.chsend:
			p.conn.Write(data)
		}
	}
}

func (p *stTcp) pack(msgType int, msg []byte) []byte {
	var sz int
	if msg != nil {
		sz = len(msg)
	} else {
		sz = 0
	}
	data := make([]byte, 0)
	if sz > 127 {
		data = append(data, byte(((sz>>8)&0x7f)|0x80))
		data = append(data, byte(sz&0xff))
	} else {
		data = append(data, byte(sz))
	}
	data = append(data, message.ToBytes(msgType)...)
	if msg != nil {
		data = append(data, msg...)
	}

	return data
}

func (p *stTcp) unpack() {
	var lenBuff int
	var sz int
	var lenSz int
	for {
		lenBuff = len(p.buff)
		if lenBuff == 0 {
			break
		}
		if p.buff[0] > 127 {
			if lenBuff < 2 {
				break
			}
			sz = int((p.buff[0]&0x7f))*256 + int(p.buff[1])
			lenSz = 2
		} else {
			sz = int(p.buff[0])
			lenSz = 1
		}
		if sz+lenSz+2 > lenBuff {
			break
		}
		p.buff = p.buff[lenSz:]

		msgType := message.ToInt(p.buff[:2])
		p.buff = p.buff[2:]
		msg := &message.Message{
			MsgType: msgType,
			Data:    p.buff[:sz],
		}
		p.buff = p.buff[sz:]
		p.chmsg <- msg
	}
}
