
use work.aes.all;
library ieee;
use ieee.numeric_std.all;

entity enc is
   generic (
      k     : key;
   );
   port (
      clk   : in std_logic;
      nrst  : in std_logic;
      clr   : in std_logic;
      i_rdy : in std_logic;
      i     : in byte;
      o_rdy : out std_logic;
      o     : out blk
   );
end enc;

architecture behavioral of enc is
   type master_state_type is (idle, loading, encrypting);
   signal master_state, next_master_state : master_state_type;
   
   type enc_state_type is (init, rounds, final);
   signal enc_state, next_enc_state : enc_state_type;
   
   type round_state_type is (subbytes, mixcols, mixmul, addkey);
   signal round_state, next_round_state : round_state_type;
   
   signal b : blk;
begin
   
   
   process(i)
   begin
      for x in index loop
         for y in index loop
            o(x,y) <= sbox(to_integer(i(x,y)));
         end loop;
      end loop;
      --o(0,0) <= sbox(to_integer(i(0,0)));
   end process;
   
end behavioral;

