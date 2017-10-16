using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace Net {
    class TransferUdp : Transfer {
        EndPoint rep;
        bool binded = false;

        public TransferUdp(Buffer buffer) : base(buffer) {
        }

        void read() {
            while (true) {
                try {
                    if (!binded) {
                        Thread.Sleep(10);
                        continue;
                    }
                    EndPoint ep = new IPEndPoint(IPAddress.Any, 0);
                    int sz = socket.ReceiveFrom(socketBuffer.bt, socketBuffer.len, Common.BUFFER_SIZE - socketBuffer.len, SocketFlags.None, ref ep);
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

        public override void AsyncConnect(IPEndPoint remote, Common.ConnectCallback cb) {
            cbConnect = cb;
            try {
                rep = remote;
                socket = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp);

                thRead = new Thread(new ThreadStart(read));
                thRead.Start();

                Connected = true;
                cbConnect(true);
            } catch (Exception e) {
                error(e);
                cbConnect(false);
            }
        }

        public override void Send(byte[] data, int len) {
            try {
                socket.SendTo(data, len, SocketFlags.None, rep);
                if (!binded) {
                    binded = true;
                }
            } catch (Exception e) {
                error(e);
            }
        }
    }
}
