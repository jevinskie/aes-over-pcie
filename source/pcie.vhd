-- File name:   pcie.vhd
-- Created:     2009-04-13
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: PCIe package

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pcie is
   
   
   attribute enum_encoding: STRING;
   
   subtype dword is unsigned(31 downto 0);
   subtype word is unsigned(15 downto 0);
   subtype seq_number_type is unsigned(11 downto 0);
   
   type rx_status_type is (
      rx_data_ok, skp_add, skp_rem, rx_detect, eight_ten_error,
      elastic_buf_over, elastic_buf_under, rx_disparity_error
   );
   attribute enum_encoding of rx_status_type : type is
      "000 001 010 011 100 101 110 111";
   
   type power_down_type is (p0, p0s, p1, p2);
   attribute enum_encoding of power_down_type : type is
      "00 01 10 11";
   
   type symbol_type is (idl);
   attribute enum_encoding of symbol_type : type is
      "01111100";
   
end pcie;

package body pcie is
end pcie;
