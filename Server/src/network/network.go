package network

import (
	"net"
)

type Message struct {
	Id   int
	Data []byte
}

var ChMessage chan *Message
var buffMessaage []*Message

var connections []*connection

func handleClient(conn net.Conn) {
	c := newConnection(len(connections), conn)
	connections = append(connections, c)
	c.start()
}

func recv() {
	for {
		for i := 0; i < len(connections); i++ {
			c := connections[i]
			select {
			case data := <-c.chrecv:
				unpack(c, data)
			default:
				break
			}
		}
	}
}

func unpack(c *connection, data []byte) {
	tmp := make([]byte, 0)
	tmp = append(tmp, c.buffer...)
	tmp = append(tmp, data...)

	for {
		sz := int(tmp[0])
		if sz+1 > len(tmp) {
			c.buffer = tmp
			break
		}
		msg := &Message{
			Id:   c.id,
			Data: tmp[1 : sz+1],
		}

		select {
		case ChMessage <- msg:
			break
		default:
			buffMessaage = append(buffMessaage, msg)
		}

		tmp = tmp[1+sz:]
	}
}

func Start() {
	connections = make([]*connection, 0)

	ChMessage = make(chan *Message, 1024)
	buffMessaage = make([]*Message, 0)

	go startTcp()
	go recv()
}

func Send(id int, data []byte) {
	if id >= len(connections) {
		return
	}
	select {
	case connections[id].chsend <- data:
		return
	default:
		return
	}
}

func Recv(id int) []byte {
	if id >= len(connections) {
		return nil
	}
	select {
	case data := <-connections[id].chrecv:
		return data
	default:
		return nil
	}
}
