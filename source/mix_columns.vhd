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
   
begin
   process(d_in)      
     variable b : col;   --temp calculation variable
      begin
      --multiply by 2 is done with a left shift   
      --need Galois field correction for b here; i.e. b(i) must be 8-bits still
      --Algo: check if upper nibble of d_in(1) = 0x80, if so b(i) = b(i) XOR 0x1b
      for i in 0 to 3 loop
         b(i) := d_in(i) sll 1;
         if std_match(d_in(i), "1-------") then
            b(i) := (b(i) xor x"1b");
         end if;
      end loop;
      
      --when multiply by 3 is needed, we can break that into x*(2x)
      d_out(0) <= b(0) xor d_in(3) xor d_in(2) xor b(1) xor d_in(1);
      d_out(1) <= b(1) xor d_in(0) xor d_in(3) xor b(2) xor d_in(2);
      d_out(2) <= b(2) xor d_in(1) xor d_in(0) xor b(3) xor d_in(3); 
      d_out(3) <= b(3) xor d_in(2) xor d_in(1) xor b(0) xor d_in(0);
   end process;
end architecture dataflow;

