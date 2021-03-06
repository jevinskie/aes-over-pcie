#!/usr/bin/env python

import sys
import random
import aes
import rijndael


def gen_rand():
   return [[random.randint(0, 255) for j in range(0, 4)] for i in range(0, 4)]





e = aes.aes()

total = 1024
passed = 0

for i in range(total):
   key = gen_rand()
   pt = gen_rand()
   r = rijndael.rijndael(e.hex_to_packed(key), block_size = 16)
   ct = e.encblock(pt, key)
   gold_ct = e.packed_to_hex(r.encrypt(e.hex_to_packed(pt)))
   
   if gold_ct != ct:
      print "ERROR in test vector #%i!" % i
      print "Key:        %s" % e.hex_to_str(key)
      print "Plaintext:  %s" % e.hex_to_str(pt)
      print "Ciphertext: %s" % e.hex_to_str(gold_ct)
      print "Calculated: %s" % e.hex_to_str(ct)
   else:
      passed += 1

print "Passed %i / %i tests (%02.1f%%)" % (passed, total, 100.0*float(passed)/total)

if passed != total:
   print "ERROR! Some tests failed!"
   sys.exit(-1)
else:
   print "PASSED! All tests passed!"
   sys.exit(0)

# iterate over all the test vectors

