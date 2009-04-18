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


for i in range(0, total):
   key = gen_rand()
   pt = gen_rand()
   print e.hex_to_str(key),
   print e.hex_to_str(pt),
   print e.hex_to_str(e.encblock(key, pt))

