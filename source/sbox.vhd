-- File name:   sbox.vhd
-- Created:     2009-02-26
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: Rijndael S-Box

use work.aes.all;
use work.reduce_pack.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sbox is
   
   port (
      clk   : in std_logic;
      a     : in byte;
      b     : out byte
   );
   
   
   type matrix_type is array (7 downto 0) of byte;
   
   
   function square_gf4 (q : nibble)
      return nibble
   is
      variable k : nibble;
   begin
      k(3) := q(3);
      k(2) := q(3) xor q(2);
      k(1) := q(2) xor q(1);
      k(0) := q(3) xor q(1) xor q(0);
      
      return k;
   end function square_gf4;
   
   
   function mullambda_gf4 (q : nibble)
      return nibble
   is
      variable k : nibble;
   begin
      k(3) := q(2) xor q(0);
      k(2) := q(3) xor q(2) xor q(1) xor q(0);
      k(1) := q(3);
      k(0) := q(2);
      
      return k;
   end function mullambda_gf4;
   
   
   function mul_gf2(q : pair; w : pair)
      return pair
   is
      variable k : pair;
   begin
      k(1) := (q(1) and w(1)) xor (q(0) and w(1)) xor (q(1) and w(0));
      k(0) := (q(1) and w(1)) xor (q(0) and w(0));
      
      return k;
   end function mul_gf2;
   
   
   function mul_alt_gf2(q : pair; w : pair)
      return pair
   is
      variable k : pair;
   begin
      k(1) := ((q(1) xor q(0)) and (w(1) xor w(0))) xor (q(0) and w(0));
      k(0) := (q(1) and w(1)) xor (q(0) and w(0));
      
      return k;
   end function mul_alt_gf2;
    
   
   function mulphi_gf2(q : pair)
      return pair
   is
      variable k : pair;
   begin
      k(1) := q(1) xor q(0);
      k(0) := q(1);
      
      return k;
   end function mulphi_gf2;
   
   
   function mul_gf4(q : nibble; w : nibble)
      return nibble
   is
      variable qh, ql, wh, wl : pair;
      variable res_top, res_mid, res_bot : pair;
      variable k : nibble;
   begin
      qh := q(3 downto 2);
      ql := q(1 downto 0);
      wh := w(3 downto 2);
      wl := w(1 downto 0);
      
      res_top := mulphi_gf2(mul_gf2(qh, wh));
      res_mid := mul_alt_gf2(qh xor ql, wh xor wl);
      res_bot := mul_alt_gf2(ql, wl);
      
      k(3 downto 2) := res_mid xor res_bot;
      k(1 downto 0) := res_top xor res_bot;
      
      return k;
   end function mul_gf4;
   
   function iso_map(q : byte)
      return byte
   is
      variable k     : byte;
      constant iso   : matrix_type :=
         ("10100000",
          "11011110",
          "10101100",
          "10101110",
          "11000110",
          "10011110",
          "01010010",
          "01000011");
   begin
      for i in iso'range loop
         k(i) := xor_reduce(q and iso(i));
      end loop;
      
      return k;
   end function iso_map;
   
   
   function inv_iso_map(q : byte)
      return byte
   is
      variable k        : byte;
      constant iso_inv  : matrix_type :=
         ("11100010",
          "01000100",
          "01100010",
          "01110110",
          "00111110",
          "10011110",
          "00110000",
          "01110101");
   begin
      for i in iso_inv'range loop
         k(i) := xor_reduce(q and iso_inv(i));
      end loop;
      
      return k;
   end function inv_iso_map;
   
   
   function mulinv_gf4(q : nibble)
      return nibble
   is
      variable k : nibble;
   begin
      k(3) := q(3) xor (q(3) and q(2) and q(1)) xor (q(3) and q(0)) xor q(2);
      k(2) := (q(3) and q(2) and q(1)) xor (q(3) and q(2) and q(0)) xor
         (q(3) and q(0)) xor q(2) xor (q(2) and q(1));
      k(1) := q(3) xor (q(3) and q(2) and q(1)) xor (q(3) and q(1) and q(0)) xor
         q(2) xor (q(2) and q(0)) xor q(1);
      k(0) := (q(3) and q(2) and q(1)) xor (q(3) and q(2) and q(0)) xor
         (q(3) and q(1)) xor (q(3) and q(1) and q(0)) xor (q(3) and q(0)) xor
         q(2) xor (q(2) and q(1)) xor (q(2) and q(1) and q(0)) xor q(1) xor q(0);
      
      return k;
   end function mulinv_gf4;
   
   
   function mulinv_lut_gf4(q : nibble)
      return nibble
   is
      variable k : nibble;
   begin
      case q is
         when x"0" => k := x"0";
         when x"1" => k := x"1";
         when x"2" => k := x"3";
         when x"3" => k := x"2";
         when x"4" => k := x"f";
         when x"5" => k := x"c";
         when x"6" => k := x"9";
         when x"7" => k := x"b";
         when x"8" => k := x"a";
         when x"9" => k := x"6";
         when x"a" => k := x"8";
         when x"b" => k := x"7";
         when x"c" => k := x"5";
         when x"d" => k := x"e";
         when x"e" => k := x"d";
         when x"f" => k := x"4";
         when others => k := x"0";
      end case;
      
      return k;
   end function mulinv_lut_gf4;
   
   
   function af(a : byte)
      return byte
   is
      variable b : byte;
      variable d : byte;
      constant m : matrix_type :=
         ("11111000",
          "01111100",
          "00111110",
          "00011111",
          "10001111",
          "11000111",
          "11100011",
          "11110001");
      constant c : byte := "01100011";
   begin
      for i in m'range loop
         b(i) := xor_reduce(a and m(i));
      end loop;
      
      b := b xor c;
      
      return b;
   end function af;

end entity sbox;


architecture dataflow of sbox is
   
   signal iso                    : byte;
   signal isoh, isol             : nibble;
   signal left_top, left_bot     : nibble;
   signal right_top, right_bot   : nibble;
   signal mulinv                 : nibble;
   signal preaf                  : byte;
   
begin
   
   iso   <= iso_map(a);
   isoh  <= iso(7 downto 4);
   isol  <= iso(3 downto 0);
   
   left_top <= mullambda_gf4(square_gf4(isoh));
   left_bot <= mul_gf4(isoh xor isol, isol);
   
   mulinv <= mulinv_lut_gf4(left_top xor left_bot);
   
   right_top <= mul_gf4(mulinv, isoh);
   right_bot <= mul_gf4(mulinv, isoh xor isol);
   
   preaf <= inv_iso_map(right_top & right_bot);
   
   b <= af(preaf);
   
end architecture dataflow;


architecture pipelined of sbox is
   
   signal iso                    : byte;
   signal isoh, isol             : nibble;
   signal isoh_q, isol_q         : nibble;
   signal left_top, left_bot     : nibble;
   signal left_top_q, left_bot_q : nibble;
   signal right_top, right_bot   : nibble;
   signal mulinv                 : nibble;
   signal preaf                  : byte;
   signal subbyte                : byte;
   
begin
   
   reg : process(clk)
   begin
      if (rising_edge(clk)) then
         isoh_q <= isoh;
         isol_q <= isol;
         left_top_q <= left_top;
         left_bot_q <= left_bot;
         b <= subbyte;
      end if;
   end process reg;
   
   iso   <= iso_map(a);
   isoh  <= iso(7 downto 4);
   isol  <= iso(3 downto 0);
   
   left_top <= mullambda_gf4(square_gf4(isoh));
   left_bot <= mul_gf4(isoh xor isol, isol);
   
   mulinv <= mulinv_lut_gf4(left_top_q xor left_bot_q);
   
   right_top <= mul_gf4(mulinv, isoh_q);
   right_bot <= mul_gf4(mulinv, isoh_q xor isol_q);
   
   preaf <= inv_iso_map(right_top & right_bot);
   
   subbyte <= af(preaf);
   
end architecture pipelined;


--architecture lut of sbox is
--begin
--   b <= work.aes.sbox(to_integer(a));
--end architecture lut;


