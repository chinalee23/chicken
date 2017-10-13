package network

import (
	"fmt"
	"net"
)

type connection struct {
	id     int
	conn   net.Conn
	chrecv chan []byte
	chsend chan []byte
	chexit chan bool
	buffer []byte
}

func newConnection(id int, conn net.Conn) *connection {
	return &connection{
		id:     id,
		conn:   conn,
		chrecv: make(chan []byte, 1024),
		chsend: make(chan []byte, 1024),
		chexit: make(chan bool),
	}
}

func (p *connection) start() {
	go p.send()
	go p.recv()
}

func (p *connection) recv() (err error) {
	defer func() {
		if err != nil {
			p.conn.Close()
			p.chexit <- true
		}
	}()

	for {
		buff := make([]byte, 1024)
		sz, err := p.conn.Read(buff)
		if err != nil {
			fmt.Println("read err:", err)
			return err
		}
		p.chrecv <- buff[:sz]
	}
}

func (p *connection) send() {
	defer func() {
		p.conn.Close()
	}()

	for {
		select {
		case <-p.chexit:
			return
		case data := <-p.chsend:
			sz, err := p.conn.Write(data)
			if err != nil || sz != len(data) {
				fmt.Println("write err:", err)
				return
			}
		}
	}
}
