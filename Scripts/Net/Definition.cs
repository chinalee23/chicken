using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Net {
    class Definition {
        public static int BUFFER_SIZE = 512 * 1024;
    }

    class Buffer {
        public byte[] bt;
        public int len;
        public Buffer() {
            bt = new byte[Definition.BUFFER_SIZE];
            len = 0;
        }
    }

    class Message {
        public int msgType;
        public byte[] msg;
    }
}
