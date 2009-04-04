
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
   signal near,near2 : std_logic;
   signal g, next_g : unsigned(3 downto 0);
begin
   
   process(clk)
   begin
      if (rising_edge(clk)) then
         cnt <= next_cnt;
         g <= next_g;
      end if;
   end process;

   process(cnt, clr, near, g)
   begin
      if (clr='1') then
         next_cnt <= (others => '1');
         next_g <= (others => '1');
      else
         -- next_cnt <= cnt rol 1;
         --next_cnt(3) <= cnt(2) xor cnt(0) xor near;
         --next_cnt(2) <= cnt(1) xor cnt(0);
         next_cnt <= cnt ror 1;
         next_cnt(3) <= cnt(3) xor cnt(0) xor near;
         
         next_g(3) <= g(0);
         next_g(2) <= g(0) xor g(3);
         next_g(1 downto 0) <= g(2 downto 1);
         
      end if;
   end process;
   
   near <= '1' when (cnt(3)='0' and cnt(2)='0' and cnt(1)='0') else '0';
   near2 <= '1' when (g(3)='0' and g(2)='0' and g(1)='0') else '0';
   
   count <= cnt;
   
   top <= '1' when cnt = x"e" else '0';
   
end behav;

