using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Collections.Generic;

namespace Net {
    class TransferUdp : Transfer {
        public TransferUdp() {
            U = new Rudp();
        }

        EndPoint rep;
        bool binded = false;
        Rudp U;

        void read() {
            while (true) {
                try {
                    if (!binded) {
                        Thread.Sleep(10);
                        continue;
                    }
                    EndPoint ep = new IPEndPoint(IPAddress.Any, 0);
                    int sz = socket.ReceiveFrom(socketBuffer.bt, socketBuffer.len, Definition.BUFFER_SIZE - socketBuffer.len, SocketFlags.None, ref ep);
                    if (!ep.Equals(rep)) {
                        continue;
                    }

                    socketBuffer.len += sz;
                    copyToDataBuffer();
                }
                catch (Exception e) {
                    error(e);
                    return;
                }
            }
        }

        void send(byte[] data, int len) {
            try {
                socket.SendTo(data, data.Length, SocketFlags.None, rep);
                if (!binded) {
                    binded = true;
                }
            }
            catch (Exception e) {
                error(e);
            }
        }

        byte[] pack(int msgType, byte[] msg) {
            byte[] btType = BitConverter.GetBytes(IPAddress.HostToNetworkOrder((short)msgType));
            byte[] btData = new byte[msg.Length + 2];
            Array.Copy(btType, 0, btData, 0, 2);
            Array.Copy(msg, 0, btData, 2, msg.Length);
            return btData;
        }

        Message unpack(byte[] btData) {
            short msgType = IPAddress.NetworkToHostOrder(BitConverter.ToInt16(btData, 0));
            Message msg = new Message();
            msg.msgType = msgType;
            msg.msg = new byte[btData.Length - 2];
            Array.Copy(btData, 2, msg.msg, 0, btData.Length - 2);
            return msg;
        }

        public override void Connect(IPEndPoint remote, Action cb) {
            try {
                rep = remote;
                socket = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp);

                threadRead = new Thread(new ThreadStart(read));
                threadRead.Start();

                Connected = true;
                cb();
            } catch (Exception e) {
                cb();
                error(e);
            }
        }

        public override void Send(int msgType, byte[] msg) {
            byte[] data = pack(msgType, msg);
            U.Send(data, data.Length);
        }

        public override void Update() {
            lock (dataBuffer) {
                List<Rudp.PackageBuffer> pkgs = U.Update(dataBuffer.bt, dataBuffer.len);
                for (int i = 0; i < pkgs.Count; ++i) {
                    send(pkgs[i].buffer, pkgs[i].len);
                }
                dataBuffer.len = 0;
            }
        }

        public override Message Recv() {
            byte[] btData = U.Recv();
            if (btData == null) {
                return null;
            } else {
                return unpack(btData);
            }
        }
    }
}
