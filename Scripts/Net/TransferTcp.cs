using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Collections.Generic;

namespace Net {
    class TransferTcp : Transfer {
        public TransferTcp() {
            msgQueue = new List<Message>();
        }
        
        List<Message> msgQueue;
        Action cbConnect;

        byte[] pack(int msgType, byte[] msg) {
            int len = msg.Length;

            byte[] btLen;
            if (len > 127) {
                btLen = new byte[2];
                btLen[0] = (byte)(((len >> 8) & 0x7f) | 0x80);
                btLen[1] = (byte)(len & 0xff);
            } else {
                btLen = new byte[1];
                btLen[0] = (byte)len;
            }
            byte[] btData = new byte[btLen.Length + len + 2];
            Array.Copy(btLen, 0, btData, 0, btLen.Length);

            byte[] btType = BitConverter.GetBytes(IPAddress.HostToNetworkOrder((short)msgType));
            Array.Copy(btType, 0, btData, btLen.Length, 2);

            Array.Copy(msg, 0, btData, btLen.Length + 2, len);

            return btData;
        }

        bool unpack(ref int offset) {
            if ((offset + 3) > dataBuffer.len) {
                return false;
            }

            int sz;
            int szLen;
            if (dataBuffer.bt[offset] > 127) {
                sz = (dataBuffer.bt[offset] & 0x7f) * 256 + dataBuffer.bt[offset + 1];
                szLen = 2;
            } else {
                sz = dataBuffer.bt[offset];
                szLen = 1;
            }
            if ((offset + szLen + 2 + sz) > dataBuffer.len) {
                return false;
            }
            short msgType = IPAddress.NetworkToHostOrder(BitConverter.ToInt16(dataBuffer.bt, offset + szLen));

            Message msg = new Message();
            msg.msgType = msgType;
            msg.msg = new byte[sz];
            Array.Copy(dataBuffer.bt, offset + szLen + 2, msg.msg, 0, sz);

            msgQueue.Add(msg);

            offset += sz + szLen + 2;
            return true;
        }

        void read() {
            while (true) {
                try {
                    int sz = socket.Receive(socketBuffer.bt, socketBuffer.len, Definition.BUFFER_SIZE - socketBuffer.len, SocketFlags.None);
                    socketBuffer.len += sz;
                    copyToDataBuffer();
                } catch (Exception e) {
                    error(e);
                    return;
                }
            }
        }

        void onConnect(IAsyncResult ar) {
            try {
                socket.EndConnect(ar);
                threadRead = new Thread(new ThreadStart(read));
                threadRead.Start();

                Connected = true;
                cbConnect();
            }
            catch (Exception e) {
                error(e);
                cbConnect();
                return;
            }
        }

        public override void Connect(IPEndPoint remote, Action cb) {
            Connected = false;
            cbConnect = cb;
            try {
                socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                socket.BeginConnect(remote, onConnect, null);
            } catch (Exception e) {
                cb();
                error(e);
            }
        }

        public override void Send(int msgType, byte[] msg) {
            byte[] data = pack(msgType, msg);
            try {
                socket.Send(data, data.Length, SocketFlags.None);
            } catch (Exception e) {

            }
        }

        public override void Update() {
            lock (dataBuffer) {
                int offset = 0;
                while (unpack(ref offset)) { }
                Array.Copy(dataBuffer.bt, offset, dataBuffer.bt, 0, dataBuffer.len - offset);
                dataBuffer.len -= offset;
            }
        }

        public override Message Recv() {
            if (msgQueue.Count > 0) {
                Message msg = msgQueue[0];
                msgQueue.RemoveAt(0);
                return msg;
            } else {
                return null;
            }
        }
    }
}
