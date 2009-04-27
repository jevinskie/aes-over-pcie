-- File name:   state_filter_out_p.vhd
-- Created:     2009-04-26
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: parallel state_filter_out

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_filter_out_p is
   
   port (
      current_state     : in state_type;
      sub_bytes_out     : in state_type;
      shift_rows_out    : in state_type;
      mix_columns_out   : in state_type;
      add_round_key_out : in state_type;
      load_out          : in byte;
      subblock          : in subblock_type;
      i                 : in g_index;
      next_state        : out state_type
   );
   
end entity state_filter_out_p;


architecture mux of state_filter_out_p is
   
begin
   
   process(current_state, sub_bytes_out, shift_rows_out,
      mix_columns_out, add_round_key_out, load_out, subblock, i)
   begin
      next_state <= current_state;
      case subblock is
         when identity =>
            -- already selected
         when sub_bytes =>
            next_state <= sub_bytes_out;
         when shift_rows =>
            next_state <= shift_rows_out;
         when mix_columns =>
            next_state <= mix_columns_out;
         when add_round_key =>
            next_state <= add_round_key_out;
         when load_pt =>
            for x in index loop
               for y in index loop
                  if (x + y * 4 = i) then
                     next_state(x, y) <= load_out;
                  end if;
               end loop;
            end loop;
         when store_ct =>
            -- already selected
         when others =>
            -- already selected
      end case;
   end process;
   
end architecture mux;

