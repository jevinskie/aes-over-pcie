#!/usr/bin/env python

import random
import aes


def gen_rand_slice():
   return [random.randint(0, 255) for j in range(0, 4)]
               


def print_slice(aes, slice):
   print "%s " % aes.hex_slice_to_str(slice),
   x = e.mixmul(slice)
   print "%s " % aes.hex_slice_to_str(x),
   print

e = aes.aes()

zeros = [0 for j in range(0, 4)]
print_slice(e, zeros)

ones = [0x01 for j in range(0, 4)]
print_slice(e, ones)

increasing = [0xdb, 0x13, 0x53, 0x45]
print_slice(e, increasing)


total = 1024

for i in range(0, total):
   key = gen_rand_slice()
   print_slice(e, key)

