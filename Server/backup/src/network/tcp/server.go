package network

import (
	"fmt"
	"net"
	"sync"
	"sync/atomic"
)

type stTcpServer struct {
	svr    *net.TCPListener
	conns  map[uint32]*TcpConn
	nextId uint32
	wg     sync.WaitGroup
	eh     func(error)
}

func NewTcpServer(addr string, eh func(error)) *stTcpServer {
	laddr, err := net.ResolveTCPAddr("tcp", addr)
	if err != nil {
		fmt.Println("tcp addr[", addr, "] error:", err)
		return nil
	}
	svr, err := net.ListenTCP("tcp", laddr)
	if err != nil {
		fmt.Println("tcp listen[", addr, "] error:", err)
		return nil
	}
	return &stTcpServer{
		svr:    svr,
		conns:  make(map[uint32]*TcpConn),
		nextId: 0,
		eh:     eh,
	}
}

func (p *stTcpServer) Start(chClient chan *Connection) {
	p.wg.Add(1)
	go func() {
		defer p.wg.Done()
		for {
			conn, err := p.svr.AcceptTCP()
			if err != nil {
				fmt.Println("tcp[", p.svr.Addr(), "] accept error:", err)
				p.eh(err)
			} else {
				p.accept(conn, chClient)
			}
		}
	}()
}

func (p *stTcpServer) Close() {
	p.svr.Close()
	p.wg.Wait()
	for _, conn := range p.conns {
		conn.close()
	}
}

func (p *stTcpServer) accept(conn *net.TCPConn, chClient chan *Connection) {
	atomic.AddUint32(&p.nextId, 1)
	tcp := newTcp(p.nextId, conn)
	p.conns[p.nextId] = tcp
	chclient <- tcp
}
