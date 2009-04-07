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
      subblock : out subblock_type;
      current_round    : out round_type;
      start_key: out std_logic;
      key_done : in std_logic
   );
   
end entity aes_rcu;


architecture Behavioral of aes_rcu is
   type state_type is (IDLE, KEYSCH, ADDRNDKY, SUBBY, SHFTRWS, MXCOLS);
   signal state, nextstate: state_type;
   signal roundcount, nextroundcount: round_type;
   signal blockcount, nextblockcount: b_index;
   
Begin
StateReg: process (clk, nrst)
   begin
       -- on reset, the RCU goes to the IDLE state, otherwise it goes
       -- to the next state.
       if (nrst = '0') then
           state <= IDLE;
       elsif (rising_edge(clk)) then
           state <= nextstate;
       end if;
end process StateReg;

RoundCounter: process(clk, nrst)
   begin
       if (nrst = '0') then
           roundcount <= 0;
       elsif (rising_edge(clk)) then
           roundcount <= nextroundcount;
       end if;
   end process RoundCounter;

SubBlockCounter: process(clk, nrst)
     begin
            if (nrst = '0') then
                blockcount <= 0;
            elsif (rising_edge(clk)) then
                blockcount <= nextblockcount;
            end if;
    end process SubBlockCounter;
        
Next_state: process (state, roundcount, blockcount, key_done)
      begin
      start_key <= '0';
      case state is
         when IDLE =>
             nextstate <= KEYSCH;
             nextroundcount <= 0;
             nextblockcount <= 0;
             start_key <= '1';
         when KEYSCH =>
             start_key <= '1';           
             if (key_done = '0') then
                 p <= roundcount;
                 subblock <= identity;
                 nextstate <= KEYSCH;
             else
             --send go signal to key_scheduler, wait in this
             --state until it sends done signal
             
             --reset block counter
                 nextblockcount <= 0;
                 nextstate <= ADDRNDKY;
             end if;
         when ADDRNDKY =>
             --loop through 16 times
            nextblockcount <= blockcount + 1;
            --nextroundcount <= roundcount + 1;
            if (roundcount < 10) then
                if (blockcount < 16) then
                    --send bus signals for addroundkey
                    p <= blockcount;
                    subblock <= add_round_key;
                    nextstate <= ADDRNDKY;
                else
                   nextblockcount <= 0;
                   nextroundcount <= roundcount + 1;
                   nextstate <= SUBBY;
               end if;
             else
                nextstate <= IDLE;
             end if;
         when SUBBY =>
             nextblockcount <= blockcount + 1;
             if (blockcount < 16) then
                 p <= blockcount;
                 subblock <= sub_bytes;
                 nextstate <= SUBBY;
             else
                 nextblockcount <= 0;
                 nextstate <= SHFTRWS;
             end if;
         when SHFTRWS =>
             nextblockcount <= blockcount + 1;
             if (roundcount < 10) then
                 if (blockcount < 4) then
                    p <= blockcount;
                    subblock <= shift_rows; 
                    nextstate <= SHFTRWS;
                 else
                    nextblockcount <= 0;
                    nextstate <= MXCOLS;
                 end if;
             else
                if (blockcount < 4) then
                   p <= blockcount;
                   subblock <= shift_rows; 
                   nextstate <= SHFTRWS;
                else
                   nextblockcount <= 0;
                   nextstate <= KEYSCH;
                   start_key <= '1';
                end if;
             end if;
         when MXCOLS =>
             nextblockcount <= blockcount + 1;
             if (blockcount < 4) then
                 p <= blockcount;
                 subblock <= mix_columns;
                 nextstate <= MXCOLS;
             else
                 nextblockcount <= 0;
                 nextstate <= KEYSCH;
                 start_key <= '1';
             end if;
         when others =>       
            nextstate <= IDLE;
         end case;
end process Next_state;
  
  current_round <= roundcount;
end architecture Behavioral;

