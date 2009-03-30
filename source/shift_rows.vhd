-- $Id: 17
-- File name:   shift_rows.vhd
-- Created:     3/30/2009
-- Author:      Zachary Curosh
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: a transposition step where each row of the state is 
-- shifted cyclically a certain number of steps

use work.aes.all;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity shift_rows is
    port (clk        : in std_logic;
          data_in    : in slice;
          num_shifts : in shift_amount;
          data_out   : out slice
          );

architecture dataflow of shift_rows is
    
    -- Shift rows algorithm
    -- row 1: no shift: [a00, a01, a02, a03] --> [a00, a01, a02, a03]
    -- row 2: shift 1 : [a10, a11, a12, a13] --> [a11, a12, a13, a10]
    -- row 3: shift 2 : [a20, a21, a22, a23] --> [a22, a23, a20, a21]
    -- row 4: shift 3 : [a30, a31, a32, a33] --> [a33, a30, a31, a32]
    
begin
    process(r_in, num_shifts)
        begin
            data_out <= data_in when num_shifts='0';
            data_out <= (data_in rol 1) when num_shifts='1';
            data_out <= (data_in rol 2) when num_shifts='2';
            data_out <= (data_in rol 3) when num_shifts='3';
    end process;
 end dataflow;