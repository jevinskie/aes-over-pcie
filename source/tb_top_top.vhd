-- File name:   tb_top_top.vhd
-- Created:     2009-04-24
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: The one test bench to rule them all

use work.pcie.all;
use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top_top is
   generic (
      clk_per  : time := 10 ns
   );
end tb_top_top;

architecture test of tb_top_top is
   
   -- dut signals
   signal clk           : std_logic := '0';
   signal nrst          : std_logic := '1';
   signal rx_data       : byte      := x"7C"; -- IDL
   signal rx_data_k     : std_logic := '1'; -- control byte
   signal rx_status     : rx_status_type := rx_data_ok;
   signal rx_elec_idle  : std_logic := '0';
   signal phy_status    : std_logic := '0';
   signal rx_valid      : std_logic := '1';
   signal tx_detect_rx  : std_logic;
   signal tx_elec_idle  : std_logic;
   signal tx_comp       : std_logic;
   signal rx_pol        : std_logic;
   signal power_down    : power_down_type;
   signal tx_data       : byte;
   signal tx_data_k     : std_logic;

   
   -- clock only runs when stop isnt asserted
   signal stop          : std_logic := '1';
   signal test_num      : natural := 0;
   
   type packet is array (natural range <>) of byte;
   
   constant norm : packet := (x"80", x"55", x"AA");
   constant bad_sync : packet := (x"FE", x"12", x"34");
   constant just_sync : packet := (0 => x"80");
   constant lots : packet := (x"80", x"DE", x"AD",
      x"BE", x"EF", x"B0", x"0B", x"F0", x"0D");
   constant mean : packet := (x"80", x"FF", x"FF",
      x"FF", x"FF", x"FF", x"FF", x"FF", x"80");
   
   -- reset the device
   procedure reset (
      signal nrst : out std_logic
   ) is
   begin
      nrst <= '0';
      wait for clk_per;
      nrst <= '1';
   end procedure reset;
   
   
   -- write out an EOP
   procedure send_eop (
      constant bits     : positive;
      constant baud     : time;
      signal d_plus     : out std_logic;
      signal d_minus    : out std_logic
   ) is
   begin
      for i in 1 to bits loop
         d_plus  <= '0';
         d_minus <= '0';
         wait for baud;
         d_plus  <= '1';
      end loop;
      wait for baud;
   end procedure;
   
   
   -- send a packet
   procedure tx_packet (
      constant p        : packet;
      constant do_eop   : boolean;
      constant eop_len  : positive;
      constant baud     : time;
      signal d_plus     : inout std_logic;
      signal d_minus    : inout std_logic
   ) is
      variable enc      : byte;
   begin
      
      for i in p'range loop
         -- send out the bits LSB first
         for j in enc'reverse_range loop
            d_plus  <= enc(j);
            d_minus <= not enc(j);
            wait for baud;
         end loop;
      end loop;
      
      -- send out EOP if requested
      if (do_eop) then
         send_eop(eop_len, baud, d_plus, d_minus);
      end if;
      
   end procedure tx_packet;
   
   
begin
   
   dut : entity work.top_top(structural) port map (
      clk => clk, nrst => nrst,
      rx_data => rx_data, rx_data_k => rx_data_k,
      rx_status => rx_status, rx_elec_idle => rx_elec_idle,
      phy_status => phy_status, rx_valid => rx_valid,
      tx_detect_rx => tx_detect_rx, tx_elec_idle => tx_elec_idle,
      tx_comp => tx_comp, rx_pol => rx_pol,
      power_down => power_down, tx_data => tx_data,
      tx_data_k => tx_data_k
   );
   
   
-- main test bench code
   
   -- clock when stop isnt asserted
   clk <= not clk and not stop after clk_per/2;
   
process
begin
   wait for clk_per*5;
   
   -- start the clock
   stop <= '0';

   -- reset the device
   reset(nrst);
   
   wait for clk_per*10;
   
   --################################################################
   
   
   --################################################################
   report "done with tests";
   
   wait for clk_per*10;
   
   -- stop the clock
   stop <= '1';
   
   wait for clk_per*5;
   
   wait;
end process;

end test;

