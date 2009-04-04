-- File name:   state_filter_out.vhd
-- Created:     2009-03-30
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: Rijndael state filter for subblock outputs

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_filter_out is
   
   port (
      current_state     : in state_type;
      sub_bytes_out     : in byte;
      shift_rows_out    : in row;
      mix_columns_out   : in col;
      add_round_key_out : in byte;
      load_out          : in byte;
      subblock          : in subblock_type;
      i                 : in g_index;
      next_state        : out state_type
   );
   
end entity state_filter_out;


architecture tristate of state_filter_out is
   
begin
   
   identity_proc : process(subblock, i, current_state)
   begin
      for x in index loop
         for y in index loop
            case subblock is
               when identity =>
                  -- select all the current bytes
                  next_state(x, y) <= current_state(x, y);
               when sub_bytes =>
                  -- dont select the indexed byte
                  if (x * 4 + y /= i) then
                     next_state(x, y) <= current_state(x, y);
                  else
                     next_state(x, y) <= (others => 'Z');
                  end if;
               when shift_rows =>
                  -- dont select the indexed row
                  if (x /= i / 4) then
                     next_state(x, y) <= current_state(x, y);
                  else
                     next_state(x, y) <= (others => 'Z');
                  end if;
               when mix_columns =>
                  -- dont select the indexed column
                  if (y /= i mod 4) then
                     next_state(x, y) <= current_state(x, y);
                  else
                     next_state(x, y) <= (others => 'Z');
                  end if;
               when add_round_key =>
                  -- dont select the indexed byte
                  if (x * 4 + y /= i) then
                     next_state(x, y) <= current_state(x, y);
                  else
                     next_state(x, y) <= (others => 'Z');
                  end if;
               when load =>
                  -- dont select the indexed byte
                  if (x * 4 + y /= i) then
                     next_state(x, y) <= current_state(x, y);
                  else
                     next_state(x, y) <= (others => 'Z');
                  end if;
               when others =>
                  next_state(x, y) <= (others => 'Z');
            end case;
         end loop;
      end loop;
   end process identity_proc;
   
   
   sub_bytes_proc : process(subblock, i, current_state, sub_bytes_out)
   begin
      for x in index loop
         for y in index loop
            case subblock is
               when sub_bytes =>
                  -- select just the indexed byte
                  if (x * 4 + y = i) then
                     next_state(x, y) <= sub_bytes_out;
                  else
                     next_state(x, y) <= (others => 'Z');
                  end if;
               when others =>
                  next_state(x, y) <= (others => 'Z');
            end case;
         end loop;
      end loop;
   end process sub_bytes_proc;
   
   
   shift_rows_proc : process(subblock, i, current_state, shift_rows_out)
   begin
      for x in index loop
         for y in index loop
            case subblock is
               when shift_rows =>
                  -- select just the indexed row
                  if (x = i) then
                     next_state(x, y) <= shift_rows_out(y);
                  else
                     next_state(x, y) <= (others => 'Z');
                  end if;
               when others =>
                  next_state(x, y) <= (others => 'Z');
            end case;
         end loop;
      end loop;
   end process shift_rows_proc;
   
   
   mix_columns_proc : process(subblock, i, current_state, mix_columns_out)
   begin
      for x in index loop
         for y in index loop
            case subblock is
               when mix_columns =>
                  -- select just the indexed column
                  if (y = i) then
                     next_state(x, y) <= mix_columns_out(x);
                  else
                     next_state(x, y) <= (others => 'Z');
                  end if;
               when others =>
                  next_state(x, y) <= (others => 'Z');
            end case;
         end loop;
      end loop;
   end process mix_columns_proc;
   
   
   add_round_key_proc : process(subblock, i, current_state, add_round_key_out)
   begin
      for x in index loop
         for y in index loop
            case subblock is
               when add_round_key =>
                  -- select just the indexed byte
                  if (x * 4 + y = i) then
                     next_state(x, y) <= add_round_key_out;
                  else
                     next_state(x, y) <= (others => 'Z');
                  end if;
               when others =>
                  next_state(x, y) <= (others => 'Z');
            end case;
         end loop;
      end loop;
   end process add_round_key_proc;
   
   
   load_proc : process(subblock, i, current_state, load_out)
   begin
      for x in index loop
         for y in index loop
            case subblock is
               when load =>
                  -- select just the indexed byte
                  if (x * 4 + y = i) then
                     next_state(x, y) <= load_out;
                  else
                     next_state(x, y) <= (others => 'Z');
                  end if;
               when others =>
                  next_state(x, y) <= (others => 'Z');
            end case;
         end loop;
      end loop;
   end process load_proc;
   
end architecture tristate;




architecture mux of state_filter_out is
   
begin
   
   process(current_state, sub_bytes_out, shift_rows_out,
      mix_columns_out, add_round_key_out, load_out, subblock, i)
   begin
      for x in index loop
         for y in index loop
            next_state(x, y) <= current_state(x, y);
            case subblock is
               when identity =>
                  -- select all the current bytes (already done)
               when sub_bytes =>
                  -- select just the indexed byte
                  if (x * 4 + y = i) then
                     next_state(x, y) <= sub_bytes_out;
                  end if;
               when shift_rows =>
                  -- select just the indexed row
                  if (x = i) then
                     next_state(x, y) <= shift_rows_out(y);
                  end if;
               when mix_columns =>
                  -- select just the indexed column
                  if (y = i) then
                     next_state(x, y) <= mix_columns_out(x);
                  end if;
               when add_round_key =>
                  -- select just the index byte
                  if (x * 4 + y = i) then
                     next_state(x, y) <= add_round_key_out;
                  end if;
               when load =>
                  -- select just the index byte
                  if (x * 4 + y = i) then
                     next_state(x, y) <= load_out;
                  end if;
               when others =>
                  next_state(x, y) <= current_state(x, y);
            end case;
         end loop;
      end loop;
   end process;
   
end architecture mux;

