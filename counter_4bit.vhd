-- counter_4bit.vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity counter_4bit is
    Port (
        CLK   : in STD_LOGIC;
        i_enable   : in STD_LOGIC;
		  i_hold : IN STD_LOGIC;
        COUNT : out STD_LOGIC_VECTOR (3 downto 0)
    );
end counter_4bit;

architecture Structural of counter_4bit is
   component d_FF
       Port (
				i_d			: IN	STD_LOGIC;
				i_clock			: IN	STD_LOGIC;
				o_q, o_qBar		: OUT	STD_LOGIC
       );
    end component;
	 
	component mux_2to1_4bit
		PORT (
			sel     : IN  STD_LOGIC;                             -- Select input
         d_in1   : IN  STD_LOGIC_VECTOR(3 downto 0);        -- 8-bit Data input 1
         d_in2   : IN  STD_LOGIC_VECTOR(3 downto 0);        -- 8-bit Data input 2                         -- Reset input
         d_out   : OUT STD_LOGIC_VECTOR(3 downto 0)
		);
	END COMPONENT;
	
	signal t_en : std_LOGIC;
   signal Q, td, td_2, td_3 : STD_LOGIC_VECTOR(3 downto 0);
   signal D : bit_vector(3 downto 0);
begin
	td <= to_stdlogicvector(D);
    -- Flip-flop instances
	FF0: d_FF 
		port map (
			i_d => td(0), 
			i_clock => CLK, 
			o_q => Q(0), 
			o_qBar => open
		);
   FF1: d_FF 
		port map (
			i_d => td(1), 
			i_clock => CLK, 
			o_q => Q(1), 
			o_qBar => open
		);
   FF2: d_FF 
		port map (
			i_d => td(2), 
			i_clock => CLK, 
			o_q => Q(2), 
			o_qBar => open
		);
   FF3: d_FF 
		port map (
			i_d => td(3), 
			i_clock => CLK, 
			o_q => Q(3), 
			o_qBar => open
		);
		
	
	t_en <= i_enable;

	td_2(0) <= NOT Q(0) AND t_en;

	td_2(1) <= (Q(0) XOR Q(1)) AND t_en;  

	td_2(2) <= ((Q(0) AND Q(1)) XOR Q(2)) AND t_en;  

	td_2(3) <= ((Q(0) AND Q(1) AND Q(2)) XOR Q(3)) AND t_en;
	
	mux_2to1_4bit_inst : mux_2to1_4bit
		PORT MAP (
			sel => i_hold,
			d_in1 => td_2,
			d_in2 => Q,
			d_out => td_3
		);
		
	D <= to_bitvector(td_3);

	COUNT <= Q;

end Structural;
