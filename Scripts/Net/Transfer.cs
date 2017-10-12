using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace Net {
    class Transfer {
        protected Socket socket;
        protected Thread thRead;

        protected Buffer socketBuffer;
        protected Buffer dataBuffer;

        public bool Connected {
            get;
            protected set;
        }

        public Transfer(Buffer buffer) {
            socketBuffer = new Buffer();
            dataBuffer = buffer;

            Connected = false;
        }

        ~Transfer() {
            if (thRead != null) {
                thRead.Abort();
            }
            if (socket != null) {
                socket.Close();
            }
        }

        void copyBuffer(Buffer socketBuffer, Buffer dataBuffer) {
            
        }

        protected void copyToDataBuffer() {
            lock (dataBuffer) {
                int copyLen = Common.BUFFER_SIZE - dataBuffer.len;
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
            if (Common.Print != null) {
                Common.Print(e.ToString());
            }
            
            Disconnect();
        }

        public void Disconnect() {
            if (thRead != null) {
                thRead.Abort();
            }
            if (socket != null) {
                socket.Close();
            }
            socketBuffer.len = 0;
            dataBuffer.len = 0;

            Connected = false;
        }

        public virtual void Connect(IPEndPoint remote) { }
        public virtual void Send(byte[] data, int len) { }
        public virtual void Update(float delta) { }
    }
}
