-- File name:   aes_top.vhd
-- Created:     2009-04-04
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: AES top level

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_top is
   
   port (
      clk   : in std_logic;
      nrst  : in std_logic
   );
   
end entity top_top;


architecture structural of top_top is
   
begin
   
   
	aes_top_b : entity work.aes_top(structural) port map (
		clk => clk, nrst => nrst
	);
	
	
end architecture structural;

