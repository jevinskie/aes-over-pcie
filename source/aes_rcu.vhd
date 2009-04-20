-- File name:   aes_rcu.vhd
-- Created:     2009-03-30
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.1  Initial Design Entry
-- Description: Rijndael RCU

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aes_rcu is
   
   port (
      clk            : in std_logic;
      nrst           : in std_logic;
      key_done       : in std_logic;
      got_key        : in std_logic;
      got_pt         : in std_logic;
      p              : out g_index;
      subblock       : out subblock_type;
      current_round  : out round_type;
      start_key      : out std_logic;
      key_load       : out std_logic;
      aes_done       : out std_logic
   );
   
end entity aes_rcu;


architecture behavioral of aes_rcu is
   
   type state_type is (
      idle, e_idle, load_pt, load_key, sub_bytes,
      mix_columns, shift_rows, add_round_key,
      key_scheduler, round_start, round_end
   );
   
   signal state, next_state               : state_type;
   signal round_count, next_round_count   : round_type;
   signal round_count_up, round_count_clr : std_logic;
   signal i, next_i                       : g_index;
   signal i_up, i_clr                     : std_logic;
   
begin
   
   fsm_reg : process(clk, nrst)
   begin
      if (nrst = '0') then
         state <= idle;
      elsif rising_edge(clk) then
         state <= next_state;
      end if;
   end process fsm_reg;
   
   fsm_nsl : process(state)
   begin
      case state is
         when idle =>
            if (got_key = '1') then
               next_state <= load_key;
            elsif (got_pt = '1') then
               next_state <= load_pt;
            else
               next_state <= idle;
            end if;
         when e_idle =>
            next_state <= e_idle;
         when round_start =>
            next_state <= key_scheduler;
         when key_scheduler =>
            if (key_done = '0') then
               next_state <= key_scheduler;
            elsif (round_count = 0) then
               next_state <= add_round_key;
            else
               next_state <= sub_bytes;
            end if;
         when sub_bytes =>
            if (i /= 15) then
               next_state <= sub_bytes;
            else
               next_state <= shift_rows;
            end if;
         when shift_rows =>
            if (i /= 3) then
               next_state <= shift_rows;
            elsif (round_count /= 10) then
               next_state <= mix_columns;
            else
               next_state <= add_round_key;
            end if;
         when mix_columns =>
            if (i /= 3) then
               next_state <= mix_columns;
            else
               next_state <= add_round_key;
            end if;
         when add_round_key =>
            if (i /= 15) then
               next_state <= add_round_key;
            else
               next_state <= round_end;
            end if;
         when round_end =>
            if (round_count /= 10) then
               next_state <= round_start;
            else
               next_state <= idle;
            end if;
         when others =>
            -- nothing
      end case;
   end process fsm_nsl;
   
   fsm_output : process(state)
   begin
      key_load <= '0';
      i_clr <= '0';
      case state is
         when idle =>
            i_clr <= '1';
         when e_idle =>
            key_load <= '1';
         when others =>
            -- nothing
      end case;
   end process fsm_output;
   
   -- leda C_1406 off
   round_count_reg : process(clk)
   begin
      if rising_edge(clk) then
         round_count <= next_round_count;
      end if;
   end process round_count_reg;
   -- leda C_1406 on
   
   round_count_nsl : process(round_count, round_count_up, round_count_clr)
   begin
      if (round_count_clr = '1') then
         next_round_count <= 0;
      elsif (round_count_up = '1') then
         next_round_count <= round_count + 1;
      else
         next_round_count <= round_count;
      end if;
   end process round_count_nsl;
   
   -- leda C_1406 off
   i_reg : process(clk)
   begin
      if rising_edge(clk) then
         i <= next_i;
      end if;
   end process i_reg;
   -- leda C_1406 on
   
   i_nsl : process(i, i_up, i_clr)
   begin
      if (i_clr = '1') then
         next_i <= 0;
      elsif (i_up = '1') then
         next_i <= i + 1;
      else
         next_i <= i;
      end if;
   end process i_nsl;
   
end architecture behavioral;

