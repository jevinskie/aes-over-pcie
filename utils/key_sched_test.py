#!/usr/bin/env python

import sys
import os
import aes

def readkey(str):
   nums = map(lambda i : int(i, 16), str.split())

   key = [[None for j in range(0, 4)] for i in range(0, 4)]
   
   for i in range(0, 4):
      for j in range(0, 4):
         key[j][i] = nums[4*i + j]
   
   return key


def key_to_str(key):
   str = ""
   for i in range(0, 4):
      for j in range(0, 4):
         str += "%02x " % key[j][i]
   return str

e = aes.aes()

overall_ok = True

# iterate over all the key test vectors
for filename in os.listdir(os.path.join(sys.path[0], 'key_vectors')):
   f = open(os.path.join(sys.path[0], 'key_vectors', filename), 'r')
   
   # read in the encryption key
   key = readkey(f.readline())
   
   # rewind the file
   f.seek(0)
   
   ok = True

   for i in range(0, 11):
      gold_key = readkey(f.readline())
      if (e.keysched(key, i) != gold_key):
         print "ERROR in key schedule %s, round key #%i" % (filename, i)
         print "Expected: %s" % key_to_str(gold_key)
         print "Got: %s" % key_to_str(e.keysched(key, i))
         ok = False
   
   f.close()
   
   if ok:
      print "%16s => GOOD" % filename
   else:
      print "%16s => BAD" % filename
      overall_ok = False

if overall_ok:
   print "All tests PASSED!"
   sys.exit(0)
else:
   print "At least one test FAILED!"
   sys.exit(-1)


