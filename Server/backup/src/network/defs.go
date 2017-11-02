package network

type Server interface {
	Start()
	Close()
}

type Connection interface {
	Start(chan *Message)
	Close()
	Write(int, []byte)
	Disconnected() bool
}
