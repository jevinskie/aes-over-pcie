-- $Id: 17
-- File name:   tb_mix_columns.vhd
-- Created:     3/30/2009
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

use work.aes.all;

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_mix_columns is
end tb_mix_columns;

architecture TEST of tb_mix_columns is

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

  component mix_columns
    PORT(
         clk : in std_logic;
         d_in : in col;
         d_out : out col
    );
  end component;

-- Insert signals Declarations here
  signal clk : std_logic;
  signal d_in : col;
  signal d_out : col;

-- signal <name> : <type>;

begin
  DUT: mix_columns port map(
                clk => clk,
                d_in => d_in,
                d_out => d_out
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process

  begin

-- Insert TEST BENCH Code Here

    clk <= '0';
    
    d_in <= (x"DB", x"13", x"53", x"45");
    wait for 10 ns;
    d_in <= (x"f2", x"0a", x"22", x"5c");
    wait for 10 ns;
    d_in <= (x"01", x"01", x"01", x"01");
    wait for 10 ns;
    d_in <= (x"c6", x"c6", x"c6", x"c6");
    wait for 10 ns;
    d_in <= (x"d4", x"d4", x"d4", x"d5");
    wait for 10 ns;
    d_in <= (x"2d", x"26", x"31", x"4c");
    
   wait;
  end process;
end TEST;