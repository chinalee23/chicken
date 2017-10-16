using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NetSystem : Singleton<NetSystem> {
    private Net.NetTcp T;

    public void Init() {
        T = new Net.NetTcp();
    }

    public void Connect(string ip, int port, Net.Common.ConnectCallback cb) {
        System.Net.IPEndPoint ep = new System.Net.IPEndPoint(System.Net.IPAddress.Parse(ip), port);
        T.AsyncConnect(ep, cb);
    }

    public void Send(byte[] data) {
        T.Send(data);
    }

    public byte[] Recv() {
        return T.Recv();
    }

    public void Dispose() {
        if (T != null) {
            T.Disconnect();
        }
    }

    public void Update() {
        T.Update();
        while (true) {
            byte[] data = T.Recv();
            if (data == null) {
                break;
            }
            LuaManager.Instance().ProcessMsg(data);
        }
    }
}
