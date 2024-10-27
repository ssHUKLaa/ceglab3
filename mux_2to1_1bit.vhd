LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux_2to1_1bit IS
    PORT(
        d0 : IN STD_LOGIC;
        d1 : IN STD_LOGIC;
        sel, en : IN STD_LOGIC;
        d_out : OUT STD_LOGIC
    );
END mux_2to1_1bit;

ARCHITECTURE structural OF mux_2to1_1bit IS
BEGIN
    d_out <= ((NOT(sel) AND d0) OR (sel AND d1)) AND en;
END structural;