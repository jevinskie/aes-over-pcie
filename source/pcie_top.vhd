-- File name:   pcie_top.vhd
-- Created:     2009-04-13
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: PCIe top level

use work.pcie.all;
use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pcie_top is
   
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
   
end entity pcie_top;


architecture structural of pcie_top is
   
   signal state_d, state_q    : state_type;
   signal subblock            : subblock_type;
   signal i                   : g_index;
   signal num_shifts          : index;
   signal filtered            : slice;
   signal round_num           : round_type;
	signal round_key				: key_type;
	signal enc_key					: key_type;
   signal sub_bytes_out       : byte;
   signal shift_rows_out      : row;
   signal mix_columns_out     : col;
   signal add_round_key_out   : byte;
   signal load_out            : byte;
   signal filtered_key        : byte;
   signal start_key           : std_logic;
   signal key_done            : std_logic;
   signal sbox_lookup         : byte;
   
begin
   
   
end architecture structural;
