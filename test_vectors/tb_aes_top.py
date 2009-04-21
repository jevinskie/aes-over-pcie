#!/usr/bin/env python

import random
import aes


def gen_rand():
   return   [
               [random.randint(0, 255) for j in range(0, 4)]
               for i in range(0, 4)
            ]


e = aes.aes()

total = 10

#key = [[0 for i in range(0, 4)] for j in range(0, 4)];

#pt_str = "3243f6a8885a308d313198a2e0370734"
#key_str = "2b7e151628aed2a6abf7158809cf4f3c"

#key = e.str_to_hex(key_str)
#pt = e.str_to_hex(pt_str)

#print e.hex_to_str(key),
#print e.hex_to_str(pt),
#print e.hex_to_str(e.encblock(pt, key))

for i in range(0, total):
   key = gen_rand()
   pt = gen_rand()
   print e.hex_to_str(key),
   print e.hex_to_str(pt),
   print e.hex_to_str(e.encblock(pt, key))

