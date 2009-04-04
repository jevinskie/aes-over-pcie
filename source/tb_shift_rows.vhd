-- File name:   tb_shift_rows.vhd
-- Created:     2009-03-30
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;

entity tb_shift_rows is
   
   generic (
      clk_per  : time := 4 ns
   );
   
end entity tb_shift_rows;

architecture test of tb_shift_rows is
   
   signal data_in    : row;
   signal num_shifts : index;
   signal data_out   : row;
   
   
   type test_sample is record
      r     : row;
      num   : index;
      gold  : row;
   end record test_sample;
   
   
   type sample_array is array (natural range <>) of test_sample;
   constant test_samples : sample_array :=
   (
      ((x"db", x"13", x"53", x"45"), 0,
       (x"db", x"13", x"53", x"45")),
      
      ((x"f2", x"0a", x"22", x"5c"), 1,
       (x"0a", x"22", x"5c", x"f2")),
      
      ((x"a3", x"01", x"b3", x"09"), 2,
       (x"b3", x"09", x"a3", x"01")),
      
      ((x"c7", x"d6", x"c6", x"a6"), 3,
       (x"a6", x"c7", x"d6", x"c6")),
      
      ((x"d4", x"d3", x"d4", x"d5"), 1,
       (x"d3", x"d4", x"d5", x"d4")),
      
      ((x"2d", x"26", x"31", x"4c"), 2,
       (x"31", x"4c", x"2d", x"26"))
   );
   
   
begin
   
   dut : entity work.shift_rows(dataflow)
      port map (
         data_in => data_in,
         num_shifts => num_shifts,
         data_out => data_out
      );
   
process
begin
   
   for i in test_samples'range loop
      data_in <= test_samples(i).r;
      num_shifts <= test_samples(i).num;
      wait for clk_per;
      assert data_out = test_samples(i).gold
         report "data_out = test_samples(i).gold check";
   end loop;
   
   wait;
   
end process;

end architecture test;

