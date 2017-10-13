package network

import (
	"fmt"
	"net"
)

func startTcp() {
	laddr, err := net.ResolveTCPAddr("tcp", "192.168.142.140:12345")
	if err != nil {
		fmt.Println("addr err:", err)
		return
	}
	svr, err := net.ListenTCP("tcp", laddr)
	if err != nil {
		fmt.Println("listen err:", err)
		return
	}

	for {
		conn, err := svr.Accept()
		if err != nil {
			fmt.Println("accept err:", err)
			break
		}
		handleClient(conn)
	}
}
