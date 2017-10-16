using System;
using System.Collections.Generic;
using System.Net;

namespace Net {
    class NetTcp : INet{
        TransferTcp transfer;
        Buffer buffer;
        List<byte[]> msg_queue;

        public NetTcp() {
            buffer = new Buffer();
            transfer = new TransferTcp(buffer);
            msg_queue = new List<byte[]>();
        }

        byte[] pack(byte[] data) {
            int len = data.Length;

            byte[] btLen;
            if (len > 127) {
                btLen = new byte[2];
                btLen[0] = (byte)(((len >> 8) & 0x7f) | 0x80);
                btLen[1] = (byte)(len & 0xff);
            } else {
                btLen = new byte[1];
                btLen[0] = (byte)len;
            }
            byte[] btMsg = new byte[btLen.Length + len];
            Array.Copy(btLen, 0, btMsg, 0, btLen.Length);
            Array.Copy(data, 0, btMsg, btLen.Length, len);

            return btMsg;
        }

        bool unpack(ref int offset) {
            int sz;
            int szLen;
            if (buffer.bt[offset] > 127) {
                if (offset == buffer.len) {
                    return false;
                }
                sz = (buffer.bt[offset] & 0x7f) * 256 + buffer.bt[offset + 1];
                szLen = 2;
            } else {
                sz = buffer.bt[offset];
                szLen = 1;
            }
            if ((buffer.len - offset - szLen) < sz) {
                return false;
            }
            byte[] bt = new byte[sz];
            Array.Copy(buffer.bt, offset + szLen, bt, 0, sz);
            msg_queue.Add(bt);

            offset += sz + szLen;
            return true;
        }

        public void AsyncConnect(System.Net.IPEndPoint remote, Common.ConnectCallback cb) {
            transfer.AsyncConnect(remote, cb);
        }

        public void Update() {
            lock(buffer) {
                int offset = 0;
                while (offset < buffer.len) {
                    if (!unpack(ref offset)) {
                        break;
                    }
                }
                Array.Copy(buffer.bt, offset, buffer.bt, 0, buffer.len - offset);
                buffer.len -= offset;
            }
        }

        public void Send(byte[] data) {
            byte[] msg = pack(data);
            transfer.Send(msg, msg.Length);
        }

        public byte[] Recv() {
            if (msg_queue.Count > 0) {
                byte[] data = msg_queue[0];
                msg_queue.RemoveAt(0);
                return data;
            } else {
                return null;
            }
        }

        public void Disconnect() {
            transfer.Disconnect();
        }

        public bool Connected() {
            return transfer.Connected;
        }
    }
}
