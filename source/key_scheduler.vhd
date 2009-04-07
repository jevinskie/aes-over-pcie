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
      encryption_key : in key_type;
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
      idle, load_key, rotate, sub_bytes, add_cols, rcon, check_done, be_done
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
               next_state <= add_cols;
            end if;
         when add_cols =>
            if (r /= 3) then
               next_state <= add_cols;
            else
               next_state <= rcon;
            end if;
         when rcon =>
            next_state <= check_done;
         when check_done =>
            if (c /= 3) then
               next_state <= rotate;
            else
               next_state <= be_done;
            end if;
         when be_done =>
            next_state <= idle;
      end case;
   end process state_nsl;
   
   state_out : process(state, cur_key, new_key, encryption_key,
      sbox_return_reged, c, r, round)
   begin
      next_cur_key <= cur_key;
      next_new_key <= new_key;
      c_up <= '0';
      c_clr <= '0';
      r_clr <= '0';
      done <= '0';
      sbox_lookup <= new_key(3, c);
      case state is
         when idle =>
            -- nothing
         when load_key =>
            next_new_key <= encryption_key;
            c_clr <= '1';
         when rotate =>
            r_clr <= '1';
            for i in index loop
               next_new_key(i, c) <= new_key(to_integer(to_unsigned(i, 2)+1), c);
            end loop;
         when sub_bytes =>
            sbox_lookup <= new_key(to_integer(to_unsigned(r, 2) + 1), c);
            next_new_key(r, c) <= sbox_return_reged;
         when add_cols =>
            next_new_key(r, c) <= new_key(r, c) xor cur_key(r, c);
         when rcon =>
            next_new_key(0, c) <= new_key(0, c) xor rcon_tbl(round);
         when check_done =>
            c_up <= '1';
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
