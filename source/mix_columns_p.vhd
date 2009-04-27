-- File name:   mix_columns_p.vhd
-- Created:     2009-04-26
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: parallel mix_columns

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mix_columns_p is
   
   port (
      d_in  : in state_type;
      d_out : out state_type
   );
   
end entity mix_columns_p;


architecture behavioral of mix_columns_p is
   type col_array is array (index) of col;
   signal in_cols, out_cols : col_array;
begin
   
   gen_mix_columns:
   for i in index generate
      mix_columns_b: entity work.mix_columns(behavioral) port map (
         d_in => in_cols(i), d_out => out_cols(i)
      );
   end generate gen_mix_columns;
   
   process(d_in, out_cols)
   begin
      for i in index loop
         for j in index loop
            in_cols(i)(j) <= d_in(j, i);
            d_out(j, i) <= out_cols(i)(j);
         end loop;
      end loop;
   end process;
   
end architecture behavioral;
