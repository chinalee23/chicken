using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NetSystem : Singleton<NetSystem> {
    Net.NetUdp U;

    public void Init() {
        U = new Net.NetUdp();
    }

    public void Connect() {
        System.Net.IPEndPoint ep = new System.Net.IPEndPoint(System.Net.IPAddress.Parse("192.168.142.140"), 12345);
        U.Connect(ep);
    }

    public void Send(byte[] data) {
        U.Send(data);
    }

    public byte[] Recv() {
        return U.Recv();
    }
}
