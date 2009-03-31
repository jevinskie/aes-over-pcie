-- $Id: $
-- File name:   tb_shift_rows.vhd
-- Created:     3/30/2009
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

use work.aes.all;

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_shift_rows is
end tb_shift_rows;

architecture TEST of tb_shift_rows is

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

  component shift_rows
    PORT(
         clk : in std_logic;
         data_in : in slice;
         num_shifts : in shift_amount;
         data_out : out slice
    );
  end component;

-- Insert signals Declarations here
  signal clk : std_logic;
  signal data_in : slice;
  signal num_shifts : shift_amount;
  signal data_out : slice;

-- signal <name> : <type>;

begin
  DUT: shift_rows port map(
                clk => clk,
                data_in => data_in,
                num_shifts => num_shifts,
                data_out => data_out
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process
   begin
       
    clk <= '0';
       
    data_in <= (x"DB", x"13", x"53", x"45");
    num_shifts <= 0;
    wait for 10 ns;
    data_in <= (x"f2", x"0a", x"22", x"5c");
    num_shifts <= 1;
    wait for 10 ns;
    data_in <= (x"a3", x"01", x"b3", x"09");
    num_shifts <= 2;
    wait for 10 ns;
    data_in <= (x"c7", x"d6", x"c6", x"a6");
    num_shifts <= 3;
    wait for 10 ns;
    data_in <= (x"d4", x"d3", x"d4", x"d5");
    num_shifts <= 1;
    wait for 10 ns;
    data_in <= (x"2d", x"26", x"31", x"4c");
    num_shifts <=2;
    
    wait;
  end process;
end TEST;