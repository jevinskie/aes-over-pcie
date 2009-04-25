-- File name:   tb_top_top.vhd
-- Created:     2009-04-24
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: The one test bench to rule them all

use work.pcie.all;
use work.aes.all;
use work.numeric_std_textio.all;
use work.aes_textio.all;

use std.textio.all;

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
   signal rx_status     : std_logic_vector(2 downto 0) := "000";
   signal rx_elec_idle  : std_logic := '0';
   signal phy_status    : std_logic := '0';
   signal rx_valid      : std_logic := '1';
   signal tx_detect_rx  : std_logic;
   signal tx_elec_idle  : std_logic;
   signal tx_comp       : std_logic;
   signal rx_pol        : std_logic;
   signal power_down    : std_logic_vector(1 downto 0);
   signal tx_data       : byte;
   signal tx_data_k     : std_logic;
   
   
   -- clock only runs when stop isnt asserted
   signal stop          : std_logic := '1';
   signal test_num      : natural := 0;
   
   -- reset the device
   procedure reset (
      signal nrst : out std_logic
   ) is
   begin
      nrst <= '0';
      wait for clk_per;
      nrst <= '1';
   end procedure reset;
   
   
   procedure tx_dllp_packet (
      constant dllp_type : byte;
      constant seq      : seq_number_type;
      signal rx_data    : inout byte;
      signal rx_data_k  : inout std_logic
   ) is
      variable last_rx_data   : byte;
      variable last_rx_data_k : std_logic;
      variable crc            : word := x"FFFF";
   begin
      last_rx_data := rx_data;
      last_rx_data_k := rx_data_k;
      rx_data <= x"5C"; -- SDP
      rx_data_k <= '1';
      wait for clk_per;
      rx_data <= dllp_type;
      crc := crc_gen(rx_data, crc);
      rx_data_k <= '0';
      wait for clk_per;
      rx_data <= x"00";
      crc := crc_gen(rx_data, crc);
      wait for clk_per;
      rx_data <= x"0" & seq(11 downto 8);
      crc := crc_gen(rx_data, crc);
      wait for clk_per;
      rx_data <= seq(7 downto 0);
      crc := crc_gen(rx_data, crc);
      wait for clk_per;
      rx_data <= crc(15 downto 8);
      wait for clk_per;
      rx_data <= crc(7 downto 0);
      wait for clk_per;
      rx_data <= x"FD"; -- END
      rx_data_k <= '1';
      wait for clk_per;
      rx_data <= last_rx_data;
      rx_data_k <= last_rx_data_k;
   end procedure tx_dllp_packet;
   
   procedure tx_tlp_packet (
      constant dllp_type   : byte;
      constant dllp_seq    : seq_number_type;
      constant tlp_seq     : seq_number_type;
      constant tlp_type    : byte;
      constant length      : word;
      constant requester_id   : word;
      constant tag         : byte;
      constant byte_en     : byte;
      constant addr        : dword;
      constant payload     : state_type;
      constant send_payload : boolean;
      signal rx_data       : inout byte;
      signal rx_data_k     : inout std_logic
   ) is
      variable last_rx_data   : byte;
      variable last_rx_data_k : std_logic;
      variable crc            : word := x"FFFF";
      variable lcrc           : dword := x"FFFFFFFF";
   begin
      last_rx_data := rx_data;
      last_rx_data_k := rx_data_k;
      rx_data <= x"FB"; -- STP
      rx_data_k <= '1';
      wait for clk_per;
      rx_data <= dllp_type;
      crc := crc_gen(rx_data, crc);
      rx_data_k <= '0';
      wait for clk_per;
      rx_data <= x"00";
      crc := crc_gen(rx_data, crc);
      wait for clk_per;
      rx_data <= x"0" & dllp_seq(11 downto 8);
      crc := crc_gen(rx_data, crc);
      wait for clk_per;
      rx_data <= dllp_seq(7 downto 0);
      crc := crc_gen(rx_data, crc);
      wait for clk_per;
      rx_data <= crc(15 downto 8);
      wait for clk_per;
      rx_data <= crc(7 downto 0);
      wait for clk_per;
      -- start of tlp
      rx_data <= x"0" & tlp_seq(11 downto 8);
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      rx_data <= tlp_seq(7 downto 0);
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      rx_data <= tlp_type;
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      rx_data <= x"00";
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      rx_data <= length(15 downto 8);
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      rx_data <= length(7 downto 0);
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      rx_data <= requester_id(15 downto 8);
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      rx_data <= requester_id(7 downto 0);
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      rx_data <= tag;
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      rx_data <= byte_en;
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      rx_data <= addr(31 downto 24);
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      rx_data <= addr(23 downto 16);
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      rx_data <= addr(15 downto 8);
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      rx_data <= addr(7 downto 0);
      lcrc := lcrc_gen(rx_data, lcrc);
      wait for clk_per;
      if send_payload then
         for i in index loop
            for j in index loop
               rx_data <= payload(j, i);
               lcrc := lcrc_gen(rx_data, lcrc);
               wait for clk_per;
            end loop;
         end loop;
      end if;
      rx_data <= lcrc(31 downto 24);
      wait for clk_per;
      rx_data <= lcrc(23 downto 16);
      wait for clk_per;
      rx_data <= lcrc(15 downto 8);
      wait for clk_per;
      rx_data <= lcrc(7 downto 0);
      wait for clk_per;
      
      rx_data <= x"FD"; -- END
      rx_data_k <= '1';
      wait for clk_per;
      rx_data <= last_rx_data;
      rx_data_k <= last_rx_data_k;
   end procedure tx_tlp_packet;
   
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
   
   file data : text open read_mode is "test_vectors/tb_aes_top.dat";
   variable sample         : line;
   variable gold_enc_key   : key_type;
   variable gold_pt        : state_type;
   variable gold_ct        : state_type;
   variable seq_num        : seq_number_type := (others => '0');
   
begin
   wait for clk_per*5;
   
   -- start the clock
   stop <= '0';

   -- reset the device
   reset(nrst);
   
   wait for clk_per*10;
   
   --################################################################
   
   -- leda DCVHDL_165 off
   while not endfile(data) loop
      readline(data, sample);
      hread(sample, gold_enc_key);
      hread(sample, gold_pt);
      hread(sample, gold_ct);
      
      tx_tlp_packet(x"00", seq_num, seq_num, x"40", x"0004",
         x"0000", x"00", x"FF", x"00001000", gold_enc_key,
         true, rx_data, rx_data_k);
      wait for clk_per*10;
      tx_tlp_packet(x"00", seq_num, seq_num, x"40", x"0004",
         x"0000", x"00", x"FF", x"00002000", gold_pt,
         true, rx_data, rx_data_k);
      wait for clk_per*1000;
      
   end loop;
   -- leda DCVHDL_165 on

   
   --################################################################
   report "done with tests";
   
   wait for clk_per*10;
   
   -- stop the clock
   stop <= '1';
   
   wait for clk_per*5;
   
   wait;
end process;

end test;

