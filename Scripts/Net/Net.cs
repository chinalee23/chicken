namespace Net {

    class Common {
        public static int BUFFER_SIZE = 1024;

        public static System.Action<string> Print;
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
        void Connect(System.Net.IPEndPoint remote);
        void Update();
        void Send(byte[] data);
        byte[] Recv();
        void Disconnect();
        bool Connected();
    }
}
