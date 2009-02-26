-- File name:   aes.vhd
-- Created:     2009-02-25
-- Author:      Jevin Sweval
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: AES package

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package aes is
  
   subtype byte is unsigned(7 downto 0);
   
   type index is range 0 to 3;
   
   type pntr is record
      i : index;
      j : index;
   end record pntr;
   
   type blk is array (index, index) of byte;
   
end aes;

