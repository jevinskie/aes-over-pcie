library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mix_columns is
    Port(CLK, RST : in std_logic;
         DATA_IN : in std_logic_vector(31 downto 0);
         DATA_OUT: out std_logic_vector(31 downto 0));
end mix_columns;

architecture arch of mix_columns is
-- Rijndael mix columns matrix
-- [ r0 ]      [ 2   3   1   1 ] [ a0 ] 
-- [ r1 ]  =   [ 1   2   3   1 ] [ a1 ]
-- [ r2 ]      [ 1   1   2   3 ] [ a2 ]
-- [ r3 ]      [ 3   1   1   2 ] [ a3 ]
--
-- Note: addition -> XOR
-- r0 = 2a0 + a3 + a2 + 3a1
-- r1 = 2a1 + a0 + a3 + 3a2
-- r2 = 2a2 + a1 + a0 + 3a3
-- r3 = 2a3 + a2 + a1 + 3a0 
type arr is array(3 downto 0) of std_logic_vector(7 downto 0);       
signal a : arr;
signal b : arr;
signal r : arr;

begin
        a(0) <= DATA_IN(31 downto 24); --db
        a(1) <= DATA_IN(23 downto 16); --13
        a(2) <= DATA_IN(15 downto 8);  --53
        a(3) <= DATA_IN(7 downto 0);   --45
        
        b(0) <= std_logic_vector(unsigned(a(0)) sll 1);
        b(1) <= std_logic_vector(unsigned(a(1)) sll 1);
        b(2) <= std_logic_vector(unsigned(a(2)) sll 1);
        b(3) <= std_logic_vector(unsigned(a(3)) sll 1);  
              
        r(0) <= b(0) XOR a(3) XOR a(2) XOR b(1) XOR a(1); --8e
        r(1) <= b(1) XOR a(0) XOR a(3) XOR b(2) XOR a(2); --4d
        r(2) <= b(2) XOR a(1) XOR a(0) XOR b(3) XOR a(3); --a1 
        r(3) <= b(3) XOR a(2) XOR a(1) XOR b(0) XOR a(0); --bc
        
        DATA_OUT <= r(0) & r(1) & r(2) & r(3);
        
end arch;