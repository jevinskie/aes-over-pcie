-- File name:   shift_rows.vhd
-- Created:     2009-03-30
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: a transposition step where each row of the state is
-- shifted cyclically a certain number of steps

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_rows is
   
   port (
      data_in     : in row;
      num_shifts  : in index;
      data_out    : out row
   );
   
end entity shift_rows;


architecture dataflow of shift_rows is
   
   -- shift rows algorithm
   -- row 1: no shift: [a00, a01, a02, a03] --> [a00, a01, a02, a03]
   -- row 2: shift 1 : [a10, a11, a12, a13] --> [a11, a12, a13, a10]
   -- row 3: shift 2 : [a20, a21, a22, a23] --> [a22, a23, a20, a21]
   -- row 4: shift 3 : [a30, a31, a32, a33] --> [a33, a30, a31, a32]
   
begin
   
   process(data_in, num_shifts)
   begin
      for k in index loop
         data_out(k) <= data_in((num_shifts + k) mod 4);
      end loop;
   end process;
   
end architecture dataflow;

