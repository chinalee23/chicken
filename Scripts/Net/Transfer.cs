using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace Net {
    class Transfer {
        protected Socket socket;
        protected Thread threadRead;

        protected Buffer socketBuffer;
        protected Buffer dataBuffer;

        public bool Connected {
            get;
            protected set;
        }

        public Transfer() {
            socketBuffer = new Buffer();
            dataBuffer = new Buffer();

            Connected = false;
        }

        ~Transfer() {
            if (threadRead != null) {
                threadRead.Abort();
            }
            if (socket != null) {
                socket.Close();
            }
        }

        protected void copyToDataBuffer() {
            lock (dataBuffer) {
                int copyLen = Definition.BUFFER_SIZE - dataBuffer.len;
                if (copyLen > socketBuffer.len) {
                    copyLen = socketBuffer.len;
                }
                if (copyLen == 0) {
                    return;
                }
                Array.Copy(socketBuffer.bt, 0, dataBuffer.bt, dataBuffer.len, copyLen);
                dataBuffer.len += copyLen;

                if (copyLen == socketBuffer.len) {
                    socketBuffer.len = 0;
                } else {
                    Array.Copy(socketBuffer.bt, copyLen, socketBuffer.bt, 0, socketBuffer.len - copyLen);
                    socketBuffer.len -= copyLen;
                }
            }
        }

        protected void error(Exception e) {
            Disconnect();
            throw e;
        }

        public void Disconnect() {
            if (threadRead != null) {
                threadRead.Abort();
            }
            if (socket != null) {
                socket.Close();
            }
            socketBuffer.len = 0;
            dataBuffer.len = 0;

            Connected = false;
        }

        public virtual void Connect(IPEndPoint remote, Action cb) { }
        public virtual void Send(int msgType, byte[] msg) { }
        public virtual void Update() { }
        public virtual Message Recv() { return null; }
    }
}
