--
-- Package: numerric_std_textio 
-- Author: n0702078
-- Created On: 02/02/01 at 13:16
--

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

package numeric_std_textio  is
--synopsys synthesis_off
        -- Read and Write procedures for SIGNED and UNSIGNED
        procedure READ(L:inout LINE; VALUE:out SIGNED);
        procedure READ(L:inout LINE; VALUE:out SIGNED; GOOD: out BOOLEAN);
        procedure READ(L:inout LINE; VALUE:out UNSIGNED);
        procedure READ(L:inout LINE; VALUE:out UNSIGNED; GOOD: out BOOLEAN);
        procedure HREAD(L:inout LINE; VALUE:out UNSIGNED);
        procedure HREAD(L:inout LINE; VALUE:out UNSIGNED; GOOD: out BOOLEAN);

        procedure WRITE(L:inout LINE; VALUE:in SIGNED;
                        JUSTIFIED:in SIDE := RIGHT; FIELD:in WIDTH := 0);
        procedure WRITE(L:inout LINE; VALUE:in UNSIGNED;
                        JUSTIFIED:in SIDE := RIGHT; FIELD:in WIDTH := 0);
--synopsys synthesis_on
end numeric_std_textio;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
package body numeric_std_textio  is
--synopsys synthesis_off
        -- Read and Write procedures for SIGNED and UNSIGNED

procedure READ(L:inout LINE; VALUE:out SIGNED; GOOD: out BOOLEAN) is
  variable slv_value : std_logic_vector(value'range);
begin
  read(L, slv_value, good);
  value:= signed(slv_value);
end;

procedure READ(L:inout LINE; VALUE:out SIGNED) is
  variable good : boolean;
begin
  read(l, value, good);
  assert good
    report "numeric_std_textio: read(line,signed) failed"
    severity error;
end;

procedure READ(L:inout LINE; VALUE:out UNSIGNED; GOOD: out BOOLEAN) is
  variable slv_value : std_logic_vector(value'range);
begin
  read(L, slv_value, good);
  value:= unsigned(slv_value);
end;

procedure READ(L:inout LINE; VALUE:out UNSIGNED) is
  variable good : boolean;
begin
  read(l, value, good);
  assert good
    report "numeric_std_textio: read(line,unsigned) failed"
    severity error;
end;

procedure HREAD(L:inout LINE; VALUE:out UNSIGNED; GOOD: out BOOLEAN) is
  variable slv_value : std_logic_vector(value'range);
begin
  hread(L, slv_value, good);
  value:= unsigned(slv_value);
end;

procedure HREAD(L:inout LINE; VALUE:out UNSIGNED) is
  variable good : boolean;
begin
  hread(l, value, good);
  assert good
    report "numeric_std_textio: hread(line,unsigned) failed"
    severity error;
end;

procedure WRITE(L:inout LINE; VALUE:in SIGNED;
                       JUSTIFIED:in SIDE := RIGHT; FIELD:in WIDTH := 0) is
begin
  write(l, std_logic_vector(value), justified, field);
end;

procedure WRITE(L:inout LINE; VALUE:in UNSIGNED;
                        JUSTIFIED:in SIDE := RIGHT; FIELD:in WIDTH := 0) is 
begin
  write(l, std_logic_vector(value), justified, field);
end;

--synopsys synthesis_on
end;
