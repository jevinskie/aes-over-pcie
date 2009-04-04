-- File name:   tb_aes_rcu.vhd
-- Created:     4/4/2009
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

use work.aes.all;

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_aes_rcu  is
    
    generic (clk_per : time := 4 ns);
    
end tb_aes_rcu ;

architecture TEST of tb_aes_rcu is

-- Insert signals Declarations here
  signal clk      : std_logic := '0';
  signal nrst     : std_logic;
  signal p        : g_index;
  signal subblock : subblock_type;
  
   -- clock only runs when stop isnt asserted
  signal stop             : std_logic := '1';

-- signal <name> : <type>;

begin
  behavioral: entity work.aes_rcu (behavioral) port map(
              clk => clk,
              nrst => nrst,
              p => p,
              subblock => subblock
              );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

-- clock when stop isnt asserted
clk <= not clk and not stop after clk_per/2;

process

  begin
    
      
   -- start the clock
   stop <= '0';
   nrst <= '0';
   wait for clk_per*4;
   nrst <= '1';
   wait for clk_per*2;
   
   wait for clk_per*100;

    
                       
     
   -- stop the clock
   stop <= '1';
   
   wait;
   
  end process;
end TEST;