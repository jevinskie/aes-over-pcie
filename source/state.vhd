-- File name:   state.vhd
-- Created:     2009-04-04
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: AES state register block


use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state is
   
   port (
      clk      : in std_logic;
      state_d  : in state_type;
      state_q  : out state_type
   );
   
end entity state;


architecture dataflow of state is
   
begin
   
   -- leda C_1406 off
   process(clk)
   begin
      if rising_edge(clk) then
         state_q <= state_d;
      end if;
   end process;
   -- leda C_1406 on
   
end architecture dataflow;

