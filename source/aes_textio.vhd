-- File name:   aes_textio.vhd
-- Created:     2009-04-06
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: AES textio package


library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

library work;
use work.numeric_std_textio.all;
use work.aes.all;

package aes_textio  is
   procedure read(l : inout line; value : out key);
   procedure read(l : inout line; value : out key; good : out boolean);
   procedure hread(l : inout line; value : out key);
   procedure hread(l : inout line; value : out key; good : out boolean);
end package aes_textio;


library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

library work;
use work.numeric_std_textio.all;


package body aes_textio is
   
   
   procedure read(l : inout line; value : out key) is
      variable good : boolean;
   begin
      read(l, value, good);
      assert good
         report "aes_textio: read(line, byte) failed"
         severity error;
   end procedure read;
   
   
   procedure read(l : inout line; value : out key; good : out boolean) is
      variable good_overall   : boolean;
      variable good_temp      : boolean;
   begin
      good_overall := true;
      for i in g_index loop
         read(l, value(i), good_temp);
         good_overall := good_overall and good_temp;
      end loop;
      good := good_overall;
   end procedure read;
   
   
   procedure hread(l : inout line; value : out key) is
      variable good : boolean;
   begin
      hread(l, value, good);
      assert good
         report "aes_textio: hread(line, byte) failed"
         severity error;
   end procedure hread;
   
   
   procedure hread(l : inout line; value : out key; good : out boolean) is
      variable good_overall   : boolean;
      variable good_temp      : boolean;
   begin
      good_overall := true;
      for i in g_index loop
         hread(l, value(i), good_temp);
         good_overall := good_overall and good_temp;
      end loop;
      good := good_overall;
   end procedure hread;
   
   
end package body aes_textio;
