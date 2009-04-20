-- File name:   state_filter_in.vhd
-- Created:     2009-03-30
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: Rijndael state filter for subblock inputs

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_filter_in is
   
   port (
      s              : in state_type;
      subblock       : in subblock_type;
      round_key      : in key_type;
      i              : in g_index;
      ks_sbox_lookup : in byte;
      d_out          : out slice;
      filtered_key   : out byte
   );
   
end entity state_filter_in;


architecture behavioral of state_filter_in is
   
begin
   
   process(i, subblock, s, round_key)
      variable r, c : index;
      variable i_clamped : index;
   begin
      -- by default output dont cares
      for j in index loop
         d_out(j) <= (others => '-');
      end loop;
      
      filtered_key <= (others => '-');
      
      i_clamped := to_integer(resize(to_unsigned(i, 4), 2));
      
      r := to_integer(to_unsigned(i / 4, 2));
      c := to_integer(to_unsigned(i mod 4, 2));
      
      case subblock is
         when sub_bytes =>
            -- output the indexed byte
            d_out(0) <= s(r, c);
         when shift_rows =>
            -- output the indexed row
            for j in index loop
               d_out(j) <= s(j, i_clamped);
            end loop;
         when mix_columns =>
            -- output the indexed column
            for j in index loop
               d_out(j) <= s(i_clamped, j);
            end loop;
         when add_round_key =>
            -- output the indexed byte
            d_out(0) <= s(r, c);
            filtered_key <= round_key(r, c);
         when key_scheduler =>
            d_out(0) <= ks_sbox_lookup;
         when others =>
            -- dont care - already done at the top
      end case;
   end process;
   
end architecture behavioral;

