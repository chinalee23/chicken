package tcp

import (
	"fmt"
	"net"
	"network/netdef"
	"sync"
)

type stTcpServer struct {
	svr   *net.TCPListener
	conns []*stTcp
	wg    sync.WaitGroup
	eh    func(error)
}

func NewServer(addr string, eh func(error)) (stTcpServer, error) {
	var tcpServer stTcpServer

	laddr, err := net.ResolveTCPAddr("tcp", addr)
	if err != nil {
		fmt.Println("tcp addr[", addr, "] error:", err)
		return tcpServer, err
	}
	svr, err := net.ListenTCP("tcp", laddr)
	if err != nil {
		fmt.Println("tcp listen[", addr, "] error:", err)
		return tcpServer, err
	}
	fmt.Println("tcp listen[", addr, "] success")
	return stTcpServer{
		svr:   svr,
		conns: make([]*stTcp, 0),
		eh:    eh,
	}, nil
}

func (p stTcpServer) Start(chClient chan netdef.Connection) {
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

func (p stTcpServer) Close() {
	p.svr.Close()
	p.wg.Wait()
	for _, conn := range p.conns {
		conn.Close()
	}
}

func (p stTcpServer) accept(conn *net.TCPConn, chClient chan netdef.Connection) {
	tcp := newTcp(conn)
	p.conns = append(p.conns, tcp)
	chClient <- tcp
}
