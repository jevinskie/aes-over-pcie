-- File name:   tb_shift_rows.vhd
-- Created:     2009-03-30
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench
-- Modified: 2009-4-18, added python integration

use work.aes.all;
use work.aes_textio.all;
use work.numeric_std_textio.all;

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_shift_rows is
   
   generic (
      clk_per  : time := 4 ns
   );
   
end entity tb_shift_rows;

architecture test of tb_shift_rows is
   
   signal data_in    : row;
   signal data_out   : row;
   signal num_shifts : index;
      
begin
   
   dut : entity work.shift_rows(dataflow)
      port map (
         data_in => data_in, data_out => data_out, num_shifts => num_shifts
      );
   
process
    
    file data : text open read_mode is "test_vectors/tb_shift_rows.dat";
    variable sample : line;
    variable data_input : state_type;
    variable gold_data_output : state_type;
    variable temp, gold_temp : slice;
    
begin
   
   while not endfile(data) loop
      readline(data, sample);
      hread(sample, data_input);
      hread(sample, gold_data_output);
      for j in 0 to 3 loop
         for i in 0 to 3 loop
           temp(i) := data_input(j,i);
           gold_temp(i) := gold_data_output(j,i);
         end loop;
         data_in <= temp;
         num_shifts <= j;
         wait for clk_per*2;
         assert gold_temp = data_out;
      end loop;
   end loop;
   
   wait;

end process;

end architecture test;

