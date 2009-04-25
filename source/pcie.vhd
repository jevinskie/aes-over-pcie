-- File name:   pcie.vhd
-- Created:     2009-04-13
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: PCIe package

use work.aes.all;

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
   --attribute enum_encoding of rx_status_type : type is
   --   "000 001 010 011 100 101 110 111";
   
   type power_down_type is (p0, p0s, p1, p2);
   --attribute enum_encoding of power_down_type : type is
   --   "00 01 10 11";
   
   type symbol_type is (idl);
   --attribute enum_encoding of symbol_type : type is
   --   "01111100";
   
   function crc_gen(data : byte; crc : word) return word;
   function lcrc_gen(data : byte; lcrc : dword) return dword;
   
end pcie;

package body pcie is
   
   
   function crc_gen (
      data  : byte;
      crc   : word
   ) return word is
      
      variable d        : byte;
      variable c        : word;
      variable newcrc   : word;
      
   begin
      
      d := data;
      c := crc;
      
      newcrc(0) := d(6) xor d(3) xor d(0) xor c(8) xor c(11) xor c(14);
      newcrc(1) := d(7) xor d(6) xor d(4) xor d(3) xor d(1) xor d(0) xor c(8) xor c(9) xor c(11) xor c(12) xor c(14) xor c(15);
      newcrc(2) := d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor d(0) xor c(8) xor c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15);
      newcrc(3) := d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15);
      newcrc(4) := d(7) xor d(5) xor d(4) xor d(2) xor d(0) xor c(8) xor c(10) xor c(12) xor c(13) xor c(15);
      newcrc(5) := d(6) xor d(5) xor d(3) xor d(1) xor c(9) xor c(11) xor c(13) xor c(14);
      newcrc(6) := d(7) xor d(6) xor d(4) xor d(2) xor c(10) xor c(12) xor c(14) xor c(15);
      newcrc(7) := d(7) xor d(5) xor d(3) xor c(11) xor c(13) xor c(15);
      newcrc(8) := d(6) xor d(4) xor c(0) xor c(12) xor c(14);
      newcrc(9) := d(7) xor d(5) xor c(1) xor c(13) xor c(15);
      newcrc(10) := d(6) xor c(2) xor c(14);
      newcrc(11) := d(7) xor c(3) xor c(15);
      newcrc(12) := c(4);
      newcrc(13) := d(6) xor d(3) xor d(0) xor c(5) xor c(8) xor c(11) xor c(14);
      newcrc(14) := d(7) xor d(4) xor d(1) xor c(6) xor c(9) xor c(12) xor c(15);
      newcrc(15) := d(5) xor d(2) xor c(7) xor c(10) xor c(13);
      
      return newcrc;
   end crc_gen;
   
   
   function lcrc_gen (
      data  : byte;
      lcrc   : dword
   ) return dword is
      
      variable d        : byte;
      variable c        : dword;
      variable newcrc   : dword;
      
   begin
      
      d := data;
      c := lcrc;
      
      newcrc(0) := d(6) xor d(0) xor c(24) xor c(30);
      newcrc(1) := d(7) xor d(6) xor d(1) xor d(0) xor c(24) xor c(25) xor c(30) xor c(31);
      newcrc(2) := d(7) xor d(6) xor d(2) xor d(1) xor d(0) xor c(24) xor c(25) xor c(26) xor c(30) xor c(31);
      newcrc(3) := d(7) xor d(3) xor d(2) xor d(1) xor c(25) xor c(26) xor c(27) xor c(31);
      newcrc(4) := d(6) xor d(4) xor d(3) xor d(2) xor d(0) xor c(24) xor c(26) xor c(27) xor c(28) xor c(30);
      newcrc(5) := d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(1) xor d(0) xor c(24) xor c(25) xor c(27) xor c(28) xor c(29) xor c(30) xor c(31);
      newcrc(6) := d(7) xor d(6) xor d(5) xor d(4) xor d(2) xor d(1) xor c(25) xor c(26) xor c(28) xor c(29) xor c(30) xor c(31);
      newcrc(7) := d(7) xor d(5) xor d(3) xor d(2) xor d(0) xor c(24) xor c(26) xor c(27) xor c(29) xor c(31);
      newcrc(8) := d(4) xor d(3) xor d(1) xor d(0) xor c(0) xor c(24) xor c(25) xor c(27) xor c(28);
      newcrc(9) := d(5) xor d(4) xor d(2) xor d(1) xor c(1) xor c(25) xor c(26) xor c(28) xor c(29);
      newcrc(10) := d(5) xor d(3) xor d(2) xor d(0) xor c(2) xor c(24) xor c(26) xor c(27) xor c(29);
      newcrc(11) := d(4) xor d(3) xor d(1) xor d(0) xor c(3) xor c(24) xor c(25) xor c(27) xor c(28);
      newcrc(12) := d(6) xor d(5) xor d(4) xor d(2) xor d(1) xor d(0) xor c(4) xor c(24) xor c(25) xor c(26) xor c(28) xor c(29) xor c(30);
      newcrc(13) := d(7) xor d(6) xor d(5) xor d(3) xor d(2) xor d(1) xor c(5) xor c(25) xor c(26) xor c(27) xor c(29) xor c(30) xor c(31);
      newcrc(14) := d(7) xor d(6) xor d(4) xor d(3) xor d(2) xor c(6) xor c(26) xor c(27) xor c(28) xor c(30) xor c(31);
      newcrc(15) := d(7) xor d(5) xor d(4) xor d(3) xor c(7) xor c(27) xor c(28) xor c(29) xor c(31);
      newcrc(16) := d(5) xor d(4) xor d(0) xor c(8) xor c(24) xor c(28) xor c(29);
      newcrc(17) := d(6) xor d(5) xor d(1) xor c(9) xor c(25) xor c(29) xor c(30);
      newcrc(18) := d(7) xor d(6) xor d(2) xor c(10) xor c(26) xor c(30) xor c(31);
      newcrc(19) := d(7) xor d(3) xor c(11) xor c(27) xor c(31);
      newcrc(20) := d(4) xor c(12) xor c(28);
      newcrc(21) := d(5) xor c(13) xor c(29);
      newcrc(22) := d(0) xor c(14) xor c(24);
      newcrc(23) := d(6) xor d(1) xor d(0) xor c(15) xor c(24) xor c(25) xor c(30);
      newcrc(24) := d(7) xor d(2) xor d(1) xor c(16) xor c(25) xor c(26) xor c(31);
      newcrc(25) := d(3) xor d(2) xor c(17) xor c(26) xor c(27);
      newcrc(26) := d(6) xor d(4) xor d(3) xor d(0) xor c(18) xor c(24) xor c(27) xor c(28) xor c(30);
      newcrc(27) := d(7) xor d(5) xor d(4) xor d(1) xor c(19) xor c(25) xor c(28) xor c(29) xor c(31);
      newcrc(28) := d(6) xor d(5) xor d(2) xor c(20) xor c(26) xor c(29) xor c(30);
      newcrc(29) := d(7) xor d(6) xor d(3) xor c(21) xor c(27) xor c(30) xor c(31);
      newcrc(30) := d(7) xor d(4) xor c(22) xor c(28) xor c(31);
      newcrc(31) := d(5) xor c(23) xor c(29);
      
      return newcrc;
   end lcrc_gen;
   
   
end pcie;

