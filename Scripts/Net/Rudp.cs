using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Net {
    class Rudp {
        public class PackageBuffer {
            public const int PACKAGE_LEN = 256;
            public byte[] buffer;
            public int len;

            public PackageBuffer() {
                buffer = new byte[PACKAGE_LEN];
                len = 0;
            }
        }

        const int TYPE_HEARTBEAT = 0;
        const int TYPE_REQUEST = 1;
        const int TYPE_DATA = 2;

        class Message {
            public byte[] data;
            public int id;
            public int tick;
        }

        private bool crashed;
        private int curr_tick;
        private int send_delay;
        private int expired_interval;
        private int send_id;
        private int recv_id_min;
        private int recv_id_max;

        private List<Message> send_queue;
        private List<Message> recv_queue;
        private List<Message> history_queue;
        private List<int> request_queue;
        private List<PackageBuffer> pkg_queue;


        public Rudp() {
            crashed = false;
            curr_tick = 0;
            send_delay = 0;
            expired_interval = 10;
            send_id = 0;
            recv_id_min = recv_id_max = 0;

            send_queue = new List<Message>();
            recv_queue = new List<Message>();
            history_queue = new List<Message>();
            request_queue = new List<int>();
            pkg_queue = new List<PackageBuffer>();
        }

        private Message newMessage(byte[] buffer, int offset, int len) {
            Message msg = new Message();
            msg.id = 0;
            msg.tick = 0;
            msg.data = new byte[len];
            Array.Copy(buffer, offset, msg.data, 0, len);

            return msg;
        }

        private int fillHeader(byte[] buffer, int offset, int len, int id) {
            if (len < 128) {
                buffer[offset] = (byte)len;
                offset += 1;
            } else {
                buffer[offset] = (byte)(((len & 0x7f00) >> 8) | 0x80);
                offset += 1;
                buffer[offset] = (byte)(len & 0xff);
                offset += 1;
            }
            buffer[offset] = (byte)((id & 0xff00) >> 8);
            offset += 1;
            buffer[offset] = (byte)(id & 0xff);
            offset += 1;

            return offset;
        }

        private int getId(byte[] buffer, int offset) {
            return buffer[offset] * 256 + buffer[offset + 1];
        }

        private void insertMessage(byte[] buffer, int offset, int len, int id) {
            if (id < recv_id_min) { // a past message
                return;
            }

            Message msg = newMessage(buffer, offset, len);
            msg.id = id;
            if (id > recv_id_max || recv_queue.Count == 0) {
                recv_queue.Add(msg);
                recv_id_max = id;
            } else {
                for (int i = 0; i < recv_queue.Count; ++i) {
                    if (recv_queue[i].id == id) {   // already received
                        return;
                    } else if (recv_queue[i].id > id) { // insert here
                        recv_queue.Insert(i, msg);
                        break;
                    }
                }
            }
        }

        private void insertRequest(int id) {
            int index = -1;
            for (int i = 0; i < request_queue.Count; ++i) {
                if (request_queue[i] == id) {
                    return;
                } else if (request_queue[i] > id) {
                    index = i;
                }
            }
            if (index == -1) {
                request_queue.Add(id);
            } else {
                request_queue.Insert(index, id);
            }
        }

        private void packMessage(Message msg, PackageBuffer pkgBuffer) {
            int lenData = msg.data.Length;
            int lenPackage = (lenData < 128) ? lenData + 3 : lenData + 4;

            if ((PackageBuffer.PACKAGE_LEN - pkgBuffer.len) < lenPackage) {
                pkg_queue.Add(pkgBuffer);
                pkgBuffer = new PackageBuffer();
            }

            pkgBuffer.len = fillHeader(pkgBuffer.buffer, pkgBuffer.len, lenData + TYPE_DATA, msg.id);
            Array.Copy(msg.data, 0, pkgBuffer.buffer, pkgBuffer.len, lenData);
            pkgBuffer.len += lenData;
        }

        private void packRequest(PackageBuffer pkgBuffer, int id) {
            if ((PackageBuffer.PACKAGE_LEN - pkgBuffer.len) < 3) {
                pkg_queue.Add(pkgBuffer);
                pkgBuffer = new PackageBuffer();
            }

            pkgBuffer.len = fillHeader(pkgBuffer.buffer, pkgBuffer.len, TYPE_REQUEST, id);
        }

        private void packHeartbeat(PackageBuffer pkgBuffer) {
            if (pkgBuffer.len == PackageBuffer.PACKAGE_LEN) {
                pkg_queue.Add(pkgBuffer);
                pkgBuffer = new PackageBuffer();
            }
            pkgBuffer.buffer[pkgBuffer.len++] = (byte)TYPE_HEARTBEAT;
        }

        private void unpack(byte[] data, int len) {
            int offset = 0;
            while (offset < len) {
                int tag = data[offset];
                if (tag > 127) {
                    tag = (tag * 256 + data[1]) & 0x7fff;
                    offset += 2;
                } else {
                    offset += 1;
                }
                switch (tag) {
                    case TYPE_HEARTBEAT:
                        break;
                    case TYPE_REQUEST:
                        insertRequest(getId(data, offset));
                        offset += 2;
                        break;
                    default:
                        int dataLen = tag - TYPE_DATA;
                        if ((offset + 2 + dataLen) > len) {
                            crashed = true;
                            return;
                        }
                        insertMessage(data, offset + 2, dataLen, getId(data, offset));
                        offset += 2 + dataLen;
                        break;
                }
            }
        }

        private void clearExpired() {
            int index = -1;
            for (int i = 0; i < history_queue.Count; ++i) {
                Message msg = history_queue[i];
                if ((msg.tick + expired_interval) < curr_tick) {    // expired, remove all msg before this(include this)
                    index = i;
                } else {
                    break;
                }
            }
            history_queue.RemoveRange(0, index + 1);
        }

        private void requestMissing(PackageBuffer buffer) {
            int id = recv_id_min;
            for (int i = 0; i < recv_queue.Count; ++i) {
                if (recv_queue[i].id > id) {
                    for (int j = id; j < recv_queue[i].id; j++) {
                        packRequest(buffer, j);
                    }
                }
                id = recv_queue[i].id + 1;
            }
        }

        private void replyRequest(PackageBuffer pkgBuffer) {
            for (int i = 0; i < request_queue.Count; ++i) {
                int id = request_queue[i];
                int index = -1;
                for (int j = 0; j < history_queue.Count; ++j) {
                    if (id < history_queue[j].id) {
                        break;
                    } else if (id == history_queue[j].id) {
                        index = j;
                        break;
                    }
                }
                if (index == -1) {  // expired
                    crashed = true;
                } else {
                    packMessage(history_queue[index], pkgBuffer);
                }
            }

            request_queue.Clear();
        }

        private void sendMessages(PackageBuffer pkgBuffer) {
            int i = 0;
            for (; i < send_queue.Count; ++i) {
                if ((send_queue[i].tick + send_delay) > curr_tick) {
                    break;
                }
                packMessage(send_queue[i], pkgBuffer);
                history_queue.Add(send_queue[i]);
            }
            send_queue.RemoveRange(0, i);
        }

        private void genPackages() {
            PackageBuffer pkgBuffer = new PackageBuffer();

            requestMissing(pkgBuffer);
            replyRequest(pkgBuffer);
            sendMessages(pkgBuffer);

            if (pkgBuffer.len == 0) {
                packHeartbeat(pkgBuffer);
            }

            pkg_queue.Add(pkgBuffer);
        }

        public void Send(byte[] data, int len) {
            Message msg = newMessage(data, 0, len);
            msg.id = send_id++;
            msg.tick = curr_tick;

            send_queue.Add(msg);
        }

        public byte[] Recv() {
            if (recv_queue.Count == 0) {
                return null;
            }
            Message msg = recv_queue[0];
            if (msg.id != recv_id_min) {
                return null;
            }
            recv_id_min++;
            recv_queue.RemoveAt(0);

            return msg.data;
        }

        public List<PackageBuffer> Update(byte[] data = null, int len = 0) {
            curr_tick++;
            pkg_queue.Clear();
            if (data != null && len > 0) {
                unpack(data, len);
            }
            genPackages();

            return pkg_queue;
        }
    }
}
