package network

import (
	"network/netdef"
	"network/tcp"
)

func NewTcpServer(addr string, eh func(error)) (netdef.Server, error) {
	return tcp.NewServer(addr, eh)
}
