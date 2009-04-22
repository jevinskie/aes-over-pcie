-- File name:   fifo.vhd
-- Created:     2009-04-20 (^-^)y-~~'`
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: FIFO

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
   
   generic (
      size : positive := 32
   );
   
   port (
      clk      : in std_logic;
      nrst     : in std_logic;
      re       : in std_logic;
      we       : in std_logic;
      w_data   : in byte;
      r_data   : out byte;
      empty    : out std_logic;
      full     : out std_logic
   );
   
   subtype fifo_pntr is integer range 0 to (size-1);
   type fifo_array is array (fifo_pntr) of byte;
   
end entity fifo;


architecture behavioral of fifo is
   
   signal r_pntr, next_r_pntr : fifo_pntr;
   signal w_pntr, next_w_pntr : fifo_pntr;
   signal fifo, next_fifo     : fifo_array;
   signal re_int, we_int      : std_logic;
   signal empty_int, full_int : std_logic;
   
begin
   
   fifo_reg : process(clk)
   begin
      if rising_edge(clk) then
         fifo <= next_fifo;
      end if;
   end process fifo_reg;
   
   fifo_nsl : process(fifo, w_pntr, we_int, w_data)
   begin
      next_fifo <= fifo;
      if (we_int = '1') then
         next_fifo(w_pntr) <= w_data;
      end if;
   end process fifo_nsl;
   
   r_pntr_reg : process(clk, nrst)
   begin
      if (nrst = '0') then
         r_pntr <= 0;
      elsif rising_edge(clk) then
         r_pntr <= next_r_pntr;
      end if;
   end process r_pntr_reg;
   
   r_pntr_nsl : process(re_int, r_pntr)
   begin
      if (re_int = '1') then
         next_r_pntr <= (r_pntr + 1) mod size;
      else
         next_r_pntr <= r_pntr;
      end if;
   end process;
   
   w_pntr_reg : process(clk, nrst)
   begin
      if (nrst = '0') then
         w_pntr <= 0;
      elsif rising_edge(clk) then
         w_pntr <= next_w_pntr;
      end if;
   end process w_pntr_reg;
   
   w_pntr_nsl : process(we_int, w_pntr)
   begin
      if (we_int = '1') then
         next_w_pntr <= (w_pntr + 1) mod size;
      else
         next_w_pntr <= w_pntr;
      end if;
   end process w_pntr_nsl;
   
   re_int <= '1' when re = '1' and empty_int = '0' else '0';
   
   we_int <= '1' when we = '1' and full_int = '0' else '0';
   
   r_data <= fifo(r_pntr);
   
   empty_int <= '1' when r_pntr = w_pntr else '0';
   
   full_int <= '1' when  r_pntr = (w_pntr + 1) mod size else '0';
   
   empty <= empty_int;
   
   full <= full_int;
   
end architecture behavioral;

