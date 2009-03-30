-- File name:   mix_columns.vhd
-- Created:     2009-03-29
-- Author:      Matt Swanson
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: Rijndael MixColumns

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mix_columns is
   
   port(
      clk   : in std_logic;
      d_in  : in slice;
      d_out : out slice
   );
   
end mix_columns;

architecture dataflow of mix_columns is
   
   -- Rijndael mix columns matrix
   -- [ r0 ]      [ 2   3   1   1 ] [ a0 ]
   -- [ r1 ]  =   [ 1   2   3   1 ] [ a1 ]
   -- [ r2 ]      [ 1   1   2   3 ] [ a2 ]
   -- [ r3 ]      [ 3   1   1   2 ] [ a3 ]
   --
   -- Note: addition -> XOR
   -- r0 = 2a0 + a3 + a2 + 3a1
   -- r1 = 2a1 + a0 + a3 + 3a2
   -- r2 = 2a2 + a1 + a0 + 3a3
   -- r3 = 2a3 + a2 + a1 + 3a0
   
   signal b : slice;

begin
   
   b(0) <= d_in(0) sll 1;
   b(1) <= d_in(1) sll 1;
   b(2) <= d_in(2) sll 1;
   b(3) <= d_in(3) sll 1;
   
   d_out(0) <= b(0) xor d_in(3) xor d_in(2) xor b(1) xor d_in(1); --8e
   d_out(1) <= b(1) xor d_in(0) xor d_in(3) xor b(2) xor d_in(2); --4d
   d_out(2) <= b(2) xor d_in(1) xor d_in(0) xor b(3) xor d_in(3); --a1 
   d_out(3) <= b(3) xor d_in(2) xor d_in(1) xor b(0) xor d_in(0); --bc
   
end architecture dataflow;

