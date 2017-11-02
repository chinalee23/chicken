package rudp

import (
	"container/list"
)

const (
	MAX_PACKAGE_LEN = 0xffff

	_PACAKGE_LEN = 512

	_TYPE_HEARTBEAT = 0
	_TYPE_REQUEST   = 1
	_TYPE_DATA      = 2
)

type stMessage struct {
	data []byte
	id   int
	tick int
}

type stPackageBuffer struct {
	buffer []byte
	sz     int
}

type Rudp struct {
	curr_tick        int
	expired_interval int
	send_id          int
	recv_id_min      int
	recv_id_max      int

	send_queue    *list.List
	recv_queue    *list.List
	history_queue *list.List
	request_queue *list.List
	pkg_queue     *list.List
}

func New() *Rudp {
	return &Rudp{
		curr_tick:        0,
		expired_interval: 10,
		send_id:          0,
		recv_id_min:      0,
		recv_id_max:      0,

		send_queue:    list.New(),
		recv_queue:    list.New(),
		history_queue: list.New(),
		request_queue: list.New(),
		pkg_queue:     list.New(),
	}
}

func new_message(buffer []byte, sz int) *stMessage {
	msg := new(stMessage)
	msg.data = make([]byte, sz)
	copy(msg.data, buffer)
	return msg
}

func new_buffer() *stPackageBuffer {
	return &stPackageBuffer{
		buffer: make([]byte, _PACAKGE_LEN),
		sz:     0,
	}
}

func fill_header(buffer []byte, sz int, id int) int {
	var offset int
	if sz < 128 {
		buffer[0] = byte(sz)
		offset = 1
	} else {
		buffer[0] = byte((sz&0x7f00)>>8) | 0x80
		buffer[1] = byte(sz & 0xff)
		offset = 2
	}

	buffer[offset] = byte((id & 0xff00) >> 8)
	buffer[offset+1] = byte(id & 0xff)

	return offset + 2
}

func get_id(buffer []byte) int {
	return int(buffer[0])*256 + int(buffer[1])
}

func (p *Rudp) insert_message(buffer []byte, sz int, id int) {
	if id < p.recv_id_min { // a past message
		return
	}

	msg := new_message(buffer, sz)
	msg.id = id
	if id > p.recv_id_max || p.recv_queue.Len() == 0 {
		p.recv_queue.PushBack(msg)
		p.recv_id_max = id
	} else {
		for e := p.recv_queue.Front(); e != nil; e = e.Next() {
			tmp := e.Value.(*stMessage)
			if tmp.id == id { // already exists
				return
			} else if tmp.id > id {
				p.recv_queue.InsertBefore(msg, e)
				break
			}
		}
	}
}

func (p *Rudp) insert_request(id int) {
	for e := p.request_queue.Front(); e != nil; e = e.Next() {
		tmp := e.Value.(int)
		if tmp == id {
			return
		} else if tmp > id {
			p.request_queue.InsertBefore(id, e)
			return
		}
	}
	p.request_queue.PushBack(id)
}

func (p *Rudp) pack_message(msg *stMessage, pkgBuffer *stPackageBuffer) {
	dataLen := len(msg.data)
	var pkgLen int
	if dataLen < 128 {
		pkgLen = dataLen + 3
	} else {
		pkgLen = dataLen + 4
	}
	if _PACAKGE_LEN-pkgBuffer.sz < pkgLen {
		p.pkg_queue.PushBack(pkgBuffer)
		pkgBuffer = new_buffer()
	}

	headLen := fill_header(pkgBuffer.buffer[pkgBuffer.sz:], dataLen+_TYPE_DATA, msg.id)
	pkgBuffer.sz += headLen

	copy(pkgBuffer.buffer[pkgBuffer.sz:pkgBuffer.sz+dataLen], msg.data)
	pkgBuffer.sz += dataLen
}

func (p *Rudp) pack_request(pkgBuffer *stPackageBuffer, id int) {
	if _PACAKGE_LEN-pkgBuffer.sz < 3 {
		p.pkg_queue.PushBack(pkgBuffer)
		pkgBuffer = new_buffer()
	}

	pkgBuffer.sz += fill_header(pkgBuffer.buffer[pkgBuffer.sz:], _TYPE_REQUEST, id)
}

func (p *Rudp) pack_heartbeat(pkgBuffer *stPackageBuffer) {
	if pkgBuffer.sz == _PACAKGE_LEN {
		p.pkg_queue.PushBack(pkgBuffer)
		pkgBuffer = new_buffer()
	}
	pkgBuffer.buffer[pkgBuffer.sz] = byte(_TYPE_HEARTBEAT)
	pkgBuffer.sz++
}

func (p *Rudp) clear_expired() {
	var next *list.Element
	for e := p.history_queue.Front(); e != nil; e = next {
		next = e.Next()
		tmp := e.Value.(*stMessage)
		if tmp.tick+p.expired_interval < p.curr_tick {
			p.history_queue.Remove(e)
		} else {
			break
		}
	}
}

func (p *Rudp) request_missing(pkgBuffer *stPackageBuffer) {
	id := p.recv_id_min
	for e := p.recv_queue.Front(); e != nil; e = e.Next() {
		tmp := e.Value.(*stMessage)
		if tmp.id > id {
			for i := id; i < tmp.id; i++ {
				p.pack_request(pkgBuffer, i)
			}
		}
		id = tmp.id + 1
	}
}

func (p *Rudp) reply_request(pkgBuffer *stPackageBuffer) {
	for e := p.request_queue.Front(); e != nil; e = e.Next() {
		id := e.Value.(int)
		for ee := p.history_queue.Front(); ee != nil; ee = ee.Next() {
			tmp := ee.Value.(*stMessage)
			if id < tmp.id { // already expired

			} else if id == tmp.id {
				p.pack_message(tmp, pkgBuffer)
			}
		}
	}
	p.request_queue.Init()
}

func (p *Rudp) send_message(pkgBuffer *stPackageBuffer) {
	for e := p.send_queue.Front(); e != nil; e = e.Next() {
		p.pack_message(e.Value.(*stMessage), pkgBuffer)
	}

	p.history_queue.PushBackList(p.send_queue)
	p.send_queue.Init()
}

func (p *Rudp) gen_package() {
	pkgBuffer := new_buffer()

	p.request_missing(pkgBuffer)
	p.reply_request(pkgBuffer)
	p.send_message(pkgBuffer)

	if pkgBuffer.sz == 0 {
		p.pack_heartbeat(pkgBuffer)
	}
	p.pkg_queue.PushBack(pkgBuffer)
}

func (p *Rudp) Send(data []byte, sz int) {
	msg := new_message(data, sz)
	msg.id = p.send_id
	p.send_id++
	msg.tick = p.curr_tick

	p.send_queue.PushBack(msg)
}

func (p *Rudp) Recv() []byte {
	if p.recv_queue.Len() == 0 {
		return nil
	}

	e := p.recv_queue.Front()
	msg := e.Value.(*stMessage)
	if msg.id != p.recv_id_min {
		return nil
	}

	p.recv_id_min++
	p.recv_queue.Remove(e)

	return msg.data
}

func (p *Rudp) Unpack(data []byte, sz int) {
	for sz > 0 {
		length := int(data[0])
		if length < 128 {
			data = data[1:]
			sz -= 1
		} else {
			length = (length*256 + int(data[1])) & 0x7fff
			data = data[2:]
			sz -= 2
		}

		switch length {
		case _TYPE_HEARTBEAT:
		case _TYPE_REQUEST:
			p.insert_request(get_id(data))
			sz -= 2
			data = data[2:]
		default:
			length -= _TYPE_DATA
			if sz < length+2 {
				// error
				return
			} else {
				id := get_id(data)
				p.insert_message(data[2:], length, id)
				sz -= length + 2
				data = data[length+2:]
			}
		}
	}
}

func (p *Rudp) Update() *list.List {
	p.curr_tick++
	p.pkg_queue.Init()
	p.gen_package()

	l := list.New()
	for e := p.pkg_queue.Front(); e != nil; e = e.Next() {
		tmp := e.Value.(*stPackageBuffer)
		l.PushBack(tmp.buffer[:tmp.sz])
	}

	return l
}
