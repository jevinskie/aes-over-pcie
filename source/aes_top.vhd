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
      nrst  : in std_logic;
      enc_key : in key_type;
      pt    : in state_type;
      ct    : out state_type
   );
   
end entity aes_top;


architecture structural of aes_top is
   
   signal state_d, state_q    : state_type;
   signal subblock            : subblock_type;
   signal i                   : g_index;
   signal num_shifts          : index;
   signal filtered            : slice;
   signal round_num           : round_type;
	signal round_key				: key_type;
   signal sub_bytes_out       : byte;
   signal shift_rows_out      : row;
   signal mix_columns_out     : col;
   signal add_round_key_out   : byte;
   signal load_out            : byte;
   signal filtered_key        : byte;
   signal start_key           : std_logic;
   signal key_done            : std_logic;
   signal sbox_lookup         : byte;
   
begin
   
   
   state_b : entity work.state(dataflow) port map (
      clk => clk, state_d => state_d, state_q => state_q
   );
   
   state_filter_in_b : entity work.state_filter_in(behavioral) port map (
      s => state_q, subblock => subblock, i => i, d_out => filtered,
      filtered_key => filtered_key, round_key => round_key
   );
   
   state_filter_out_b : entity work.state_filter_out(mux) port map (
      current_state => state_q, sub_bytes_out => sub_bytes_out,
      shift_rows_out => shift_rows_out, mix_columns_out => mix_columns_out,
      add_round_key_out => add_round_key_out, load_out => load_out,
      subblock => subblock, i => i, next_state => state_d
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
   
   aes_rcu_b : entity work.aes_rcu(Behavioral) port map (
      clk => clk, nrst => nrst, p => i, subblock => subblock,
      current_round => round_num, start_key => start_key,
      key_done => key_done
   );
   
   key_scheduler_b : entity work.key_scheduler(behavioral) port map (
      clk => clk, nrst => nrst, sbox_lookup => sbox_lookup,
      sbox_return => sub_bytes_out, round => round_num,
      encryption_key => enc_key, round_key => round_key,
      go => start_key, done => key_done
   );
   
   ct <= state_d;
   
end architecture structural;

