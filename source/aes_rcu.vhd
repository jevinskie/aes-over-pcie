-- File name:   aes_rcu.vhd
-- Created:     2009-03-30
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: Rijndael RCU

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aes_rcu is
   
   port (
      clk      : in std_logic;
      nrst     : in std_logic;
      p        : out g_index;
      subblock : out subblock_type 
   );
   
end entity aes_rcu;


architecture Behavioral of aes_rcu is
   type state_type is (IDLE, KEYSCH, ADDRNDKY, SUBBY, SHFTRWS, MXCOLS);
   signal state, nextstate: state_type;
Begin
StateReg: process (clk, nrst)
   begin
       -- on reset, the RCU goes to the IDLE state, otherwise it goes
       -- to the next state.
       if (nrst = '0') then
           state <= IDLE;
       elsif (clk'event and clk = '1') then
           state <= nextstate;
       end if;
end process StateReg;

Next_state: process (state)
   variable count : unsigned(3 downto 0) := "0000";
   begin
      case state is
         when IDLE =>
             nextstate <= KEYSCH;
         when KEYSCH =>
             nextstate <= ADDRNDKY;
         when ADDRNDKY =>
             count := count + 1;
             if (count < 11) then
                nextstate <= SUBBY;
             else
                nextstate <= IDLE;
             end if;
         when SUBBY =>
             nextstate <= SHFTRWS;
         when SHFTRWS =>
             if (count < 10) then
                 nextstate <= MXCOLS;
             else
                 nextstate <= KEYSCH;
             end if;
         when MXCOLS =>
             nextstate <= KEYSCH;
         when others =>       
            nextstate <= IDLE;
         end case;
end process Next_state;
  
end architecture Behavioral;

