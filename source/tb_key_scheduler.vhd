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
   
   signal d1, d2 : byte;
   signal k1, k2 : key;
   
begin
   
   
process
   file data : text open read_mode is "test_vectors/tb_key_scheduler.dat";
   variable sample : line;
   variable b1, b2 : byte;
   variable key1, key2 : key;
begin
   
   while not endfile(data) loop
      readline(data, sample);
      hread(sample, b1);
      hread(sample, b2);
      hread(sample, key1);
      hread(sample, key2);
      d1 <= b1;
      d2 <= b2;
      k1 <= key1;
      k2 <= key2;
      wait for 1 ns;
      assert (d1 = d2)
         report "wtf";
      wait for clk_per;
   end loop;
   
   wait;
   
end process;

end architecture test;

