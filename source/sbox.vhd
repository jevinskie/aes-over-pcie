-- File name:   sbox.vhd
-- Created:     2009-02-26
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: Rijndael S-Box

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sbox is
   port (
      a : in byte;
      b : out byte;
   );
end sbox;

architecture dataflow of sbox is
begin
   
end dataflow;

