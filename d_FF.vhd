LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY d_FF IS
	PORT(
		i_d, i_en, i_reset			: IN	STD_LOGIC;
		i_clock			: IN	STD_LOGIC;
		o_q, o_qBar		: OUT	STD_LOGIC);
END d_FF;

ARCHITECTURE rtl OF d_FF IS
	SIGNAL int_q, int_qBar : STD_LOGIC;
	SIGNAL int_d,int_d2, int_dBar : STD_LOGIC;
	SIGNAL int_notD, int_notClock : STD_LOGIC;

	COMPONENT enabledSRLatch
		PORT(
			i_set, i_reset	: IN	STD_LOGIC;
			i_enable	: IN	STD_LOGIC;
			o_q, o_qBar	: OUT	STD_LOGIC);
	END COMPONENT;
	
	COMPONENT mux_2to1_1bit
		PORT (
			d0 : IN STD_LOGIC;
         d1 : IN STD_LOGIC;
         sel : IN STD_LOGIC;
         d_out : OUT STD_LOGIC
		);
	END COMPONENT;

BEGIN
	int_d <= i_d AND i_en;
	mux_2to1_1bit_decide : mux_2to1_1bit
		PORT MAP (
			d0 => int_d,
			d1 => '0',
			sel => i_reset,
			d_out => int_d2
		);
	
	-- Component Instantiation
	masterLatch: enabledSRLatch
		PORT MAP (	i_set 		=> int_d2, 
				i_reset 	=> int_notD,
				i_enable 	=> int_notClock,
				o_q 		=> int_q,
				o_qBar		=> int_qBar);

	slaveLatch: enabledSRLatch
		PORT MAP (	i_set 		=> int_q, 
				i_reset 	=> int_qBar,
				i_enable	=> i_clock,
				o_q 		=> o_q,
				o_qBar		=> o_qBar);
	
	--  Concurrent Signal Assignment

	int_notD	<=	not(int_d2);
	int_notClock	<=	not(i_clock);

END rtl;
