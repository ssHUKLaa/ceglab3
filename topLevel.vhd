LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

Entity topLevel IS
	PORT (
		GClock, GReset, SSCS : IN STD_LOGIC;
		MSC, SSC : IN STD_LOGIC_VECTOR(3 downto 0);
		MSTL, SSTL : OUT STD_LOGIC_VECTOR(2 downto 0);
		SegmentOut : OUT STD_LOGIC_VECTOR(13 downto 0)
	);
END topLevel;

architecture basic of topLevel IS
	
	COMPONENT BCD_to_7Segment 
		PORT (
			A_in : IN  STD_LOGIC_VECTOR(3 downto 0); 
			seg : OUT STD_LOGIC_VECTOR(13 downto 0)  
		);
	END COMPONENT;
	
	COMPONENT equality_Comparator_4bit
		PORT (
			A, B : IN STD_LOGIC_VECTOR(3 downto 0);
			isEqual : OUT STD_LOGIC		
		);
	END COMPONENT;
	
	COMPONENT counter_4bit 
		PORT (
			CLK   : in STD_LOGIC;
         i_enable   : in STD_LOGIC;
			i_hold : IN STD_LOGIC;
         COUNT : out STD_LOGIC_VECTOR (3 downto 0)
		);
	END COMPONENT;
	
	COMPONENT mux_2to1_1bit
		PORT (
			d0 : IN STD_LOGIC;
         d1 : IN STD_LOGIC;
         sel, en : IN STD_LOGIC;
         d_out : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT mux_2to1_2bit
		PORT (
			sel     : IN  STD_LOGIC;                             -- Select input
         d_in1   : IN  STD_LOGIC_VECTOR(1 downto 0);        -- 8-bit Data input 1
         d_in2   : IN  STD_LOGIC_VECTOR(1 downto 0);        -- 8-bit Data input 2                         -- Reset input
         d_out   : OUT STD_LOGIC_VECTOR(1 downto 0) 
		);
	END COMPONENT;
	
	COMPONENT mux_4to1_1bit
		PORT (
			d_in : IN STD_LOGIC_VECTOR(3 downto 0);
			sel : IN STD_LOGIC_VECTOR(1 downto 0);
			en : IN STD_LOGIC;
			d_out : OUT STD_LOGIC
		);
	END COMPONENT;
	
	component d_FF
       Port (
				i_d			: IN	STD_LOGIC;
				i_clock			: IN	STD_LOGIC;
				o_q, o_qBar		: OUT	STD_LOGIC
       );
    end component;
	
	signal MT, SST : STD_LOGIC_VECTOR(3 downto 0);
	signal transitoryMSLT, transitoryMTTT, transitorySSLT, transitorySSTT, displayOnBCD : STD_LOGIC_VECTOR(3 downto 0);
	signal transitoryMSTL : bit_vector(1 downto 0);
	signal transitorySSTL : bit_vector(1 downto 0);
	signal MSTLIsGreen, MSTLIsYellow, MSTLIsRed : STD_LOGIC;
	signal SSTLIsGreen, SSTLIsYellow : STD_LOGIC;
	signal STDtransitoryMSTL, STDtransitorySSTL, STDtransitoryMSTLDecider, STDtransitorySSTLDecider : STD_LOGIC_VECTOR(1 downto 0);
	signal MSLTHoldCond, MSTLReachedEnd : STD_LOGIC;
	signal SSTLReachedEnd : STD_LOGIC;
	signal SSTReachedEnd : STD_LOGIC;
	signal MTReachedEnd : STD_LOGIC;
begin
	MT <= "1100";
	SST <= "1000"; 
	
	STDtransitoryMSTL <= to_stdlogicvector(transitoryMSTL);
	STDtransitorySSTL <= to_stdlogicvector(transitorySSTL);
	MSLTHoldCond <= MSTLReachedEnd AND NOT SSCS;
		
	counter_4bit_MSLTimer : counter_4bit
		PORT MAP (
			CLK => GClock,
			i_enable => STDtransitoryMSTL(1),
			i_hold => MSLTHoldCond,
			COUNT => transitoryMSLT
		);
	
	equality_Comparator_4bit_MSLT_MSC : equality_Comparator_4bit
		PORT MAP (
			A => transitoryMSLT,
			B => MSC,
			isEqual => MSTLReachedEnd
		);
		
	counter_4bit_MTT : counter_4bit
		PORT MAP (
			CLK => GClock,
			i_enable => STDtransitoryMSTL(0),
			i_hold => '0',
			COUNT => transitoryMTTT
		);
	
	equality_Comparator_4bit_MTTTT_MT : equality_Comparator_4bit
		PORT MAP (
			A => transitoryMTTT,
			B => MT,
			isEqual => MTReachedEnd
		);
		
	counter_4bit_SSLTimer : counter_4bit
		PORT MAP (
			CLK => GClock,
			i_enable => STDtransitorySSTL(1),
			i_hold => '0',
			COUNT => transitorySSLT
		);
	
	equality_Comparator_4bit_SSLT_SSC : equality_Comparator_4bit
		PORT MAP (
			A => transitorySSLT,
			B => SSC,
			isEqual => SSTLReachedEnd
		);
		
	counter_4bit_SST : counter_4bit
		PORT MAP (
			CLK => GClock,
			i_enable => STDtransitorySSTL(0),
			i_hold => '0',
			COUNT => transitorySSTT
		);
	
	equality_Comparator_4bit_SSTT_SST : equality_Comparator_4bit
		PORT MAP (
			A => transitorySSTT,
			B => SST,
			isEqual => SSTReachedEnd
		);
		
	MSTLIsGreen <= (((NOT SSCS OR NOT MSTLReachedEnd) AND (STDtransitoryMSTL(1) AND NOT STDtransitoryMSTL(0))) OR 
	(SSTReachedEnd OR (NOT STDtransitoryMSTL(1) OR NOT STDtransitoryMSTL(0)))) AND NOT (MSTLIsYellow OR STDtransitorySSTL(1) OR STDtransitorySSTL(0));
	
	MSTLIsYellow <= (((SSCS AND MSTLReachedEnd) AND (STDtransitoryMSTL(1) AND NOT STDtransitoryMSTL(0))) OR 
	(NOT MTReachedEnd AND (NOT STDtransitoryMSTL(1) AND STDtransitoryMSTL(0))));
	
	MSTLIsRed <= (MTReachedEnd AND (NOT STDtransitoryMSTL(1) AND STDtransitoryMSTL(0))) OR 
	((NOT SSTReachedEnd OR NOT SSTLReachedEnd) AND (NOT STDtransitoryMSTL(1) AND NOT STDtransitoryMSTL(0)));
	
	
	d_FF_MSTL_High : d_FF
		PORT MAP (
			i_d => MSTLIsGreen, 
			i_clock => GClock, 
			o_q => STDtransitoryMSTLDecider(1), 
			o_qBar => open
		);
		
	d_FF_MSTL_Low : d_FF
		PORT MAP (
			i_d => MSTLIsYellow, 
			i_clock => GClock, 
			o_q => STDtransitoryMSTLDecider(0), 
			o_qBar => open
		);
		
	transitoryMSTL <= to_bitvector(STDtransitoryMSTLDecider);
	
	SSTLIsGreen <= (MTReachedEnd AND (NOT STDtransitorySSTL(1) AND NOT STDtransitorySSTL(0))) OR 
	(NOT SSTLReachedEnd AND (STDtransitorySSTL(1) AND NOT STDtransitorySSTL(0)));
	
	SSTLIsYellow <= (SSTLReachedEnd AND (STDtransitorySSTL(1) AND NOT STDtransitorySSTL(0))) OR 
	(NOT SSTReachedEnd AND (NOT STDtransitorySSTL(1) AND STDtransitorySSTL(0)));	
	
	d_FF_SSTL_High : d_FF
		PORT MAP (
			i_d => SSTLIsGreen, 
			i_clock => GClock, 
			o_q => STDtransitorySSTLDecider(1), 
			o_qBar => open
		);
		
	d_FF_SSTL_Low : d_FF
		PORT MAP (
			i_d => SSTLIsYellow, 
			i_clock => GClock, 
			o_q => STDtransitorySSTLDecider(0), 
			o_qBar => open
		);
		
	transitorySSTL <= to_bitvector(STDtransitorySSTLDecider);
	
	SSTL(0) <= NOT STDtransitorySSTLDecider(1) AND NOT STDtransitorySSTLDecider(0);
	SSTL(1) <= STDtransitorySSTLDecider(0);
	SSTL(2) <= STDtransitorySSTLDecider(1);
	MSTL(0) <= NOT STDtransitoryMSTLDecider(1) AND NOT STDtransitoryMSTLDecider(0);
	MSTL(1) <= STDtransitoryMSTLDecider(0);
	MSTL(2) <= STDtransitoryMSTLDecider(1);
	
	displayOnBCD <= transitoryMSLT OR transitoryMTTT OR transitorySSLT OR transitorySSTT;
	
	BCD_to_7Segment_inst : BCD_to_7Segment
		PORT MAP (
			A_in => displayOnBCD,
			seg => SegmentOut
		);
	
	
end basic;