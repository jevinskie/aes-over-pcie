-- File name:   tb_mix_columns.vhd
-- Created:     2009-03-30
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench
-- Modified:    2009-04-16, Matt Swanson, added python integration

use work.aes.all;
use work.aes_textio.all;
use work.numeric_std_textio.all;

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_mix_columns is
   
   generic (
      clk_per  : time := 4 ns
   );
   
end entity tb_mix_columns;

architecture test of tb_mix_columns is
   
   signal d_in    : col;
   signal d_out   : col;
      
begin
   
   dut : entity work.mix_columns(behavioral)
      port map (
         d_in => d_in, d_out => d_out
      );
   
process
    
    file data : text open read_mode is "test_vectors/tb_mix_columns.dat";
    variable sample : line;
    variable data_input : col;
    variable gold_data_output : col;
begin
   
   while not endfile(data) loop
      readline(data, sample);
      hread(sample, data_input);
      d_in <= data_input;
      wait for clk_per*2;
      hread(sample, gold_data_output);
      assert gold_data_output = d_out;
   end loop;
   
   wait;

end process;

end architecture test;


