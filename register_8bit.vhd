LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY register_8bit IS
    PORT(
        i_d         : IN  STD_LOGIC_VECTOR(7 downto 0);  -- 8-bit input data
        i_clock     : IN  STD_LOGIC;                      -- Clock input
        i_enable    : IN  STD_LOGIC;                      -- Enable signal (single bit)
        o_q         : OUT STD_LOGIC_VECTOR(7 downto 0)   -- 8-bit output data
    );
END register_8bit;

ARCHITECTURE rtl OF register_8bit IS
    COMPONENT d_FF
        PORT(
            i_d       : IN  STD_LOGIC;                    -- 1-bit input data
            i_clock   : IN  STD_LOGIC;                    -- Clock input
            o_q       : OUT STD_LOGIC;                    -- 1-bit output data
            o_qBar    : OUT STD_LOGIC                       -- 1-bit inverted output data
        );
    END COMPONENT;

    SIGNAL q_internal, d_internal : STD_LOGIC_VECTOR(7 downto 0);  -- Internal signal to hold the output of D flip-flops

BEGIN
	 d_internal(0) <= i_d(0) AND i_enable;
	 d_internal(1) <= i_d(1) AND i_enable;
	 d_internal(2) <= i_d(2) AND i_enable;
	 d_internal(3) <= i_d(3) AND i_enable;
	 d_internal(4) <= i_d(4) AND i_enable;
	 d_internal(5) <= i_d(5) AND i_enable;
	 d_internal(6) <= i_d(6) AND i_enable;
	 d_internal(7) <= i_d(7) AND i_enable;
    -- Instantiate each D flip-flop for the 8-bit register
    dff_inst0: d_FF
        PORT MAP (
            i_d     => d_internal(0),                -- Load if enabled
            i_clock => i_clock,
            o_q     => q_internal(0),
            o_qBar  => open                                  -- Not used
        );

    dff_inst1: d_FF
        PORT MAP (
            i_d     => d_internal(1),
            i_clock => i_clock,
            o_q     => q_internal(1),
            o_qBar  => open
        );

    dff_inst2: d_FF
        PORT MAP (
            i_d     => d_internal(2),
            i_clock => i_clock,
            o_q     => q_internal(2),
            o_qBar  => open
        );

    dff_inst3: d_FF
        PORT MAP (
            i_d     => d_internal(3),
            i_clock => i_clock,
            o_q     => q_internal(3),
            o_qBar  => open
        );

    dff_inst4: d_FF
        PORT MAP (
            i_d     => d_internal(4),
            i_clock => i_clock,
            o_q     => q_internal(4),
            o_qBar  => open
        );

    dff_inst5: d_FF
        PORT MAP (
            i_d     => d_internal(5),
            i_clock => i_clock,
            o_q     => q_internal(5),
            o_qBar  => open
        );

    dff_inst6: d_FF
        PORT MAP (
            i_d     => d_internal(6),
            i_clock => i_clock,
            o_q     => q_internal(6),
            o_qBar  => open
        );

    dff_inst7: d_FF
        PORT MAP (
            i_d     => d_internal(7),
            i_clock => i_clock,
            o_q     => q_internal(7),
            o_qBar  => open
        );

    -- Assign the internal signal to the output
    o_q <= q_internal;

END rtl;
