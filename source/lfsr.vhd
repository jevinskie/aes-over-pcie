
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr is
   port (
      clk : in std_logic;
      clr : in std_logic;
      count : out unsigned(3 downto 0);
      top   : out std_logic
   );
end lfsr;

architecture behav of lfsr is
   signal cnt, next_cnt : unsigned(3 downto 0);
   signal near : std_logic;
begin
   
   process(clk)
   begin
      if (rising_edge(clk)) then
         cnt <= next_cnt;
      end if;
   end process;

   process(cnt, clr, near)
   begin
      if (clr='1') then
         next_cnt <= (others => '1');
      else
         -- next_cnt <= cnt rol 1;
         --next_cnt(3) <= cnt(2) xor cnt(0) xor near;
         --next_cnt(2) <= cnt(1) xor cnt(0);
         next_cnt <= cnt ror 1;
         next_cnt(3) <= cnt(3) xor cnt(0) xor near;
      end if;
   end process;
   
   near <= '1' when (cnt(3)='0' and cnt(2)='0' and cnt(1)='0') else '0';
   
   count <= cnt;
   
   top <= '1' when cnt = x"e" else '0';
   
end behav;

