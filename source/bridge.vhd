use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bridge is
   port(
       clk : in std_logic;
       nrst : in std_logic;
       incoming_data : in byte;
       outgoing_data : out byte;
       to_aes: out byte;
       from_aes: in byte;
       crtl : out std_logic --change this later 
       got_key : out std_logic;
       got_pt : out std_logic;
       send_ct: out std_logic     
       );
end entity bridge;

architecture behavioral of bridge is
    type state_type is (IDLE, READ_HEADER, READ_ADDR, READ_PAYLOAD, AES_CTRL, ERR);
    type packet_type is (MWR, MRD, CPLD, MAL);
    signal currentpacket: packet_type;
    signal pformat: unsigned(1 downto 0);
    signal ptype: unsigned(4 downto 0);
    signal paddr: unsigned(6 downto 0);
    signal ackseq: unsigned(11 downto 0);
    signal state, next_state: state_type;
    subtype l_index is integer range 0 to 15;
    signal readcount, nextreadcount: l_index;
    signal seqnum, nextseqnum: sequence_number_type;
    signal crc, nextcrc:word

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
    
    SeqNum: process(clk, nrst)
    begin
           if (nrst = '0') then
               seqnum <= (others => '0');
           elsif (rising_edge(clk)) then
               seqnum <= nextseqnum;
           end if;
    end process SeqNum;
    
   rcu_nsl : process(state)
   begin
      case state is
         when idle =>
            next_state <= read_dllp_type;
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
            next_state <= read_reqester_id_hi;
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
            if (addr = x"00001000") then
               next_state <= load_key;
            elsif (addr = x"00002000") then
               next_state <= load_pt;
            elsif (addr = x"00003000") then
               next_state <= store_ct;
            else
               next_state <= e_idle;
            end if;
         when load_key =>
            if (i /= 15) then
               next_state <= load_key;
            else
               next_state <= read_lcrc_hi_hi;
            end if;
         when load_pt =>
            if (i /= 15) then
               next_state <= load_pt;
            else
               next_state <= read_lcrc_hi_hi;
            end if;
         when store_ct =>
            next_state <= read_lcrc_hi_hi;
         when read_lcrc_hi_hi =>
            next_state <= read_lcrc_hi_lo;
         when read_lcrc_hi_lo =>
            next_state <= read_lcrc_lo_hi;
         when read_lcrc_lo_hi =>
            next_state <= read_lcrc_lo_lo;
         when read_lcrc_lo_lo =>
            next_state <= send_dllp_type;
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
            next_state <= idle;
         when send_tlp_seq_num_hi =>
            next_state <= send_tlp_seq_num_lo;
         when send_tlp_seq_num_lo =>
            next_state <= send_tlp_type;
         when send_tlp_type =>
            next_state <= send_dummy_2;
         when send_dummy_2 =>
            next_state <= send_tlp_length_hi;
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
            next_state <= send_ct;
         when send_ct =>
            if (i /= 15) then
               next_state <= send_ct;
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
            next_state <= idle;
         when others =>
            next_state => e_idle;
      end case;
   end process bridge_nsl;
   
   bridge_output : process(state)
   begin
      
   end process bridge_output;
   
end architecture behavioral;

