namespace Net {

    public class Common {
        public static int BUFFER_SIZE = 1024;

        public static System.Action<string> Print;

        public delegate void ConnectCallback(bool status);
    }

    class Buffer {
        public byte[] bt;
        public int len;
        public Buffer() {
            bt = new byte[Common.BUFFER_SIZE];
            len = 0;
        }
    }

    interface INet {
        void AsyncConnect(System.Net.IPEndPoint remote, Common.ConnectCallback cb);
        void Update();
        void Send(byte[] data);
        byte[] Recv();
        void Disconnect();
        bool Connected();
    }
}
