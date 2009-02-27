-- File name:   tb_sbox.vhd
-- Created:     2009-02-26
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: S-Box tester

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sbox is
end tb_sbox;

architecture test of tb_sbox is
   
   component sbox is
      port (
         a : in byte;
         b : out byte
      );
   end component sbox;
   
   signal a, b : byte;
   
begin
   
   sbox_b : sbox port map (
      a => a, b => b
   );
   
process
begin
   
   for i in 0 to 255 loop
      a <= to_unsigned(i, 8);
      wait for 15 ns;
      assert b = work.aes.sbox(i);
   end loop;
   
   wait;
end process;

end test;

