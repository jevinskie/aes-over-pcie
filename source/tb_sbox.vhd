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
   generic (
      clk_per  : time := 5 ns
   );
end tb_sbox;

architecture test of tb_sbox is
   
   component sbox is
      port (
         clk   : in std_logic;
         a     : in byte;
         b     : out byte
      );
   end component sbox;
   
   signal clk  : std_logic := '0';
   signal a, b : byte;
   
   signal stop : std_logic := '1';
   signal gold : byte;
begin
   
   dut : sbox port map (
      clk => clk, a => a, b => b
   );
   
   -- clock when stop isnt asserted
   clk <= not clk and not stop after clk_per/2;
   
process
begin
   
   stop <= '0';
   
   for i in 0 to 256 loop
      if (i <= 255) then
         a <= to_unsigned(i, 8);
      end if;
      
      wait for clk_per;
      
      if (i >= 1) then
         gold <= work.aes.sbox(i-1);
         assert b = work.aes.sbox(i-1);
      end if;
   end loop;
   
   stop <= '1';
   
   wait;
end process;

end test;

