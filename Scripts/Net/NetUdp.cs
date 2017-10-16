using System;
using System.Collections.Generic;

namespace Net {
    class NetUdp : INet {
        Buffer buffer;
        Transfer transfer;

        Rudp U;

        public NetUdp() {
            buffer = new Buffer();
            transfer = new TransferUdp(buffer);

            U = new Rudp();
        }

        public void AsyncConnect(System.Net.IPEndPoint remote, Common.ConnectCallback cb) {
            transfer.AsyncConnect(remote, cb);
        }

        public void Update() {
            lock (buffer) {
                List<Rudp.PackageBuffer> pkgs = U.Update(buffer.bt, buffer.len);
                for (int i = 0; i < pkgs.Count; ++i) {
                    transfer.Send(pkgs[i].buffer, pkgs[i].len);
                }
            }
        }

        public void Send(byte[] data) {
            U.Send(data, data.Length);
        }

        public byte[] Recv() {
            return U.Recv();
        }

        public void Disconnect() {
            transfer.Disconnect();
        }

        public bool Connected() {
            return transfer.Connected;
        }
    }
}
