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


architecture behavioral of aes_rcu is
   
begin
   
end architecture behavioral;

