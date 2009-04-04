#!/usr/bin/python

iso      = ((1,0,1,0,0,0,0,0),
            (1,1,0,1,1,1,1,0),
            (1,0,1,0,1,1,0,0),
            (1,0,1,0,1,1,1,0),
            (1,1,0,0,0,1,1,0),
            (1,0,0,1,1,1,1,0),
            (0,1,0,1,0,0,1,0),
            (0,1,0,0,0,0,1,1));

iso_inv  = ((1,1,1,0,0,0,1,0),
            (0,1,0,0,0,1,0,0),
            (0,1,1,0,0,0,1,0),
            (0,1,1,1,0,1,1,0),
            (0,0,1,1,1,1,1,0),
            (1,0,0,1,1,1,1,0),
            (0,0,1,1,0,0,0,0),
            (0,1,1,1,0,1,0,1));

affine_a = ((1,1,1,1,1,0,0,0),
            (0,1,1,1,1,1,0,0),
            (0,0,1,1,1,1,1,0),
            (0,0,0,1,1,1,1,1),
            (1,0,0,0,1,1,1,1),
            (1,1,0,0,0,1,1,1),
            (1,1,1,0,0,0,1,1),
            (1,1,1,1,0,0,0,1));

affine_b =  ((0,),(1,),(1,),(0,),(0,),(0,),(1,),(1,));

def binary_matrix_mul(a, b):
   m = len(a)
   n = len(a[0])
   p = len(b[0])
   
   x = []

   assert n == len(b)
   for i in range(0, m):
      assert len(a[i]) == n
   for i in range(0, len(b)):
      assert len(b[0]) == len(b[i])

   for i in range(0, m):
      r = []
      for j in range(0, p):
         s = 0
         for k in range(0, m):
            s ^= a[i][k] & b[k][j]
         r.append(s)
      x.append(r)
   
   return x

def trans(a):
   m = len(a)
   n = len(a[0])
   
   b = []
   
   for i in range(0, n):
      r = []
      for j in range(0, m):
         r.append(a[j][i])
      b.append(r)
   
   return b

def binary_matrix_add(a, b):
   m = len(a)
   n = len(a[0])
   
   x = []
   
   assert m == len(b)
   for i in range(0, m):
      assert n == len(a[i])
      assert n == len(b[i])
   
   for i in range(0, m):
      r = []
      for j in range(0, n):
         r.append(a[i][j] ^ b[i][j])
      x.append(r)
   
   return x


