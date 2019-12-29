--Lab5 project for ENEL453
--Authors:
--Derek Lugowski
--Sarah Price


--Top level design file:

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
 
entity sin_gen is
    Port ( clk                           : in  STD_LOGIC; --"single wire"
           reset                         : in  STD_LOGIC; --"single wire"
           LEDR                          : out STD_LOGIC_VECTOR (9 downto 0); --vector with 10 elements
           HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : out STD_LOGIC_VECTOR (7 downto 0); --vector with 8 elements 
			  --sw                            : in std_logic;
			  switch								  : in STD_LOGIC_vector (2 downto 0);
			  arduino_io						  : out std_logic_vector(9 downto 0)
          );
           
end sin_gen;

architecture Behavioral of sin_gen is --Concurent statements describing logic functions

--7 internal signals that are a vector with 4 elements that uses aggregate assignment - all are assigned to 0
Signal Num_Hex0, Num_Hex1, Num_Hex2, Num_Hex3, Num_Hex4, Num_Hex5 :   STD_LOGIC_VECTOR (3 downto 0):= (others=>'0');   
--1 internal signal that is a vector with 5 elements, it is not given an intial value
--Signal DP_in_volt, dp_in_dist, dp_in :   STD_LOGIC_VECTOR (5 downto 0);
--4 internal signals that are a vector with 12 elements
Signal ADC_read,rsp_data,q_outputs_1,q_outputs_2 : STD_LOGIC_VECTOR (11 downto 0);
--1 internal signal that is a vector with 13 elements
--Signal voltage: STD_LOGIC_VECTOR (12 downto 0);
--1 internal signal that is not a vector unlike all the others above
--Signal busy, busy2: STD_LOGIC;
--3 internal signals that are vectors but can only hold 1 element, just one bit
signal response_valid_out_i1,response_valid_out_i2,response_valid_out_i3 : STD_LOGIC_VECTOR(0 downto 0);
--1 interal signal that is a vector with 16 elements
Signal bcd: STD_LOGIC_VECTOR(15 DOWNTO 0);
--1 internal signal that is a vector with 12 elements
Signal Q_temp1 : std_logic_vector(11 downto 0);
signal switch1, switch2 : std_logic_vector(2 downto 0);
signal sel_volt2bcd : std_logic_vector(1 downto 0);
signal pwm_out_square, pwm_out_sawtooth, pwm_out_triangle, enable_square, enable_sawtooth, enable_triangle : std_logic;


Component SevenSegment is
    Port( switch																 : in std_logic;
			 Num_Hex0,Num_Hex1,Num_Hex2,Num_Hex3,Num_Hex4,Num_Hex5 : in  STD_LOGIC_VECTOR (3 downto 0); --internal signals
          Hex0,Hex1,Hex2,Hex3,Hex4,Hex5                         : out STD_LOGIC_VECTOR (7 downto 0) --physical, declared in entity
          --DP_in                                                 : in  STD_LOGIC_VECTOR (5 downto 0) --interal signal
			);
End Component ;

--Component test_de10_lite is
Component ADC_Conversion is
    Port( MAX10_CLK1_50      : in STD_LOGIC;
          response_valid_out : out STD_LOGIC; --correspond to internal response_valid_out_i1, etc...?
          ADC_out            : out STD_LOGIC_VECTOR (11 downto 0) --not in signal list above?
         );
End Component ;

--Component binary_bcd IS
--   PORT(
--      clk     : IN  STD_LOGIC;                      --system clock
--      reset   : IN  STD_LOGIC;                      --active low asynchronus reset
--      ena     : IN  STD_LOGIC;                      --latches in new binary number and starts conversion
--      binary  : IN  STD_LOGIC_VECTOR(12 DOWNTO 0);  --binary number to convert
--      busy    : OUT STD_LOGIC;                      --indicates conversion in progress
--      bcd     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)   --resulting BCD number
--		);           
--END Component;

Component registers is
   generic(bits : integer);
   port
     ( 
      clk       : in  std_logic;
      reset     : in  std_logic;
      enable    : in  std_logic;
      d_inputs  : in  std_logic_vector(bits-1 downto 0);
      q_outputs : out std_logic_vector(bits-1 downto 0)  
     );
END Component;

--Component averager is
--  port(
--    clk, reset : in std_logic;
--    Din : in  std_logic_vector(11 downto 0);
--    EN  : in  std_logic; -- response_valid_out
--    Q   : out std_logic_vector(11 downto 0)
--    );
--  end Component;

--Component mux is
--	generic(bits : integer);
--	port(
--		sel	: in std_logic;
--		A		: in std_logic_vector(bits-1 downto 0);
--		B		: in std_logic_vector(bits-1 downto 0);
--		C		: out std_logic_vector(bits-1 downto 0)
--		);
--	end component;

--component volt2dist is 
--	port(
--		volt		: in	std_logic_vector(11 downto 0);
--		dist		: out	std_logic_vector(12 downto 0)
--		);
--end component;
  
component voltage2bcd is 
	
	port (
		voltageRawIN						: in 	std_logic_vector(11 downto 0);
		clk, reset, response_valid_out: in 	std_logic;
		sel									: in 	std_logic_vector(0 to 1);
		VoltageAvgOut						: out	std_logic_vector(11 downto 0);    --voltageAvgOut is the output to the LED's
		binaryOut							: out std_logic_vector(12 downto 0);
		bcdOut								: out std_logic_vector(15 downto 0);
		distanceOut							: out std_logic_vector(12 downto 0)
		);
end component;
  
--component square_wave_gen is
--	port(	clk		: in		std_logic;
--			reset		: in		std_logic;
--			buttons	: in		std_logic_vector(1 downto 0);
--			switch	: in		std_logic;
--			enable	: in		std_logic;
--			pwm_out	: out		std_logic
--			);
--end component;
--  
--  
--component pwm_sawtooth is
--	port(
--		clk		: in		std_logic;
--		reset		: in		std_logic;
--		buttons	: in		std_logic_vector(1 downto 0);
--		enable	: in		std_logic;
--		pwm_out	: out		std_logic
--		);
--end component;
--  
--component pwm_triangle is 
--	port(
--		clk		: in	std_logic;
--		reset		: in	std_logic;
--		buttons	: in	std_logic_vector(1 downto 0);
--		enable	: in	std_logic;
--		pwm_out	: out	std_logic
--		);
--end component;
--
--component pwm_buzzer is
--	port(	clk		: in		std_logic;
--			reset		: in		std_logic;
--			switch	: in		std_logic;
--			voltage_in:in		std_logic_vector(11 downto 0);
--			enable	: in		std_logic;
--			pwm_out	: out		std_logic
--			);
--end component;

component voltage2sin is

	port(
		volt_avg_in				: in	std_logic_vector(11 downto 0);
		clk, reset, enable	: in	std_logic;
		switch					: in std_logic;
		sin_out					: out	std_logic_vector(9 downto 0)
		);
end component;

begin
   Num_Hex0 <= bcd(3  downto  0); 
   Num_Hex1 <= bcd(7  downto  4);
   Num_Hex2 <= bcd(11 downto  8);
   Num_Hex3 <= bcd(15 downto 12);
   Num_Hex4 <= "1111";  -- blank this display
   Num_Hex5 <= "1111";  -- blank this display   
--   DP_in_volt    <= "001000";-- position of the decimal point in the display
--	DP_in_dist	  <= "000100";
                  
   
--ave :    averager
--         port map(
--                  clk       => clk,
--                  reset     => reset,
--                  Din       => q_outputs_2,
--                  EN        => response_valid_out_i3(0),
--                  Q         => Q_temp1
--                  );
   
sync1 : registers 
        generic map(bits => 12)
        port map(
                 clk       => clk,
                 reset     => reset,
                 enable    => '1',
                 d_inputs  => ADC_read,
                 q_outputs => q_outputs_1
                );

sync2 : registers 
        generic map(bits => 12)
        port map(
                 clk       => clk,
                 reset     => reset,
                 enable    => '1',
                 d_inputs  => q_outputs_1,
                 q_outputs => q_outputs_2

                );
                
sync3 : registers
        generic map(bits => 1)
        port map(
                 clk       => clk,
                 reset     => reset,
                 enable    => '1',
                 d_inputs  => response_valid_out_i1,
                 q_outputs => response_valid_out_i2
                );

sync4 : registers
        generic map(bits => 1)
        port map(
                 clk       => clk,
                 reset     => reset,
                 enable    => '1',
                 d_inputs  => response_valid_out_i2,
                 q_outputs => response_valid_out_i3
                );   
sync5 : 	registers
			generic map(bits => 3)
			port map(
						clk		=> clk,
						reset		=> reset,
						enable	=> '1',
						d_inputs => switch,
						q_outputs => switch1
						);
sync6	:	registers
			generic map(bits =>3)
			port map(
						clk		=> clk,
						reset		=> reset,
						enable	=> '1',
						d_inputs	=> switch1,
						q_outputs => switch2
						);
                
SevenSegment_ins: SevenSegment  
                  PORT MAP( switch	 => switch2(1),
									 Num_Hex0 => Num_Hex0,
                            Num_Hex1 => Num_Hex1,
                            Num_Hex2 => Num_Hex2,
                            Num_Hex3 => Num_Hex3,
                            Num_Hex4 => Num_Hex4,
                            Num_Hex5 => Num_Hex5,
                            Hex0     => Hex0,
                            Hex1     => Hex1,
                            Hex2     => Hex2,
                            Hex3     => Hex3,
                            Hex4     => Hex4,
                            Hex5     => Hex5
--                            DP_in    => DP_in
                          );
                                     
--ADC_Conversion_ins:  test_de10_lite  PORT MAP(      
ADC_Conversion_ins:  ADC_Conversion  PORT MAP(
                                     MAX10_CLK1_50       => clk,
                                     response_valid_out  => response_valid_out_i1(0),
                                     ADC_out             => ADC_read);
 
LEDR(9 downto 0) <=Q_temp1(11 downto 2); -- gives visual display of upper binary bits to the LEDs on board

-- in line below, can change the scaling factor (i.e. 2500), to calibrate the voltage reading to a reference voltmeter
--voltage <= std_logic_vector(resize(unsigned(mux_out)*2500*2/4096,voltage'length));  -- Converting ADC_read a 12 bit binary to voltage readable numbers

--mux_avg: mux 
--				generic map(bits => 12)
--				PORT MAP(
--						sel	=> switch2(0),
--						A		=> q_outputs_2,
--						B		=> q_temp1,
--						C		=> mux_out
--						);

						
--mux_dist: mux
--				generic map(bits => 13)
--				port map(
--					sel		=> switch2(1),
--					A			=> voltage,
--					B			=>	distance,
--					C			=> mux_out2
--					);
--mux_dist_dp: mux
--				generic map(bits=> 6)
--				port map(
--					sel => switch2(1),
--					A 	=> dp_in_volt,
--					B	=> dp_in_dist,
--					C	=> dp_in
--					);
					
					
--volt_to_dist: volt2dist
--				port map(
--					volt		=> mux_out,
--					dist		=> distance
--					);
					

sel_volt2bcd(0) <= switch2(0);
sel_volt2bcd(1) <= switch2(1);
					
volt_to_bcd: voltage2bcd
	port map(
		voltageRawIN			=>	q_outputs_2,
		clk						=>	clk,
		reset						=> reset,
		response_valid_out	=> response_valid_out_i3(0),
		sel						=> sel_volt2bcd,
		VoltageAvgOut			=> Q_temp1,    --voltageAvgOut is the output to the LED's
		binaryOut				=> open,
		bcdOut					=> bcd
		);
					
					
					
					
--binary_bcd_ins: binary_bcd                               
--   PORT MAP(
--      clk      => clk,                          
--      reset    => reset,                                 
--      ena      => '1',                           
--      binary   => mux_out2,    
--      busy     => busy,                         
--      bcd      => bcd    
--      );
		
--binary_bcd_ins_raw: binary_bcd
--	PORT MAP(
--		clk		=> clk,
--		reset		=> reset,
--		ena		=> '1',
--		binary	=> raw_voltage,
--		busy		=> busy2,
--		bcd		=> bcd2
--		);
--pwm_square : square_wave_gen
--	port map(
--			clk		=> clk,
--			reset		=> reset,
--			buttons	=> buttons,
--			switch	=> switch2(2),
--			enable	=> enable_square,
--			pwm_out	=> pwm_out_square--pwm_out
--			);
--		
--sawtooth_wave : pwm_sawtooth
--	port map(
--			clk		=> clk,
--			reset		=> reset,
--			buttons	=> buttons,
--			enable	=> enable_sawtooth,
--			pwm_out	=> pwm_out_sawtooth
--			);
--			
--triangle_wave : pwm_triangle
--	port map(
--		clk			=> clk,
--		reset			=> reset,
--		buttons		=> buttons,
--		enable		=> enable_triangle,
--		pwm_out		=> pwm_out_triangle
--		);
--			
--pwm_out_select : process(clk)
--begin
--	if(rising_edge(clk)) then
--		if(		switch2(3) = '0' and switch2(4) = '0'	) then -- 00 = square
--			enable_sawtooth <= '0';
--			enable_square <= '1';
--			enable_triangle <= '0';
--			ARDUINO_IO(0) <= pwm_out_square;
--		elsif(	switch2(3) = '0' and switch2(4) = '1'	) then -- 01 = sawtooth
--			ARDUINO_IO(0) <= pwm_out_sawtooth;
--			enable_sawtooth <= '1';
--			enable_square <= '0';
--			enable_triangle <= '0';
--		elsif(	switch2(3) = '1' and switch2(4) = '1'	) then -- 11 = triangle
--			ARDUINO_IO(0) <= pwm_out_triangle;
--			enable_sawtooth <= '0';
--			enable_square <= '0';
--			enable_triangle <= '1';
--		else																	 -- 10 = disable
--			ARDUINO_IO(0) <= '0';
--			enable_sawtooth <= '0';
--			enable_square <= '0';
--			enable_triangle <= '0';
--		end if;
--	end if;
--end process;


--buzzer :  pwm_buzzer
--	port map(
--			clk			=> clk,		--: in		std_logic;
--			reset			=> reset,		--: in		std_logic;
--			switch		=> switch2(5),		--: in		std_logic;
--			voltage_in	=> Q_temp1,		--:in		std_logic_vector(11 downto 0);
--			enable		=> '1',		--: in		std_logic;
--			pwm_out		=> ARDUINO_IO(1)		--: out		std_logic
--			);

sin_generation : voltage2sin
	port map(
		volt_avg_in => Q_temp1,
		clk			=> clk,
		reset			=> reset,
		enable		=> '1',
		switch		=> switch(2),
		sin_out		=> arduino_io
		);

		
end Behavioral;


