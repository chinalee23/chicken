using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace Net {
    class TransferTcp : Transfer {
        public TransferTcp(Buffer buffer) : base(buffer) {
        }

        void cbConnect(IAsyncResult ar) {
            try {
                socket.EndConnect(ar);
                thRead = new Thread(new ThreadStart(read));
                thRead.Start();

                Connected = true;
            } catch (Exception e) {
                error(e);
                return;
            }
        }

        void read() {
            while (true) {
                try {
                    int sz = socket.Receive(socketBuffer.bt, socketBuffer.len, Common.BUFFER_SIZE - socketBuffer.len, SocketFlags.None);
                    socketBuffer.len += sz;
                    copyToDataBuffer();
                } catch (Exception e) {
                    error(e);
                    return;
                }
            }
        }

        public override void Connect(IPEndPoint remote) {
            try {
                socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                socket.BeginConnect(remote, cbConnect, null);
            } catch (Exception e) {
                error(e);
            }
        }

        public override void Send(byte[] data, int len) {
            try {
                socket.Send(data, len, SocketFlags.None);
            } catch (Exception e) {

            }
        }
    }
}
