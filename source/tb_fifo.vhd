-- File name:   tb_fifo.vhd
-- Created:     2009-04-20 (^-^)y-~~'`
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: FIFO test bench

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fifo is
   
   generic (
      clk_per  : time := 4 ns;
      size     : positive := 32
   );
   
end tb_fifo;

architecture test of tb_fifo is
   
   -- dut and gold model signals
   signal clk     : std_logic := '0';
   signal nrst    : std_logic := '1';
   signal re      : std_logic := '0';
   signal we      : std_logic := '0';
   signal w_data  : byte;
   signal r_data  : byte;
   signal empty   : std_logic;
   signal full    : std_logic;
   
   -- clock only runs when stop isnt asserted
   signal stop          : std_logic := '1';
   
   procedure store (
      constant d        : in byte;
      signal w_enable   : out std_logic;
      signal w_data     : out byte
   ) is
   begin
      w_data <= d;
      w_enable <= '1';
      wait for clk_per;
      w_enable <= '0';
   end procedure store;
   
   procedure get (
      variable d        : out byte;
      signal r_enable   : out std_logic;
      signal r_data     : in byte
   ) is
   begin
      d := r_data;
      r_enable <= '1';
      wait for clk_per;
      r_enable <= '0';
   end procedure get;
   
begin
   
   dut : entity work.fifo(behavioral)
      --generic map (
         --size => size
      --)
      port map (
         clk      => clk,
         nrst     => nrst,
         re       => re,
         we       => we,
         w_data   => w_data,
         r_data   => r_data,
         empty    => empty,
         full     => full
      );
   
-- main test bench code
   
   -- clock when stop isnt asserted
   clk <= not clk and not stop after clk_per/2;
   
process
   variable d : byte;
begin
   wait for clk_per*5;
   
   -- start the clock
   stop <= '0';

   -- reset the device
   nrst <= '0';
   wait for clk_per;
   nrst <= '1';
   
   assert empty = '1';
   assert full = '0';
   
   -- fill the buffer up
   for i in 0 to size-2 loop
      store(to_unsigned(i, 8), we, w_data);
      wait for clk_per*5;
      assert empty = '0';
   end loop;
   
   -- we better be full now
   assert full = '1';
   
   -- get all that shiz out
   for i in 0 to size-2 loop
      get(d, re, r_data);
      wait for clk_per*5;
      assert full = '0';
      -- make sure we get back what we put in
      assert d = to_unsigned(i, 8);
   end loop;
   
   -- we better be empty now
   assert empty = '1';
   
   -- overflow the fifo for fun...
   for i in 0 to size*2-2 loop
      store(to_unsigned(i, 8), we, w_data);
      wait for clk_per*5;
      assert empty = '0';
      if i > size-2 then
         assert full = '1';
      end if;
   end loop;
   
   -- ... and see what comes out
   for i in 0 to size*2-2 loop
      get(d, re, r_data);
      wait for clk_per*5;
      assert full = '0';
      if i > size*2-2 then
         assert empty = '1';
      end if;
   end loop;
   
   wait for clk_per*5;
   
   -- stop the clock
   stop <= '1';
   
   wait for clk_per*5;
   
   wait;
end process;
end test;

