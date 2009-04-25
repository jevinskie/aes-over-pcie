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
   procedure read(l : inout line; value : out state_type);
   procedure read(l : inout line; value : out state_type; good : out boolean);
   procedure hread(l : inout line; value : out state_type);
   procedure hread(l : inout line; value : out state_type; good : out boolean);
   procedure read(l : inout line; value : out slice);
   procedure read(l : inout line; value : out slice; good : out boolean);
   procedure hread(l : inout line; value : out slice);
   procedure hread(l : inout line; value : out slice; good : out boolean);
   procedure hwrite(l : inout line; value : out byte);
   procedure hwrite(l : inout line; value : out state_type; good : out boolean);
end package aes_textio;


library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

library work;
use work.numeric_std_textio.all;


package body aes_textio is
   
   
   -- state_type stuff
   procedure read(l : inout line; value : out key_type) is
      variable good : boolean;
   begin
      read(l, value, good);
      assert good
         report "aes_textio: read(line, key_type) failed"
         severity error;
   end procedure read;
   
   
   procedure read(l : inout line; value : out key_type; good : out boolean) is
      variable good_overall   : boolean;
      variable good_temp      : boolean;
   begin
      good_overall := true;
      for i in g_index loop
         read(l, value(i mod 4, i / 4), good_temp);
         good_overall := good_overall and good_temp;
      end loop;
      good := good_overall;
   end procedure read;
   
   
   procedure hread(l : inout line; value : out key_type) is
      variable good : boolean;
   begin
      hread(l, value, good);
      assert good
         report "aes_textio: hread(line, key_type) failed"
         severity error;
   end procedure hread;
   
   
   procedure hread(l : inout line; value : out key_type; good : out boolean) is
      variable good_overall   : boolean;
      variable good_temp      : boolean;
   begin
      good_overall := true;
      for i in g_index loop
         hread(l, value(i mod 4, i / 4), good_temp);
         good_overall := good_overall and good_temp;
      end loop;
      good := good_overall;
   end procedure hread;
   
   
   -- slice stuff
   procedure read(l : inout line; value : out slice) is
      variable good : boolean;
   begin
      read(l, value, good);
      assert good
         report "aes_textio: read(line, slice) failed"
         severity error;
   end procedure read;
   
   
   procedure read(l : inout line; value : out slice; good : out boolean) is
      variable good_overall   : boolean;
      variable good_temp      : boolean;
   begin
      good_overall := true;
      for i in index loop
         read(l, value(i), good_temp);
         good_overall := good_overall and good_temp;
      end loop;
      good := good_overall;
   end procedure read;
   
   
   procedure hread(l : inout line; value : out slice) is
      variable good : boolean;
   begin
      hread(l, value, good);
      assert good
         report "aes_textio: hread(line, slice) failed"
         severity error;
   end procedure hread;
   
   
   procedure hread(l : inout line; value : out slice; good : out boolean) is
      variable good_overall   : boolean;
      variable good_temp      : boolean;
   begin
      good_overall := true;
      for i in index loop
         hread(l, value(i), good_temp);
         good_overall := good_overall and good_temp;
      end loop;
      good := good_overall;
   end procedure hread;   
   
   -- hwrite stuff

   procedure hwrite(l : inout line; value : out byte) is
      variable good : boolean;
   begin
      hwrite(l, std_logic_vector(value), good);
      assert good
         report "aes_textio: hwrite(line, byte) failed"
         severity error;
   end procedure hwrite;

   
   procedure hwrite(l : inout line; value : out state_type; good : out boolean) is
      variable good_overall   : boolean;
      variable good_temp      : boolean;
   begin
      good_overall := true;
      for i in g_index loop
         hwrite(l, value(i mod 4, i / 4), good_temp);
         good_overall := good_overall and good_temp;
      end loop;
      good := good_overall;
   end procedure hwrite;


   
end package body aes_textio;
