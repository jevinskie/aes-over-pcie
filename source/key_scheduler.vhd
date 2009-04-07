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
          clk: in std_logic;
          nrst: in std_logic;
          sbox_lookup: out byte;
          sbox_return: in byte;
          iteration: in round;
          encryption_key: in key;
          round_key: out key;
          go : in std_logic; 
          done : out std_logic     
          );
   
   type rcon_array is array (0 to 10) of byte;     
   constant rcon : rcon_array :=
      (
        x"8d", x"01", x"02", x"04", x"08", x"10", x"20", x"40", 
        x"80", x"1b", x"36"
      );
       
end key_scheduler;

architecture behavioral of key_scheduler is
    type states is (IDLE, SETUP, SETUP2, SETUP3, SETUP4, SETUP5, COMPUTE,
                    COMPUTE2, COMPUTE3, COMPUTE4, SETUP2b, SETUP3b, SETUP4b,
                    STOREKEY);
    signal state, nextstate: states;
    signal stored_key, next_stored_key : key;
    signal int_col, test : col;
    signal store: std_logic;

begin
    

    -- leda C_1406 off
    state_reg: process(clk, nrst)
    begin
        if (nrst = '0') then
            state <= IDLE;
        elsif (rising_edge(clk)) then
            state <= nextstate;
            if (store = '1') then
                stored_key <= next_stored_key;
            end if;
        end if;
    end process state_reg;
   -- leda C_1406 on

    process(sbox_return,iteration,store,encryption_key,state, go)
        variable word0, word1, word2, word3, rotword : col;
    begin
       store <= '0';
       done <= '0';
       case state is
           when IDLE =>
                if (go = '1') then
                    nextstate <= SETUP;
                else
                    nextstate <= IDLE;
                end if;
           when SETUP =>
                if (iteration = 0) then   --setup round
                    next_stored_key <= encryption_key;  --first round, load in user input key
                    nextstate <= STOREKEY;
                else    --Rjindeal rounds 1 through 10
                 --break stored key into 4 words
                 for i in 0 to 3 loop
                    word0(i) := stored_key(i);
                    word1(i) := stored_key(i+4);
                    word2(i) := stored_key(i+8);
                    word3(i) := stored_key(i+12);
                 end loop;
                 for j in 0 to 3 loop
                    rotword(j) := word3((j+1) mod 4); --generated rotated word
                 end loop;
                 
                 --sbox sub 0
                 sbox_lookup <= rotword(0);
                 nextstate <= SETUP2;
                end if;
            when SETUP2 =>
                --first sbox sub should be here
                rotword(0) := sbox_return;
                nextstate <= SETUP2b;
            when SETUP2b =>            
                --sbox sub 1
                sbox_lookup <= rotword(1);
                int_col <= rotword;
                nextstate <= SETUP3;
            when SETUP3 =>
                rotword(1) :=sbox_return;
                nextstate <= SETUP3b;
            when SETUP3b =>
                sbox_lookup <= rotword(2);
                int_col <= rotword;
                nextstate <= SETUP4;
            when SETUP4 =>
                rotword(2) := sbox_return;
                nextstate <= SETUP4b;
            when SETUP4b =>
                sbox_lookup <= rotword(3);
                int_col <= rotword;
                nextstate <= SETUP5;
            when SETUP5 =>
                rotword(3) := sbox_return;
                --rotword should now be completely subbed
                int_col <= rotword;    
                rotword(0) := rotword(0) xor rcon(iteration);
                --int_col <= rotword;
                nextstate <= COMPUTE;
            when COMPUTE =>
                for i in 0 to 3 loop
                   word0(i) := word0(i) xor rotword(i);
                end loop;
                int_col <= word0;
                nextstate <= COMPUTE2;
            when COMPUTE2 =>
                for i in 0 to 3 loop
                   word1(i) := word1(i) xor word0(i);
               end loop;
                nextstate <= COMPUTE3;
            when COMPUTE3 =>
                for i in 0 to 3 loop
                   word2(i) := word2(i) xor word1(i);
            end loop;
                nextstate <= COMPUTE4;
            when COMPUTE4 =>
               for i in 0 to 3 loop
                   word3(i) := word3(i) xor word2(i);
            end loop;
                --combine chunks back togethers
                 for i in 0 to 3 loop
                    next_stored_key(i) <= word0(i);
                    next_stored_key(i+4) <= word1(i);
                    next_stored_key(i+8) <= word2(i);
                    next_stored_key(i+12) <= word3(i);
                 end loop;
                 nextstate <= STOREKEY;
            when STOREKEY =>
                  store <= '1';   
                  done <= '1';
                  nextstate <= IDLE;       
            end case;    
    
    end process;
    done <= '1' when (state = STOREKEY) else '0';
    round_key <= stored_key;
end behavioral;
