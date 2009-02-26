
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_test is
end tb_test;

architecture test of tb_test is
   signal clk : std_logic := '0';
   signal clr : std_logic := '1';
   signal bcnt, lcnt : unsigned(3 downto 0);
   signal btop, ltop : std_logic;
   
   component cntr is
   port (
      clk : in std_logic;
      clr   : in std_logic;
      count : out unsigned(3 downto 0);
      top   : out std_logic
      );
   end component;

   component lfsr is
   port (
      clk : in std_logic;
      clr   : in std_logic;
      count : out unsigned(3 downto 0);
      top   : out std_logic
   );
   end component;

begin

   bcntr : cntr port map (
      clk => clk, clr => clr, count => bcnt, top => btop);
   lcntr : lfsr port map (
      clk => clk, clr => clr, count => lcnt, top => ltop);

   clk <= not clk after 5 ns;

   process
   begin
      wait for 20 ns;
      clr <= '1';
      wait for 10 ns;
      clr <= '0';
      wait;
   end process;
end test;

