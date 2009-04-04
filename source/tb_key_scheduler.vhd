-- File name:   tb_key_scheduler.vhd
-- Created:     4/4/2009
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

use work.aes.all;

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_key_scheduler is
    
    generic (clk_per : time := 4 ns);
    
end tb_key_scheduler;

architecture TEST of tb_key_scheduler is

-- Insert signals Declarations here
  signal clk : std_logic := '0';
  signal rst : std_logic;
  signal sbox_lookup : byte;
  signal sbox_return : byte;
  signal iteration : round;
  signal encryption_key : key;
  signal round_key : key;
  signal go : std_logic;
   -- clock only runs when stop isnt asserted
  signal stop             : std_logic := '1';
  signal done : std_logic;
-- signal <name> : <type>;

begin
  behavioral: entity work.key_scheduler(behavioral) port map(
                clk => clk,
                rst => rst,
                sbox_lookup => sbox_lookup,
                sbox_return => sbox_return,
                iteration => iteration,
                encryption_key => encryption_key,
                round_key => round_key,
                go => go,
                done => done
                );
                
  data : entity work.sbox(dataflow) port map (
     clk => clk, a => sbox_lookup, b => sbox_return
     );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

-- clock when stop isnt asserted
clk <= not clk and not stop after clk_per/2;

process

  begin
    
      
   -- start the clock
   stop <= '0';
   rst <= '1';
   wait for clk_per*2;
   rst <= '0';
   wait for clk_per;

-- Insert TEST BENCH Code Here

    encryption_key <= (x"00", x"00", x"00", x"00", x"00", x"00",
                       x"00", x"00", x"00", x"00", x"00", x"00",
                       x"00", x"00", x"00", x"00");
    
    
    --encryption_key <= (x"2b", x"7e", x"15", x"16", x"28", x"ae",
    --                   x"d2", x"a6", x"ab", x"f7", x"15", x"88",
    --                   x"09", x"cf", x"4f", x"3c");
    --
                       
    go <= '1';
    iteration <= 0;
    wait for clk_per;
    go <= '0';
    wait for clk_per*20;
    wait for clk_per*2;
    
     
    for i in 1 to 10 loop
       go <= '1';
       iteration <= i;
       wait for clk_per;
       go <= '0';
       wait for clk_per*4;
       go <= '0';
       wait for clk_per*20;
       wait for clk_per*2;
   end loop;
    
    
                       
     
   -- stop the clock
   stop <= '1';
   
   wait;
   
  end process;
end TEST;