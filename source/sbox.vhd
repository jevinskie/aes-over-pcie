-- File name:   sbox.vhd
-- Created:     2009-02-26
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: Rijndael S-Box

use work.aes.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sbox is
   port (
      a : in byte;
      b : out byte
   );
end sbox;

architecture dataflow of sbox is
   
   
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
      res_mid := mul_gf2(qh xor ql, wh xor wl);
      res_bot := mul_gf2(ql, wl);
      
      k(3 downto 2) := res_mid xor res_bot;
      k(1 downto 0) := res_top xor res_bot;
      
      return k;
   end function mul_gf4;
   
   function iso_map(q : byte)
      return byte
   is
      variable k : byte;
   begin
      k(7) := q(7) xor q(5);
      k(6) := q(7) xor q(6) xor q(4) xor q(3) xor q(2) xor q(1);
      k(5) := q(7) xor q(5) xor q(3) xor q(2);
      k(4) := q(7) xor q(5) xor q(3) xor q(2) xor q(1);
      k(3) := q(7) xor q(6) xor q(2) xor q(1);
      k(2) := q(7) xor q(4) xor q(3) xor q(2) xor q(1);
      k(1) := q(6) xor q(4) xor q(1);
      k(0) := q(6) xor q(1) xor q(0);
      
      return k;
   end function iso_map;
   
   
   function inv_iso_map(q : byte)
      return byte
   is
      variable k : byte;
   begin
      k(7) := q(7) xor q(6) xor q(5) xor q(1);
      k(6) := q(6) xor q(2);
      k(5) := q(6) xor q(5) xor q(1);
      k(4) := q(6) xor q(5) xor q(4) xor q(2) xor q(1);
      k(3) := q(5) xor q(4) xor q(3) xor q(2) xor q(1);
      k(2) := q(7) xor q(4) xor q(3) xor q(2) xor q(1);
      k(1) := q(5) xor q(4);
      k(0) := q(6) xor q(5) xor q(4) xor q(2) xor q(0);
      
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
   
   
   function af(a : byte)
      return byte
   is
      variable b : byte;
      variable d : byte;
      constant r : byte := "11111000";
      constant c : byte := "01100011";
   begin
      for i in 0 to 7 loop
         b(i) := '0';
         d := r ror i;
         for j in 0 to 7 loop
            b(i) := b(i) xor (a(j) and d(j));
         end loop;
      end loop;
      
      b := b xor c;
      
      return b;
   end function af;
   
   signal iso : byte;
   signal isoh, isol : nibble;
   signal left_top, left_bot : nibble;
   signal right_top, right_bot : nibble;
   signal mulinv : nibble;
   signal preaf : byte;
   
begin
   
   iso <= iso_map(a);
   isoh <= iso(7 downto 4);
   isol <= iso(3 downto 0);
   
   left_top <= mullambda_gf4(square_gf4(isoh));
   left_bot <= mul_gf4(isoh xor isol, isol);
   
   mulinv <= mulinv_gf4(left_top xor left_bot);
   
   right_top <= mul_gf4(mulinv, isoh);
   right_bot <= mul_gf4(mulinv, isoh xor isol);
   
   preaf <= inv_iso_map(right_top & right_bot);
   
   b <= af(preaf);
   
end dataflow;

architecture naive of sbox is
begin
   b <= work.aes.sbox(to_integer(a));
end naive;

