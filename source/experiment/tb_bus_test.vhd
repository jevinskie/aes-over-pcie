-- File name:   tb_bus_test.vhd
-- Created:     2009-02-26
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: bus_test tester

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_bus_test is
   generic (
      clk_per  : time := 5 ns
   );
end tb_bus_test;

architecture test of tb_bus_test is
   
   component bus_test is
      port (
         clk   : in std_logic;
         nrst  : in std_logic;
         b     : out unsigned(7 downto 0)
      );
   end component bus_test;
   
   signal clk  : std_logic := '0';
   signal nrst : std_logic := '1';
   signal stop : std_logic := '1';
   signal b    : unsigned(7 downto 0);
   
begin
   
   dut : bus_test port map (
      clk => clk, nrst => nrst, b => b
   );
   
   -- clock when stop isnt asserted
   clk <= not clk and not stop after clk_per/2;
   
process
begin
   
   nrst <= '0';
   wait for clk_per*2;
   nrst <= '1';
   
   stop <= '0';
   
   wait for clk_per*32;
   
   stop <= '1';
   
   wait for clk_per*4;
   
   wait;
end process;

end test;

