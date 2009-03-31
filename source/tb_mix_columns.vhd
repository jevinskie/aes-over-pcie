-- File name:   tb_mix_columns.vhd
-- Created:     2009-03-30
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;

entity tb_mix_columns is
   
   generic (
      clk_per  : time := 4 ns
   );
   
end entity tb_mix_columns;

architecture test of tb_mix_columns is
   
   signal d_in    : col;
   signal d_out   : col;
   
   type test_sample is record
      input : col;
      gold  : col;
   end record test_sample;
      
   type sample_array is array (natural range <>) of test_sample;
   constant test_samples : sample_array :=
   (
      ((x"db", x"13", x"53", x"45"),
       (x"8e", x"4d", x"a1", x"bc")),
      
      ((x"f2", x"0a", x"22", x"5c"),
       (x"9f", x"dc", x"58", x"9d")),
      
      ((x"01", x"01", x"01", x"01"),
       (x"01", x"01", x"01", x"01")),
      
      ((x"c6", x"c6", x"c6", x"c6"),
       (x"c6", x"c6", x"c6", x"c6")),
      
      ((x"d4", x"d4", x"d4", x"d5"),
       (x"d5", x"d5", x"d7", x"d6")),
      
      ((x"2d", x"26", x"31", x"4c"),
       (x"4d", x"7e", x"bd", x"f8"))
   );
   
begin
   
   dut : entity work.mix_columns(behavioral)
      port map (
         d_in => d_in, d_out => d_out
      );
   
process
begin
   
   for i in test_samples'range loop
      d_in <= test_samples(i).input;
      wait for clk_per;
      assert d_out = test_samples(i).gold
         report "dout = test_samples(i).gold check";
   end loop;
   
   wait;

end process;

end architecture test;

