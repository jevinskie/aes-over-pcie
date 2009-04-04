-- File name:   tb_add_round_key.vhd
-- Created:     3/31/2009
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

use work.aes.all;

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_add_round_key is
end tb_add_round_key;

architecture TEST of tb_add_round_key is

  function INT_TO_STD_LOGIC( X: INTEGER; NumBits: INTEGER )
     return STD_LOGIC_VECTOR is
    variable RES : STD_LOGIC_VECTOR(NumBits-1 downto 0);
    variable tmp : INTEGER;
  begin
    tmp := X;
    for i in 0 to NumBits-1 loop
      if (tmp mod 2)=1 then
        res(i) := '1';
      else
        res(i) := '0';
      end if;
      tmp := tmp/2;
    end loop;
    return res;
  end;

  component add_round_key
    PORT(
         data_in : in byte;
         key_in : in byte;
         data_out : out byte
    );
  end component;

-- Insert signals Declarations here
  signal data_in : byte;
  signal key_in : byte;
  signal data_out : byte;

-- signal <name> : <type>;

begin
  DUT: add_round_key port map(
                data_in => data_in,
                key_in => key_in,
                data_out => data_out
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process

  begin

-- Insert TEST BENCH Code Here

    data_in <= x"a3";

    key_in <= x"54";
    
    wait for 10 ns;
    
    data_in <= "11111111";

    key_in <= "11111111";
    
    wait for 10 ns;
    
    data_in <= "00000000";

    key_in <= "11111111";
    
    wait for 10 ns;
    
    data_in <= "11111111";

    key_in <= "00000000";
    
    wait for 10 ns;
    
    data_in <= "10101010";

    key_in <= "01010101";
    
    wait for 10 ns;
    
    data_in <= x"23";

    key_in <= x"b7";
    
  wait;
  end process;
end TEST;