-- File name:   tb_key_scheduler.vhd
-- Created:     2009-04-06
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     2.0 Revamped Test Bench with external test vectors!


use work.aes.all;
use work.aes_textio.all;
use work.numeric_std_textio.all;

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_key_scheduler is
   
   generic (
      clk_per  : time := 4 ns
   );
   
end entity tb_key_scheduler;


architecture test of tb_key_scheduler is
   
   
   signal clk              : std_logic := '0';
   signal nrst             : std_logic := '1';
   signal round            : round_type;
   signal key_data         : byte;
   signal key_load         : std_logic;
   signal key_index        : g_index;
   signal round_key        : key_type;
   signal go               : std_logic := '0';
   signal done             : std_logic;
   -- clock only runs when stop isnt asserted
   signal stop             : std_logic := '1';
   
   
begin
   
   
   dut : entity work.key_scheduler(behavioral) port map (
      clk => clk, nrst => nrst, round => round,
      round_key => round_key, key_data => key_data,
      key_load => key_load, key_index => key_index,
      go => go, done => done
   );
   
   clk <= not clk and not stop after clk_per/2;
   
process
   
   
   file data : text open read_mode is "test_vectors/tb_key_scheduler.dat";
   variable sample               : line;
   variable gold_encryption_key  : key_type;
   variable gold_round_key       : key_type;
   
   
begin
   
   stop <= '0';
   nrst <= '0';
   wait for clk_per;
   nrst <= '1';
   wait for clk_per;
   
   -- leda DCVHDL_165 off
   while not endfile(data) loop
      readline(data, sample);
      hread(sample, gold_encryption_key);
      key_load <= '1';
      for i in g_index loop
         key_data <= gold_encryption_key(i mod 4, i / 4);
         key_index <= i;
         wait for clk_per;
      end loop;
      key_load <= '0';
      wait for clk_per;
      for i in 0 to 10 loop
         go <= '1';
         round <= i;
         wait for clk_per;
         go <= '0';
         wait until done = '1';
         wait for 2*clk_per;
         hread(sample, gold_round_key);
         assert gold_round_key = round_key;
      end loop;
   end loop;
   -- leda DCVHDL_165 on
   
   stop <= '1';
   
   wait;
   
end process;

end architecture test;

