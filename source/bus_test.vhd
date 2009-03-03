-- File name:   bus_test.vhd
-- Created:     2009-02-25
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: block for testing bus stuff

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bus_test is
   port (
      clk   : in std_logic;
      nrst  : in std_logic;
      b     : out unsigned(7 downto 0)
   );
end bus_test;

architecture behavioral of bus_test is
   signal n : unsigned(2 downto 0);
begin
   
   process(clk, nrst)
   begin
      if (nrst='0') then
         n <= (others => '0');
      elsif (rising_edge(clk)) then
         n <= n + 1;
      end if;
   end process;
   
   process(n)
   begin
      case n is
         when "001" =>  b <= to_unsigned(2, 8);
         when others => b <= (others => 'Z');
      end case;
   end process;
   
   process(n)
   begin
      case n is
         when "011" =>  b <= to_unsigned(4, 8);
         when others => b <= (others => 'Z');
      end case;
   end process;
   
   process(n)
   begin
      case n is
         when "001" =>  b <= (others => 'Z');
         when "011" =>  b <= (others => 'Z');
         when others => b <= to_unsigned(7, 8);
      end case;
   end process;
   
end behavioral;

