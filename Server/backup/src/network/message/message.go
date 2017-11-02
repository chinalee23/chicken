package network

import (
	"bytes"
	"encoding/binary"
)

type Message struct {
	ConnId  uint32
	MsgType int
	Data    []byte
}

func toBytes(n int) []byte {
	tmp := int16(n)
	bytesBuffer := bytes.NewBuffer([]byte{})
	binary.Write(bytesBuffer, binary.BigEndian, tmp)
	return bytesBuffer.Bytes()
}

func toInt(b []byte) int {
	bytesBuffer := bytes.NewBuffer(b)
	var tmp int16
	binary.Read(bytesBuffer, binary.BigEndian, &tmp)
	return int(tmp)
}
