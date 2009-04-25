use work.aes.all;
use work.pcie.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bridge is
   port (
      clk : in std_logic;
      nrst : in std_logic;
      rx_data : in byte;
      tx_data_aes : in byte;
      rx_data_k : in std_logic;
      aes_done : in std_logic;
      tx_data: out byte;
      tx_data_k : out std_logic;
      got_key : out std_logic;
      got_pt : out std_logic;
      send_ct : out std_logic     
   );
end entity bridge;

architecture behavioral of bridge is
    type state_type is (read_special_end, send_byte_count_lo, send_dummy_2, read_dummy_2, send_tag, send_crc_lo, send_dummy_1, send_tlp_type, read_requester_id_hi, send_lcrc_lo_hi, send_completer_id_lo, send_lcrc_hi_lo, read_addr_hi_hi, read_crc_hi, read_addr_lo_lo, send_dllp_seq_num_lo, read_dllp_seq_num_hi, read_dllp_seq_num_lo, read_addr_hi_lo, e_idle, send_crc_hi, read_lcrc_hi_hi, send_lcrc_hi_hi, read_lcrc_lo_hi, read_requestor_id_lo, read_byte_enables, read_addr_lo_hi, send_lcrc_lo_lo, read_length_hi, send_dllp_type, idle, send_requester_id_lo, read_crc_lo, read_lcrc_lo_lo, send_dllp_seq_num_hi, read_tlp_type, send_addr_lo_lo, read_dllp_type, read_dummy_1, read_tag, send_payload, read_tlp_seq_num_lo, send_tlp_length_hi, load_payload, read_lcrc_hi_lo, read_tlp_seq_num_hi, send_requester_id_hi, send_completer_id_hi, read_length_lo, send_byte_count_hi, send_tlp_seq_num_lo, send_tlp_seq_num_hi, send_tlp_length_lo, read_special_char, send_special_char, send_special_end);
   signal state, next_state : state_type;
   signal dllp_seq_num, next_dllp_seq_num : seq_number_type;
   signal tlp_seq_num, next_tlp_seq_num : seq_number_type;
   signal tlp_type, next_tlp_type : byte;
   signal tag, next_tag : byte;
   signal addr, next_addr : dword;
   signal i, next_i                       : g_index;
   signal i_up, i_clr                     : std_logic;
   signal crc, next_crc : word;
   signal lcrc, next_lcrc : dword;
   signal send_completion, send_completion_clr : std_logic;
   signal crc_clr, crc_calc : std_logic;
   signal lcrc_clr, lcrc_calc : std_logic;
   signal rxing : std_logic;  
   signal tx_data_int : byte;
   signal our_crc, next_our_crc : word;
   signal our_lcrc, next_our_lcrc : dword;
   signal ack_dec, next_ack_dec : std_logic;
   signal ack, ack_set :std_logic;
   signal last_rx_data : byte;
   
   
   
begin
   
   
   state_reg : process (clk, nrst)
   begin
      -- on reset, the RCU goes to the IDLE state, otherwise it goes
      -- to the next state.
      if (nrst = '0') then
         state <= IDLE;
      elsif (rising_edge(clk)) then
         state <= next_state;
      end if;
   end process state_reg;
   
   -- leda C_1406 off
   i_reg : process(clk)
   begin
      if rising_edge(clk) then
         i <= next_i;
      end if;
   end process i_reg;
   -- leda C_1406 on
   
   i_nsl : process(i, i_up, i_clr)
   begin
      if (i_clr = '1') then
         next_i <= 0;
      elsif (i_up = '1') then
         next_i <= to_integer(to_unsigned(i, 4) + 1);
      else
         next_i <= i;
      end if;
   end process i_nsl;

   crc_nsl: process(crc_clr, crc_calc, our_crc, rxing, last_rx_data, tx_data_int)
   begin
      if (crc_clr = '1') then
         next_our_crc <= (others => '1');
      elsif (crc_calc = '1') then
         if (rxing = '1') then
            next_our_crc <= crc_gen(last_rx_data, our_crc);
         else
            next_our_crc <= crc_gen(tx_data_int, our_crc);
         end if;
      else
         next_our_crc <= our_crc;
      end if;
   end process crc_nsl;

   lcrc_nsl: process(lcrc_clr, lcrc_calc, our_lcrc, rxing, last_rx_data, tx_data_int)
   begin
      if (lcrc_clr = '1') then        
         next_our_lcrc <= (others => '1');
      elsif (lcrc_calc = '1') then
         if (rxing = '1') then
            next_our_lcrc <= lcrc_gen(last_rx_data, our_lcrc);
         else
            next_our_lcrc <= lcrc_gen(tx_data_int, our_lcrc);
         end if;
      else
         next_our_lcrc <= our_lcrc;
      end if;
   end process lcrc_nsl;
   
   
   -- leda C_1406 off
   register_party : process(clk)
   begin
      if rising_edge(clk) then
         dllp_seq_num <= next_dllp_seq_num;
         tlp_seq_num <= next_tlp_seq_num;
         tlp_type <= next_tlp_type;
         tag <= next_tag;
         addr <= next_addr;
         crc <= next_crc;
         our_crc <= next_our_crc;
         lcrc <= next_lcrc;
         our_lcrc <= next_our_lcrc;
         ack_dec <= next_ack_dec;
         last_rx_data <= rx_data;
      end if;
   end process register_party;
   -- leda C_1406 off
   
   ack_dec_nsl: process(ack_dec, ack_set, ack)     
   begin
      if (ack_set = '1') then
         next_ack_dec <= ack;
      else 
         next_ack_dec <= ack_dec;
      end if;
   end process ack_dec_nsl;        
   
   completion_reg: process(clk, nrst, aes_done, tlp_type, send_completion_clr)
   begin
      if (nrst = '0') then
	      send_completion <= '0';
      elsif rising_edge(clk) then 
	      if (aes_done = '1') then
            send_completion <= '1';
         elsif (send_completion_clr = '1') then
            send_completion <= '0';
         else
            send_completion <= send_completion;
         end if;
      end if;
   end process completion_reg;

   rcu_nsl : process(state, rx_data_k, rx_data, last_rx_data, send_completion, addr, i, tlp_type)
   begin
      next_state <= e_idle;
      case state is
         when idle =>
            if (rx_data /= x"7C") then 
	            next_state <= read_special_char;
	         elsif (send_completion = '1' and tlp_type = x"00") then
	            next_state <= send_special_char;
	         else
	            next_state <= idle;
	         end if;
         when read_special_char =>
            if (last_rx_data = x"FB" or last_rx_data = x"5C") then
               next_state <= read_dllp_type;
            else
               next_state <= e_idle;
            end if;
         when send_special_char =>
            next_state <= send_dllp_type;
         when send_special_end =>
            next_state <= idle;
         when read_dllp_type =>
            next_state <= read_dummy_1;
         when read_dummy_1 =>
            next_state <= read_dllp_seq_num_hi;
         when read_dllp_seq_num_hi =>
            next_state <= read_dllp_seq_num_lo;
         when read_dllp_seq_num_lo =>
            next_state <= read_crc_hi;
         when read_crc_hi =>
            next_state <= read_crc_lo;
         when read_crc_lo =>
            -- done reading dllp, going to lp
            next_state <= read_tlp_seq_num_hi;
         when read_tlp_seq_num_hi =>
            next_state <= read_tlp_seq_num_lo;
         when read_tlp_seq_num_lo =>
            -- done reading lp, going to tlp
            next_state <= read_tlp_type;
         when read_tlp_type =>
            next_state <= read_dummy_2;
         when read_dummy_2 =>
            next_state <= read_length_hi;
         when read_length_hi =>
            next_state <= read_length_lo;
         when read_length_lo =>
            next_state <= read_requester_id_hi;
         when read_requester_id_hi =>
            next_state <= read_requestor_id_lo;
         when read_requestor_id_lo =>
            next_state <= read_tag;
         when read_tag =>
            next_state <= read_byte_enables;
         when read_byte_enables =>
            next_state <= read_addr_hi_hi;
         when read_addr_hi_hi =>
            next_state <= read_addr_hi_lo;
         when read_addr_hi_lo =>
            next_state <= read_addr_lo_hi;
         when read_addr_lo_hi =>
            next_state <= read_addr_lo_lo;
         when read_addr_lo_lo =>
            if (addr(31 downto 8) & last_rx_data = x"00001000") then
               next_state <= load_payload;
            elsif (addr(31 downto 8) & last_rx_data = x"00002000") then
               next_state <= load_payload;
            elsif (addr(31 downto 8) & last_rx_data = x"00003000") then
               next_state <= read_lcrc_hi_hi;
            else
               next_state <= e_idle;
            end if;
         when load_payload =>
            if (i /= 15) then
               next_state <= load_payload;
            else
               next_state <= read_lcrc_hi_hi;
            end if;
         when read_lcrc_hi_hi =>
            next_state <= read_lcrc_hi_lo;
         when read_lcrc_hi_lo =>
            next_state <= read_lcrc_lo_hi;
         when read_lcrc_lo_hi =>
            next_state <= read_lcrc_lo_lo;
         when read_lcrc_lo_lo =>
            next_state <= read_special_end;
         when send_dllp_type =>
            -- sends ack or nak
            next_state <= send_dummy_1;
         when send_dummy_1 =>
            next_state <= send_dllp_seq_num_hi;
         when send_dllp_seq_num_hi =>
            next_state <= send_dllp_seq_num_lo;
         when send_dllp_seq_num_lo =>
            next_state <= send_crc_hi;
         when send_crc_hi =>
            next_state <= send_crc_lo;
         when send_crc_lo =>
            -- either go to idle after an ack/nak or send the ct
            --if (tlp_type = "00001010") then  --type is CplD
            if (send_completion = '1') then
               next_state <= send_tlp_seq_num_hi;
            else
               next_state <= send_special_end;
            end if;
         when send_tlp_seq_num_hi =>
            next_state <= send_tlp_seq_num_lo;
         when send_tlp_seq_num_lo =>
            next_state <= send_tlp_type;
         when send_tlp_type =>
            next_state <= send_dummy_2;
         when send_dummy_2 =>
            next_state <= send_tlp_length_hi;
         when send_tlp_length_hi =>
            next_state <= send_tlp_length_lo;
         when send_tlp_length_lo =>
            next_state <= send_completer_id_hi;
         when send_completer_id_hi =>
            next_state <= send_completer_id_lo;
         when send_completer_id_lo =>
            next_state <= send_byte_count_hi;
         when send_byte_count_hi =>
            next_state <= send_byte_count_lo;
         when send_byte_count_lo =>
            next_state <= send_requester_id_hi;
         when send_requester_id_hi =>
            next_state <= send_requester_id_lo;
         when send_requester_id_lo =>
            next_state <= send_tag;
         when send_tag =>
            next_state <= send_addr_lo_lo;
         when send_addr_lo_lo =>
            next_state <= send_payload;
         when send_payload =>
            if (i /= 15) then
               next_state <= send_payload;
            else
               next_state <= send_lcrc_hi_hi;
            end if;
         when send_lcrc_hi_hi =>
            next_state <= send_lcrc_hi_lo;
         when send_lcrc_hi_lo =>
            next_state <= send_lcrc_lo_hi;
         when send_lcrc_lo_hi =>
            next_state <= send_lcrc_lo_lo;
         when send_lcrc_lo_lo =>
            next_state <= send_special_end;
         when read_special_end =>
            if (last_rx_data = x"FD") then
               next_state <= send_special_char;
            else
               next_state <= e_idle;
            end if;
         when others =>
            next_state <= e_idle;
      end case;
   end process rcu_nsl;
   
   bridge_output : process(state, addr, rx_data, tx_data_aes, dllp_seq_num, tlp_seq_num, tlp_type, tag, lcrc, crc, our_crc, ack_dec, last_rx_data, our_lcrc)
   begin
      tx_data_int <= x"7C"; -- idl
      tx_data_k <= '1'; -- control byte
      got_key <= '0';
      got_pt <= '0';
      send_ct <= '0';
      send_completion_clr <= '0';
      crc_clr <= '0';
      lcrc_clr <= '0';
      rxing <= '1';
      crc_calc <= '0';
      lcrc_calc <= '0';
      ack <= '0';
      ack_set <= '0';
      i_clr <= '1';
      i_up <= '0';
      
      next_dllp_seq_num <= dllp_seq_num;
      next_tlp_seq_num <= tlp_seq_num;
      next_tlp_type <= tlp_type;
      next_tag <= tag;
      next_addr <= addr;
      next_lcrc <= lcrc;
      next_crc <= crc;
      
      case state is
         when idle =>
            -- already logic idling
            crc_clr <= '1';
            lcrc_clr <= '1';
         when read_special_char =>
            -- nothing?
         when read_special_end =>
            crc_clr <= '1';
         when send_special_char =>
            tx_data_int <= x"FB";
            tx_data_k <= '1';
         when read_dllp_type =>
            crc_calc <= '1';
         when read_dummy_1 =>
            crc_calc <= '1';
         when read_addr_lo_lo =>
            lcrc_calc <= '1';
            next_addr(7 downto 0) <= last_rx_data;
            if (addr(31 downto 8) & last_rx_data = x"00001000") then
               got_key <= '1';
            elsif (addr(31 downto 8) & last_rx_data = x"00002000") then
               got_pt <= '1';
            end if;
         when send_addr_lo_lo =>
            tx_data_int <= "0" & addr(6 downto 0);
            tx_data_k <= '0';
            lcrc_calc <= '1';
            rxing <= '0';
            send_ct <= '1';
         when read_dllp_seq_num_hi =>
            next_dllp_seq_num(11 downto 8) <= last_rx_data(3 downto 0);
            crc_calc <= '1';
         when read_dllp_seq_num_lo =>
            next_dllp_seq_num(7 downto 0) <= last_rx_data;
            crc_calc <= '1';
         when read_tlp_seq_num_hi =>
            next_tlp_seq_num(11 downto 8) <= last_rx_data(3 downto 0);
         when read_tlp_seq_num_lo =>
            next_tlp_seq_num(7 downto 0) <= last_rx_data;
         when read_crc_hi => 
            next_crc(15 downto 8) <= last_rx_data;
         when read_crc_lo =>  --check vs our calculated CRC to determine ack or nak
            next_crc(7 downto 0) <= last_rx_data;
            ack_set <= '1';
            if (our_crc = crc(15 downto 8) & last_rx_data) then
               ack <= '1';
            else 
               ack <= '0';
            end if;
         when read_lcrc_hi_hi =>
            next_lcrc(31 downto 24) <= last_rx_data;
         when read_lcrc_hi_lo =>
            next_lcrc(23 downto 16) <= last_rx_data;
         when read_lcrc_lo_hi =>
            next_lcrc(15 downto 8) <= last_rx_data;
         when read_lcrc_lo_lo =>
            next_lcrc(7 downto 0) <= last_rx_data;
         when read_tlp_type =>
            lcrc_calc <= '1';  
            next_tlp_type <= last_rx_data;
         when read_length_hi =>
            lcrc_calc <= '1';
         when read_length_lo =>
            lcrc_calc <= '1';
         when read_tag =>
            lcrc_calc <= '1';
            next_tag <= last_rx_data;
         when read_addr_hi_hi =>
            lcrc_calc <= '1';
            next_addr(31 downto 24) <= last_rx_data;
         when read_addr_hi_lo =>
            lcrc_calc <= '1';
            next_addr(23 downto 16) <= last_rx_data;
         when read_addr_lo_hi =>
            lcrc_calc <= '1';
            next_addr(15 downto 8) <= last_rx_data;
         when load_payload =>
            lcrc_calc <= '1';
            i_clr <= '0';
            i_up <= '1';
         when read_dummy_2 =>
            lcrc_calc <= '1';
         when read_requester_id_hi =>
            lcrc_calc <= '1';
         when read_requestor_id_lo =>
            lcrc_calc <= '1'; 
         when read_byte_enables =>
            lcrc_calc <= '1';
         when send_lcrc_hi_hi =>
            tx_data_int<= our_lcrc(31 downto 24);
            tx_data_k <= '0';
         when send_lcrc_hi_lo =>
            tx_data_int<= our_lcrc(23 downto 16);
            tx_data_k <= '0';
         when send_lcrc_lo_hi =>
            tx_data_int<= our_lcrc(15 downto 8);
            tx_data_k <= '0';
         when send_lcrc_lo_lo =>
            tx_data_int <= our_lcrc(7 downto 0);
            tx_data_k <= '0';
       when send_payload =>
            i_up <= '1';
            i_clr <= '0';
            lcrc_calc <= '1';
            rxing <= '0';
          tx_data_int<= tx_data_aes;
          tx_data_k <= '0';
       when send_tag =>
            lcrc_calc <= '1';
            rxing <= '0';
          tx_data_int<= tag;
          tx_data_k <= '0';
       when send_dllp_type =>
            crc_calc <= '1';
            rxing <= '0';
            tx_data_int <= "000" & ack_dec & "0000";
            tx_data_k <= '0';
         when send_dummy_1 =>
            crc_calc <= '1';
            rxing <= '0';
          tx_data_int<= "00000000";
          tx_data_k <= '0';
         when send_dllp_seq_num_hi =>
            crc_calc <= '1';
            rxing <= '0';
          tx_data_int<= "0000" & dllp_seq_num(11 downto 8);
          tx_data_k <= '0';
         when send_dllp_seq_num_lo =>
            crc_calc <= '1';
            rxing <= '0';
          tx_data_int<= dllp_seq_num(7 downto 0);
          tx_data_k <= '0';
         when send_crc_hi =>
          tx_data_int<= our_crc(15 downto 8);
	         tx_data_k <= '0';
         when send_crc_lo =>
	         tx_data_int<= our_crc(7 downto 0);
	         tx_data_k <= '0';
         when send_tlp_seq_num_hi =>
            send_completion_clr <= '1';
            lcrc_calc <= '1';
            rxing <= '0';
	         tx_data_int<= "0000" & tlp_seq_num(11 downto 8);
	         tx_data_k <= '0';
         when send_tlp_seq_num_lo =>
            lcrc_calc <= '1';
            rxing <= '0';
	         tx_data_int<= tlp_seq_num(7 downto 0);
	         tx_data_k <= '0';
         when send_tlp_type =>
            lcrc_calc <= '1';
            rxing <= '0';
	         tx_data_int <= "00001010"; -- cpld
	         tx_data_k <= '0';
         when send_dummy_2 =>
            lcrc_calc <= '1';
            rxing <= '0';
	         tx_data_int<= "00000000";
	         tx_data_k <= '0';
         when send_tlp_length_hi =>
            lcrc_calc <= '1';
            rxing <= '0';
	         tx_data_int<= "00000000";
	         tx_data_k <= '0';
         when send_tlp_length_lo =>
            lcrc_calc <= '1';
            rxing <= '0';
	         tx_data_int<= "00000100";
	         tx_data_k <= '0';
         when send_completer_id_hi =>
            lcrc_calc <= '1';
            rxing <= '0';
	         send_completion_clr <= '1';
            tx_data_int<= "00000000";
	         tx_data_k <= '0';
         when send_completer_id_lo =>
            lcrc_calc <= '1';
            rxing <= '0';
	         tx_data_int<= "00010001";
	         tx_data_k <= '0';
         when send_byte_count_hi => 
            lcrc_calc <= '1';
            rxing <= '0';
	         tx_data_int<= "00000000";  ---first 3 bits are status, 000 for success
	         tx_data_k <= '0';
         when send_byte_count_lo =>
            lcrc_calc <= '1';
            rxing <= '0';
	         tx_data_int<= "00010000";
	         tx_data_k <= '0';
         when send_requester_id_hi =>
            lcrc_calc <= '1';
            rxing <= '0';
	         tx_data_int<= "00000000";
	         tx_data_k <= '0';
         when send_requester_id_lo =>
            lcrc_calc <= '1';
            rxing <= '0';
	         tx_data_int<= "00000001";
	         tx_data_k <= '0';
         when send_special_end =>
            tx_data_int <= x"FD";
            tx_data_k <= '1';
         when others =>
      end case;
   end process bridge_output;

   tx_data <= tx_data_int;
end architecture behavioral;

