package network

import (
	"fmt"
	"net"
)

func startTcp() {
	laddr, err := net.ResolveTCPAddr("tcp", "192.168.59.128:12345")
	if err != nil {
		fmt.Println("addr err:", err)
		return
	}
	svr, err := net.ListenTCP("tcp", laddr)
	if err != nil {
		fmt.Println("listen err:", err)
		return
	}
	fmt.Println("listening...")
	for {
		conn, err := svr.Accept()
		if err != nil {
			fmt.Println("accept err:", err)
			break
		}
		fmt.Println("accept a client:", conn.RemoteAddr())
		handleClient(conn)
	}
}
