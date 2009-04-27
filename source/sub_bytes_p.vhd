-- File name:   sub_bytes_p.vhd
-- Created:     2009-04-26
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: parallel sub_bytes

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sub_bytes_p is
   
   port (
      d_in  : in state_type;
      d_out : out state_type
   );
   
end entity sub_bytes_p;


architecture structural of sub_bytes_p is
   
begin
   
   gen_sbox : for i in g_index generate
      sub_bytes_b : entity work.sbox(dataflow) port map (
         clk => '0', a => d_in(i mod 4, i / 4), b => d_out(i mod 4, i / 4)
      );
   end generate gen_sbox;
   
end architecture structural;

