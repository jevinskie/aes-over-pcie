
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cntr is
   port (
      clk : in std_logic;
      clr   : in std_logic;
      count : out unsigned(3 downto 0);
      top   : out std_logic
   );
end cntr;

architecture behav of cntr is
   signal cnt, next_cnt : unsigned(3 downto 0);
begin
   
   process(clk)
   begin
      if (rising_edge(clk)) then
         cnt <= next_cnt;
      end if;
   end process;

   process(cnt, clr)
   begin
      if (clr='1') then
         next_cnt <= (others => '0');
      else
         next_cnt <= cnt + "1";
      end if;
   end process;
   
   count <= cnt;
   
   top <= '1' when cnt = x"f" else '0';
   
end behav;

