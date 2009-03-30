-- $Id: 17
-- File name:   add_round_key.vhd
-- Created:     3/30/2009
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: each byte of the state is combined with the round 
-- key; each round key is derived from the cipher key using the 
-- key scheduler

use work.aes.all;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity add_round_key is
    port (clk      : in std_logic;
          data_in  : in byte;
          key_in   : in byte;
          data_out : out byte
          );    
end add_round_key;
          
architecture dataflow of add_round_key is
    
    -- for each round of the addroundkey step, a subkey byte that was
    -- derived from the key scheduler is added to the corresponding
    -- byte of the state using bitwise XOR.
begin
    process(data_in, key_in)
        begin
            
            data_out <= data_in xor key_in;
            
    end process;
end dataflow;