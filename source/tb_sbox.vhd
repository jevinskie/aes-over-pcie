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
   
   --component sbox is
   --   port (
   --      clk   : in std_logic;
   --      a     : in byte;
   --      b     : out byte
   --   );
   --end component sbox;
   
   signal clk              : std_logic := '0';
   signal lut_a, lut_b     : byte;
   signal data_a, data_b   : byte;
   signal pipe_a, pipe_b   : byte;
   
   signal stop : std_logic := '1';
   signal gold : byte;
   
begin
   
   lut : entity work.sbox(lut) port map (
      clk => clk, a => lut_a, b => lut_b
   );
   
   data : entity work.sbox(dataflow) port map (
      clk => clk, a => data_a, b => data_b
   );
   
   pipe : entity work.sbox(pipelined) port map (
      clk => clk, a => pipe_a, b => pipe_b
   );
   
   -- clock when stop isnt asserted
   clk <= not clk and not stop after clk_per/2;
   
process
begin
   
   for i in 0 to 255 loop
      lut_a  <= to_unsigned(i, 8);
      data_a <= to_unsigned(i, 8);
      
      wait for 10 ns;
      
      gold         <= work.aes.sbox(i);
      assert lut_b  = work.aes.sbox(i);
      assert data_b = work.aes.sbox(i);
   end loop;
   
   stop <= '0';
   
   for i in 0 to 256 loop
      if (i <= 255) then
         pipe_a <= to_unsigned(i, 8);
      end if;
      
      wait for clk_per;
      
      if (i >= 1) then
         gold         <= work.aes.sbox(i-1);
         assert pipe_b = work.aes.sbox(i-1);
      end if;
   end loop;
   
   stop <= '1';
   
   wait;
end process;

end test;

