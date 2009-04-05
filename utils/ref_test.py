#!/usr/bin/env python
import rijndael as aes

def hex2bin(s):
   assert len(s) % 2 == 0
   r = ""
   for i in range(0, len(s) // 2):
      r = ''.join([r, chr(int(s[i*2:i*2+2],16))])
   
   return r

def bin2hex(b):
   r = ""
   for i in range(0, len(b)):
      r = ''.join([r, '%02x' % ord(b[i])])
   
   return r

def shuffle(b):
   lut = (0xf, 7, 0xb, 5, 0xa, 0xd, 6, 3, 9, 4, 2, 1, 0, 8, 0xc, 0xe)
   s = [0,1,2,3,4,5,6,7,9,9,10,11,12,13,14,15]
   for i in range(0, 16):
      s[lut[i]] = b[i]
   
   return ''.join(s)

k = hex2bin("00010203050607080A0B0C0D0F101112")

r = aes.rijndael(k, block_size = 16)

p = hex2bin("506812A45F08C889B97F5980038B8359")

c1 = r.encrypt(p)
shuffled = shuffle(p)
print bin2hex(p)
print bin2hex(shuffled)
c2 = r.encrypt(shuffled)
print bin2hex(c1)
print bin2hex(c2)
print bin2hex(shuffle(c2))
