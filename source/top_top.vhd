-- File name:   aes_top.vhd
-- Created:     2009-04-04
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: AES top level

use work.aes.all;
use work.pcie.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_top is
   
   port (
      clk            : in std_logic;
      nrst           : in std_logic;
      rx_data        : in byte;
      rx_data_k      : in std_logic;
      rx_status      : in rx_status_type;
      rx_elec_idle   : in std_logic;
      phy_status     : in std_logic;
      rx_valid       : in std_logic;
      tx_detect_rx   : out std_logic;
      tx_elec_idle   : out std_logic;
      tx_comp        : out std_logic;
      rx_pol         : out std_logic;
      power_down     : out power_down_type;
      tx_data        : out byte;
      tx_data_k      : out std_logic
   );
   
end entity top_top;


architecture structural of top_top is
   
   signal got_key : std_logic;
   signal got_pt  : std_logic;
   signal send_ct : std_logic;
   signal aes_done   : std_logic;
   signal tx_data_aes : byte;
   
begin
   
   
   pcie_top_b : entity work.pcie_top(structural) port map (
      clk => clk, nrst => nrst, rx_data => rx_data,
      rx_data_k => rx_data_k, rx_status => rx_status,
      rx_elec_idle => rx_elec_idle, phy_status => phy_status,
      rx_valid => rx_valid, tx_detect_rx => tx_detect_rx,
      tx_elec_idle => tx_elec_idle, tx_comp => tx_comp,
      rx_pol => rx_pol, power_down => power_down,
      tx_data => tx_data, tx_data_k => tx_data_k,
      tx_data_aes => tx_data_aes, aes_done => aes_done,
      got_key => got_key, got_pt => got_pt, send_ct => send_ct
   );
   
   
	aes_top_b : entity work.aes_top(structural) port map (
		clk => clk, nrst => nrst, rx_data => rx_data,
      got_key => got_key, got_pt => got_pt, send_ct => send_ct,
      aes_done => aes_done, tx_data => tx_data_aes
   );
	
	
end architecture structural;
