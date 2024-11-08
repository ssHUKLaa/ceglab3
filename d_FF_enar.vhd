LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY d_FF_enar IS
	PORT(
		i_d, i_enable, i_reset			: IN	STD_LOGIC;
		i_clock			: IN	STD_LOGIC;
		o_q, o_qBar		: OUT	STD_LOGIC);
END d_FF_enar;

ARCHITECTURE rtl OF d_FF_enar IS
	SIGNAL int_q, int_qBar, oq_t : STD_LOGIC;
	SIGNAL int_d, int_dBar : STD_LOGIC;
	SIGNAL int_notD, int_notClock : STD_LOGIC;

	COMPONENT enabledSRLatch
		PORT(
			i_set, i_reset	: IN	STD_LOGIC;
			i_enable	: IN	STD_LOGIC;
			o_q, o_qBar	: OUT	STD_LOGIC);
	END COMPONENT;

BEGIN

	-- Component Instantiation
	masterLatch: enabledSRLatch
		PORT MAP (	i_set 		=> i_d, 
				i_reset 	=> int_notD,
				i_enable 	=> int_notClock,
				o_q 		=> int_q,
				o_qBar		=> int_qBar);

	slaveLatch: enabledSRLatch
		PORT MAP (	i_set 		=> int_q, 
				i_reset 	=> int_qBar,
				i_enable	=> i_clock,
				o_q 		=> oq_t,
				o_qBar		=> o_qBar);
	
	o_q <= oq_t AND i_enable AND NOT i_reset;
	
	--  Concurrent Signal Assignment

	int_notD	<=	not(i_d);
	int_notClock	<=	not(i_clock);

END rtl;
