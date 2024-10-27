LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux_4to1_1bit IS
	PORT(
		d_in : IN STD_LOGIC_VECTOR(3 downto 0);
		sel : IN STD_LOGIC_VECTOR(1 downto 0);
		en : IN STD_LOGIC;
		d_out : OUT STD_LOGIC
	);
END mux_4to1_1bit;

ARCHITECTURE structural OF mux_4to1_1bit IS
	SIGNAL andResult : STD_LOGIC;
	
BEGIN
	andResult <= (NOT(sel(0)) AND NOT(sel(1)) AND d_in(0)) 
	OR (NOT(sel(0)) AND sel(1) AND d_in(1)) 
	OR (sel(0) AND NOT(sel(1)) AND d_in(2)) 
	OR (sel(0) AND sel(1) AND d_in(3));
	
	d_out <= andResult AND en;
	
end structural;
	