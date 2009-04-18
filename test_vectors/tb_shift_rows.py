#!/usr/bin/env python

import random
import aes


def gen_rand_block():
   return   [
               [random.randint(0, 255) for j in range(0, 4)]
               for i in range(0, 4)
            ]
               


def print_block(aes, block):
   print "%s " % aes.hex_to_str(block),
   x = e.shiftrows(block)
   print "%s " % aes.hex_to_str(x),
   print

e = aes.aes()

zeros = [[0 for j in range(0, 4)] for i in range(0, 4)]
print_block(e, zeros)

ones = [[0xFF for j in range(0, 4)] for i in range(0, 4)]
print_block(e, ones)

increasing = [[4*j+i for j in range(0, 4)] for i in range(0, 4)]
print_block(e, increasing)


total = 1024

for i in range(0, total):
   key = gen_rand_block()
   print_block(e, key)
