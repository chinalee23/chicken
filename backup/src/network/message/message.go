package message

import (
	"bytes"
	"encoding/binary"
)

type Message struct {
	MsgType int
	Data    []byte
}

func ToBytes(n int) []byte {
	tmp := int16(n)
	bytesBuffer := bytes.NewBuffer([]byte{})
	binary.Write(bytesBuffer, binary.BigEndian, tmp)
	return bytesBuffer.Bytes()
}

func ToInt(b []byte) int {
	bytesBuffer := bytes.NewBuffer(b)
	var tmp int16
	binary.Read(bytesBuffer, binary.BigEndian, &tmp)
	return int(tmp)
}
