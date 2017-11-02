using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

public class NetSystem : Singleton<NetSystem> {
    private Net.Transfer transfer;

    private LuaFunction cbConnect;
    private bool waitConnect;
    private bool recvConnect;

    public void Init() {
        transfer = new Net.TransferTcp();
        //transfer = new Net.TransferUdp();

        waitConnect = false;
        recvConnect = false;
    }

    public void Connect(string ip, int port, LuaFunction cb) {
        cbConnect = cb;
        System.Net.IPEndPoint ep = new System.Net.IPEndPoint(System.Net.IPAddress.Parse(ip), port);
        waitConnect = true;
        recvConnect = false;

        transfer.Connect(ep, delegate () {
            recvConnect = true;
        });
    }

    public void Send(int msgType, byte[] data) {
        transfer.Send(msgType, data);
    }

    public void Update() {
        if (waitConnect) {
            if (recvConnect) {
                waitConnect = false;
                if (cbConnect != null) {
                    cbConnect.Call(transfer.Connected);
                }
            }
        }
        
        if (!transfer.Connected) {
            return;
        }
        
        transfer.Update();
        while (true) {
            Net.Message msg = transfer.Recv();
            if (msg == null) {
                break;
            }
            LuaManager.Instance().ProcessMsg(msg.msgType, msg.msg);
        }
    }

    public void Dispose() {
        if (transfer != null) {
            transfer.Disconnect();
        }
    }
}
