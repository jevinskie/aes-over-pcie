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
      clk      : in std_logic;
      nrst     : in std_logic;
      rx_data  : in byte;
      got_key  : in std_logic;
      got_pt   : in std_logic;
      send_ct  : in std_logic;
      aes_done : out std_logic;
      tx_data  : out byte
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
   signal filtered_key        : byte;
   signal start_key           : std_logic;
   signal key_done            : std_logic;
   signal ks_sbox_lookup      : byte;
   signal key_load            : std_logic;
   signal ks_sbox_return      : byte;
   
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
      add_round_key_out => add_round_key_out, load_out => rx_data,
      subblock => subblock, i => i, next_state => state_d
	);
   
   sub_bytes_b : entity work.sbox(dataflow) port map (
      clk => clk, a => filtered(0), b => sub_bytes_out
   );
   
   num_shifts <= i mod 4;
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
   
   aes_rcu_b : entity work.aes_rcu(behavioral) port map (
      clk => clk, nrst => nrst, p => i, subblock => subblock,
      current_round => round_num, start_key => start_key,
      key_done => key_done, key_load => key_load,
      got_key => got_key, got_pt => got_pt, aes_done => aes_done,
      send_ct => send_ct
   );
   
   key_scheduler_b : entity work.key_scheduler(behavioral) port map (
      clk => clk, nrst => nrst, round => round_num,
      round_key => round_key, go => start_key, done => key_done,
      key_data => rx_data, key_index => i, key_load => key_load
   );
   
   tx_data <= filtered(0);
   
end architecture structural;

architecture structural_p of aes_top is
   
   signal state_d, state_q    : state_type;
   signal subblock            : subblock_type;
   signal i                   : g_index;
   signal round_num           : round_type;
	signal round_key				: key_type;
   signal sub_bytes_out       : state_type;
   signal shift_rows_out      : state_type;
   signal mix_columns_out     : state_type;
   signal add_round_key_out   : state_type;
   signal start_key           : std_logic;
   signal key_done            : std_logic;
   signal ks_sbox_lookup      : byte;
   signal key_load            : std_logic;
   signal ks_sbox_return      : byte;
   
begin
   
   
   state_b : entity work.state(dataflow) port map (
      clk => clk, state_d => state_d, state_q => state_q
   );
   
   state_filter_out_p_b : entity work.state_filter_out_p(mux) port map (
      current_state => state_q, sub_bytes_out => sub_bytes_out,
      shift_rows_out => shift_rows_out, mix_columns_out => mix_columns_out,
      add_round_key_out => add_round_key_out, load_out => rx_data,
      subblock => subblock, i => i, next_state => state_d
	);
   
   sub_bytes_p_b : entity work.sub_bytes_p(structural) port map (
      d_in => state_q, d_out => sub_bytes_out
   );
   
   shift_rows_p_b : entity work.shift_rows_p(behavioral) port map (
      d_in => state_q, d_out => shift_rows_out
   );
   
   mix_columns_p_b : entity work.mix_columns_p(behavioral) port map (
      d_in => state_q, d_out => mix_columns_out
   );
   
   add_round_key_p_b : entity work.add_round_key_p(dataflow) port map (
      data_in => state_q, key_in => round_key,
      data_out => add_round_key_out
   );
   
   aes_rcu_b : entity work.aes_rcu(behavioral_p) port map (
      clk => clk, nrst => nrst, p => i, subblock => subblock,
      current_round => round_num, start_key => start_key,
      key_done => key_done, key_load => key_load,
      got_key => got_key, got_pt => got_pt, aes_done => aes_done,
      send_ct => send_ct
   );
   
   key_scheduler_p_b : entity work.key_scheduler(behavioral_p) port map (
      clk => clk, nrst => nrst, round => round_num,
      round_key => round_key, go => start_key, done => key_done,
      key_data => rx_data, key_index => i, key_load => key_load
   );
   
   tx_data <= state_q(i mod 4, i / 4);
   
end architecture structural_p;
