-- File name:   state_filter_in.vhd
-- Created:     2009-03-30
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: Rijndael state filter for subblock inputs

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_filter_in is
   
   port (
      clk      : in std_logic;
      nrst     : in std_logic;
      s        : in state;
      subblock : in subblock_type;
      i        : in g_index;
      d_out    : out slice
   );
   
end entity state_filter_in;


architecture dataflow of state_filter_in is
   
begin
   
   process(i, subblock, s)
   begin
      case subblock is
         when sub_bytes =>
            d_out(0) <= s(i / 4, i mod 4);
            for j in 1 to 3 loop
               d_out(j) <= (others => '-');
            end loop;
         when shift_rows =>
            for j in 0 to 3 loop
               d_out(j) <= s(j, i);
            end loop;
         when mix_columns =>
            for j in 0 to 3 loop
               d_out(j) <= s(i, j);
            end loop;
         when add_key =>
            d_out(0) <= s(i / 4, i mod 4);
            for j in 1 to 3 loop
               d_out(j) <= (others => '-');
            end loop;
         when others =>
            for j in 0 to 3 loop
               d_out(j) <= (others => '-');
            end loop;
      end case;
   end process;
   
end architecture dataflow;

