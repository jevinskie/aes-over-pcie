-- File name:   add_round_key.vhd
-- Created:     2009-03-30
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: each byte of the state is combined with the round
-- key; each round key is derived from the cipher key using the
-- key scheduler

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_round_key is
   
   port (
      data_in  : in byte;
      key_in   : in byte;
      data_out : out byte
   );
   
end entity add_round_key;


architecture dataflow of add_round_key is
   
begin
   
   -- for each round of the addroundkey step, a subkey byte that was
   -- derived from the key scheduler is added to the corresponding
   -- byte of the state using bitwise XOR.
    
   data_out <= data_in xor key_in;
   
end architecture dataflow;

