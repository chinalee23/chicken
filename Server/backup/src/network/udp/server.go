package udp

import (
	"fmt"
	"net"
	"network/message"
	"sync"
	"sync/atomic"
)

type stSendPackage struct {
	addr net.Addr
	data []byte
}

type UdpServer struct {
	svr     *net.UDPConn
	conns   map[string]*stUdp
	id2conn map[uint32]*stUdp
	nextId  uint32
	wg      sync.WaitGroup
	chsend  chan *stSendPackage
	chexit  chan bool
	eh      func(error)

	Chmsg chan *message.Message
}

func NewServer(addr string, eh func(error)) *UdpServer {
	laddr, err := net.ResolveUDPAddr("udp", addr)
	if err != nil {
		fmt.Println("udp addr[", addr, "] error:", err)
		return nil
	}
	svr, err := net.ListenUDP("udp", laddr)
	if err != nil {
		fmt.Println("udp listen[", addr, "] error:", err)
		return nil
	}
	return &UdpServer{
		svr:     svr,
		conns:   make(map[string]*stUdp),
		id2conn: make(map[uint32]*stUdp),
		nextId:  0,
		chsend:  make(chan *stSendPackage, 1024),
		chexit:  make(chan bool),
		eh:      eh,

		Chmsg: make(chan *message.Message, 1024),
	}
}

func (p *UdpServer) Start() {
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

func (p *UdpServer) Close() {
	p.svr.Close()
	p.wg.Wait()
	for _, conn := range p.conns {
		conn.close()
	}
}

func (p *UdpServer) Read() []*message.Message {
	msgs := make([]*message.Message, 0)
	for {
		select {
		case msg := <-p.Chmsg:
			msgs = append(msgs, msg)
			break
		default:
			return msgs
		}
	}
}

func (p *UdpServer) Write(connId uint32, msgType int, msg []byte) bool {
	conn, ok := p.id2conn[connId]
	if !ok {
		return false
	}
	conn.write(msgType, msg)
	return true
}

func (p *UdpServer) recv() (err error) {
	defer func() {
		if err != nil {
			select {
			case <-p.chexit:
				err = nil
			default:
				p.eh(err)
			}
		}
	}()
	for {
		select {
		case <-p.chexit:
			return
		default:
			buf := make([]byte, 512)
			sz, addr, err := p.svr.ReadFrom(buf)
			if err != nil {
				fmt.Println("udp[", p.svr.LocalAddr(), "] read error:", err)
				return err
			}
			saddr := addr.String()
			conn, ok := p.conns[saddr]
			if !ok {
				p.accept(addr)
				conn = p.conns[saddr]
			}
			conn.recv(buf[:sz])
		}
	}
}

func (p *UdpServer) send() {
	for {
		select {
		case <-p.chexit:
			break
		case pkg := <-p.chsend:
			p.svr.WriteTo(pkg.data, pkg.addr)
			break
		}
	}
}

func (p *UdpServer) accept(addr net.Addr) {
	atomic.AddUint32(&p.nextId, 1)
	udp := newUdp(p.nextId, addr, p.chsend, p.Chmsg)
	p.conns[addr.String()] = udp
	p.id2conn[p.nextId] = udp
	udp.start()
}
