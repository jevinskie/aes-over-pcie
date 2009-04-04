-- File name:   aes_top.vhd
-- Created:     2009-04-04
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: AES top level

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aes_top is
   
   port (
      clk   : in std_logic;
      nrst  : in std_logic
   );
   
end entity aes_top;


architecture structural of aes_top is
   
   signal state_d, state_q    : state_type;
   signal subblock            : subblock_type;
   signal i                   : index;
   signal num_shifts          : index;
   signal filtered            : slice;
   signal sub_bytes_out       : byte;
   signal shift_rows_out      : row;
   signal mix_columns_out     : col;
   signal add_round_key_out   : byte;
   signal load_out            : byte;
   signal filtered_key        : byte;
   
begin
   
   
   state_b : entity work.state(dataflow) port map (
      clk => clk, state_d => state_d, state_q => state_q
   );
   
   state_filter_in_b : entity work.state_filter_in(behavioral) port map (
      s => state_d, subblock => subblock, i => i, d_out => filtered,
      filtered_key => filtered_key
   );
   
   state_filter_out_b : entity work.state_filter_out(mux) port map (
      current_state => state_d, sub_bytes_out => sub_bytes_out,
      shift_rows_out => shift_rows_out, mix_columns_out => mix_columns_out,
      add_round_key_out => add_round_key_out, load_out => load_out,
      subblock => subblock, i => i, next_state => state_q
   );
   
   sub_bytes_b : entity work.sbox(dataflow) port map (
      clk => clk, a => filtered(0), b => sub_bytes_out
   );
   
   shift_rows_b : entity work.shift_rows(dataflow) port map (
      data_in => filtered, num_shifts => num_shifts,
      data_out => shift_rows_out
   );
   
   mix_columns_b : entity work.mix_columns(behavioral) port map (
      d_in => filtered, d_out => mix_columns_out
   );
   
   add_round_key_b : entity work.add_round_key(dataflow) port map (
      data_in => filtered(0), key_in => filtered_key,
      data_out => add_round_key_out
   );
   
   
   
end architecture structural;

