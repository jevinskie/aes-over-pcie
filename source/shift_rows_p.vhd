-- File name:   shift_rows_p.vhd
-- Created:     2009-04-26
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: parallel shift_rows

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_rows_p is
   
   port (
      d_in  : in state_type;
      d_out : out state_type
   );
   
end entity shift_rows_p;


architecture behavioral of shift_rows_p is
   type row_array is array (index) of row;
   signal in_rows, out_rows : row_array;
begin
   
   gen_shift_rows:
   for i in index generate
      shift_rows_b: entity work.shift_rows(dataflow) port map (
         data_in => in_rows(i), num_shifts => i, data_out => out_rows(i)
      );
   end generate gen_shift_rows;
   
   process(d_in, out_rows)
   begin
      for i in index loop
         for j in index loop
            in_rows(i)(j) <= d_in(i, j);
            d_out(i, j) <= out_rows(i)(j);
         end loop;
      end loop;
   end process;
   
end architecture behavioral;

