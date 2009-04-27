-- File name:   add_round_key_p.vhd
-- Created:     2009-04-26
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: parallel add round key stage

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_round_key_p is
   
   port (
      data_in  : in state_type;
      key_in   : in state_type;
      data_out : out state_type
   );
   
end entity add_round_key_p;


architecture dataflow of add_round_key_p is
   
begin
   
   process(data_in, key_in)
   begin
      for i in index loop
         for j in index loop
            data_out(i, j) <= data_in(i, j) xor key_in(i, j);
         end loop;
      end loop;
   end process;
   
end architecture dataflow;

