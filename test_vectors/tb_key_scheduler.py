#!/usr/bin/env python

import random
import aes


def gen_rand_key():
   return   [
               [random.randint(0, 255) for j in range(0, 4)]
               for i in range(0, 4)
            ]


def print_key_schedule(aes, key):
   print "%s " % aes.hex_to_str(key),
   for i in range(0, 11):
      round_key = e.keysched(key, i)
      print "%s " % aes.hex_to_str(round_key),
   print

e = aes.aes()

zeros = [[0 for j in range(0, 4)] for i in range(0, 4)]
print_key_schedule(e, zeros)

ones = [[0xFF for j in range(0, 4)] for i in range(0, 4)]
print_key_schedule(e, ones)

increasing = [[4*j+i for j in range(0, 4)] for i in range(0, 4)]
print_key_schedule(e, increasing)


total = 1024

for i in range(0, total):
   key = gen_rand_key()
   print_key_schedule(e, key)

