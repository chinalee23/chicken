package netdef

import (
	"network/message"
)

type Connection interface {
	Start(chan *message.Message)
	Close()
	Write(int, []byte)
	Disconnected() bool
}

type Server interface {
	Start(chan Connection)
	Close()
}
