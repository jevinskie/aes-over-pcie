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
    signal state, nextstate: state_type;
    subtype l_index is integer range 0 to 15;
    signal readcount, nextreadcount: l_index;
    signal seqnum, nextseqnum: sequence_number_type;
    signal crc, nextcrc:word
       
    Begin
    StateReg: process (clk, nrst)
       begin
           -- on reset, the RCU goes to the IDLE state, otherwise it goes
           -- to the next state.
           if (nrst = '0') then
               state <= IDLE;
           elsif (rising_edge(clk)) then
               state <= nextstate;
           end if;
    end process StateReg;
    
    ReadCounter: process(clk, nrst)
       begin
           if (nrst = '0') then
               readcount <= 0;
           elsif (rising_edge(clk)) then
               readcount <= nextreadcount;
           end if;
       end process ReadCounter;
    
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
            next_state <= check_lcrc;
         when others =>
            next_state => e_idle;
      end case;
   end process bridge_nsl;
    
    Next_state: process (state)
          begin
          case state is
             when IDLE =>
                 --add start condition
                 nextstate <= READ_DLLP_TYPE;
                 nextreadCount <= 0;
             when READ_DLLP_TYPE =>
                 nextstate <= READ_ACK_SEQ_NUM;
                 nextreadcount <= 0;
             when READ_ACK_SEQ_NUM =>
                 if (readcount < 2) then
                    nextstate <= READ_ACK_SEQ_NUM;
                    nextseqnum <= seqnum;
                    nextreadcount <= readcount + 1;
                 else
                    nextstate <= READ_CRC;
                    nextseqnum <= incoming_data;
                    nextreadcount <= 0; 
                 end if;
             when READ_CRC =>
                 
             when READ_HEADER =>
                 --read from stream_in to determine packet type and length
                 if (readcount < 4) then
                     nextstate <= READ_HEADER;
                     if (readcount = 0) then
                         pformat <= fifo_in(6 downto 5);
                         ptype <= fifo_in(4 downto 0);
                     end if;
                     nextreadcount <= readcount + 1;
                 else
                     nextstate <= READ_ADDR;
                     nextreadcount <= 0;
                 end if;
             when READ_ADDR =>
                 --read 32bit addr to determine where to write
                 if (readcount < 4) then
                     nextstate <= READ_ADDR;
                     --lets leave first 3 addr bytes empty
                     if (readcount = 4) then
                         paddr <= fifo_in(7 downto 1);
                     end if;
                     nextreadcount <= readcount + 1;
                 else
                     --if has payload
                     if (pformat = "00" and ptype = "00000") then
                         currentpacket <= MRD;
                         nextstate <= AES_CTRL;
                         nextreadcount <= 0;
                     elsif (pformat = "10" and ptype = "00000") then 
                         currentpacket <= MWR;
                         nextstate <= READ_PAYLOAD;
                         nextreadcount <= 0;
                     else
                         nextstate <= ERROR;
                         nextreadcount <= 0;
                         currentpacket <= MAL;
                     end if;
                 end if;
             when READ_PAYLOAD =>
                 --read in 128 bit block
                 if (readcount < 16) then
                     nextstate <= READ_PAYLOAD;
                     to_aes <= fifo_in;
                     nextreadcount <= readcount + 1;
                 else
                     nextstate <= AES_CTRL;
                     nextreadcount <= 0;
                 end if;
             when AES_CTRL =>
                 --send appropriate ctrl signals to aes_rcu
                 nextstate <= IDLE;
             when ERR =>
                 --possible error conditions: bad addr, length mismatch, incomplete data, malformed packet
                 nextstate <= ERROR;
             
             when others =>       
                 nextstate <= IDLE;
             end case;
    end process Next_state;
                   
end architecture Behavioral;
