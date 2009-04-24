-- File name:   key_scheduler.vhd
-- Created:     2009-03-30
-- Author:      Matt Swanson
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: Rijndael KeyScheduler


use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity key_scheduler is
   
   
   port (
      clk            : in std_logic;
      nrst           : in std_logic;
      go             : in std_logic;
      round          : in round_type;
      key_data       : in byte;
      key_index      : in g_index;
      key_load       : in std_logic;
      sbox_return    : in byte;
      sbox_lookup    : out byte;
      round_key      : out key_type; 
      done           : out std_logic     
   );
   
   
   type rcon_array is array (0 to 10) of byte;     
   constant rcon_tbl : rcon_array :=
      (
         x"8d", x"01", x"02", x"04", x"08", x"10", x"20", x"40", 
         x"80", x"1b", x"36"
      );
   
   
end key_scheduler;


architecture behavioral of key_scheduler is
   
   
   type state_type is (
      idle, load_key, rotate, sub_bytes, add_cols, rcon, be_done
   );
   
   
   signal state            : state_type;
   signal next_state       : state_type;
   signal cur_key          : key_type;
   signal next_cur_key     : key_type;
   signal new_key          : key_type;
   signal next_new_key     : key_type;
   signal c                : index;
   signal next_c           : index;
   signal c_clr            : std_logic;
   signal c_up             : std_logic;
   signal r                : index;
   signal next_r           : index;
   signal r_clr            : std_logic;
   signal sbox_return_reged : byte;
   
   
begin
   
   
   -- leda C_1406 off
   state_reg : process(clk, nrst)
   begin
      if (nrst = '0') then
         state <= idle;
      elsif rising_edge(clk) then
         state <= next_state;
         cur_key <= next_cur_key;
         new_key <= next_new_key;
      end if;
   end process state_reg;
   -- leda C_1406 on
   
   state_nsl : process(state, go, r, c, round)
   begin
      next_state <= idle;
      case state is
         when idle =>
            if (go = '1' and round = 0) then
               next_state <= load_key;
            elsif (go = '1') then
               next_state <= rotate;
            else
               next_state <= idle;
            end if;
         when load_key =>
            next_state <= be_done;
         when rotate =>
            next_state <= sub_bytes;
         when sub_bytes =>
            if (r /= 3) then
               next_state <= sub_bytes;
            else
               next_state <= rcon;
            end if;
         when rcon =>
            next_state <= add_cols;
         when add_cols =>
            if (r = 3 and c = 3) then
               next_state <= be_done;
            else
               next_state <= add_cols;
            end if;
         when be_done =>
            next_state <= idle;
      end case;
   end process state_nsl;
   
   
   state_out : process(state, cur_key, new_key, key_data,
      key_index, key_load,
      sbox_return_reged, c, r, round)
      variable temp_index : index;
   begin
      next_cur_key <= cur_key;
      next_new_key <= new_key;
      c_up <= '0';
      c_clr <= '0';
      r_clr <= '0';
      done <= '0';
      sbox_lookup <= (others => '-');
      case state is
         when idle =>
            if (key_load = '1') then
               next_new_key(key_index mod 4, key_index / 4) <= key_data;
            end if;
         when load_key =>
            -- nothing
         when rotate =>
            r_clr <= '1';
            c_clr <= '1';
            sbox_lookup <= cur_key(1, 3);
            for i in index loop
               next_new_key(i, 0) <= cur_key(to_integer(to_unsigned(i, 2) + 1), 3);
            end loop;
         when sub_bytes =>
            sbox_lookup <= new_key(to_integer(to_unsigned(r, 2) + 1), 0);
            next_new_key(r, c) <= sbox_return_reged;
         when rcon =>
            -- leda DFT_021 off
            next_new_key(0, 0) <= new_key(0, 0) xor rcon_tbl(round);
            -- leda DFT_021 on
            c_clr <= '1';
            r_clr <= '1';
         when add_cols =>
            if (c = 0) then
               temp_index := 0;
            else
               temp_index := c - 1;
            end if;
            next_new_key(r, c) <= new_key(r, temp_index) xor cur_key(r, c);
            if (r = 3) then
               c_up <= '1';
            end if;
         when be_done =>
            next_cur_key <= new_key;
            done <= '1';
      end case;
   end process state_out;
   
   -- leda C_1406 off
   c_counter_reg : process(clk)
   begin
      if rising_edge(clk) then
         c <= next_c;
      end if;
   end process c_counter_reg;
   -- leda C_1406 on
   
   c_counter_nsl : process(c, c_up, c_clr)
   begin
      if (c_clr = '1') then
         next_c <= 0;
      elsif (c_up = '1') then
         next_c <= to_integer(to_unsigned(c, 2) + 1);
      else
         next_c <= c;
      end if;
   end process c_counter_nsl;
   
   -- leda C_1406 off
   r_counter_reg : process(clk)
   begin
      if rising_edge(clk) then
         r <= next_r;
      end if;
   end process r_counter_reg;
   -- leda C_1406 on
   
   -- leda C_1406 off
   sbox_return_reg : process(clk)
   begin
      if rising_edge(clk) then
         sbox_return_reged <= sbox_return;
      end if;
   end process sbox_return_reg;
   -- leda C_1406 on

   
   r_counter_nsl : process(r, r_clr)
   begin
      if (r_clr = '1') then
         next_r <= 0;
      else
         next_r <= to_integer(to_unsigned(r, 2) + 1);
      end if;
   end process r_counter_nsl;
   
   round_key <= cur_key;
   
end behavioral;

