library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity voltage2bcd is 
	
	port (
		voltageRawIN	: in 	std_logic_vector(11 downto 0);
		clk, reset, response_valid_out		: in 	std_logic;
		sel					: in 	std_logic_vector(0 to 1);
		VoltageAvgOut		: out	std_logic_vector(11 downto 0);    --voltageAvgOut is the output to the LED's
		binaryOut			: out std_logic_vector(12 downto 0);
		bcdOut				: out std_logic_vector(15 downto 0);
		distanceOut			: out std_logic_vector(12 downto 0)
		);
end entity;


architecture connections of voltage2bcd is

signal AvgVoltage, voltage 	: std_logic_vector(11 downto 0);
signal distance, voltage_mult, binary	: std_logic_vector(12 downto 0);
--signal 				: std_logic_vector(

Component averager is
  port(
    clk, reset : in std_logic;
    Din : in  std_logic_vector(11 downto 0);
    EN  : in  std_logic; -- response_valid_out
    Q   : out std_logic_vector(11 downto 0)
    );
  end Component;

Component mux is
	generic(bits : integer);
	port(
		sel	: in std_logic;
		A		: in std_logic_vector(bits-1 downto 0);
		B		: in std_logic_vector(bits-1 downto 0);
		C		: out std_logic_vector(bits-1 downto 0)
		);
	end component;

component volt2dist is 
	port(
		volt		: in	std_logic_vector(11 downto 0);
		dist		: out	std_logic_vector(12 downto 0)
		);
end component;

Component binary_bcd IS
   PORT(
      clk     : IN  STD_LOGIC;                      --system clock
      reset   : IN  STD_LOGIC;                      --active low asynchronus reset
      ena     : IN  STD_LOGIC;                      --latches in new binary number and starts conversion
      binary  : IN  STD_LOGIC_VECTOR(12 DOWNTO 0);  --binary number to convert
      busy    : OUT STD_LOGIC;                      --indicates conversion in progress
      bcd     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)   --resulting BCD number
		);           
END Component;


begin
avg : averager
			port map(
					clk       => clk,
               reset     => reset,
               Din       => voltageRawIN,
               EN        => response_valid_out,
               Q         => AvgVoltage
               );

mux_avg: mux 
				generic map(bits => 12)
				PORT MAP(
						sel	=> sel(0),
						A		=> voltageRawIN,
						B		=> AvgVoltage,
						C		=> voltage
						);

volt_to_dist: volt2dist
				port map(
					volt		=> voltage,
					dist		=> distance
					);


mux_dist: mux
				generic map(bits => 13)
				port map(
					sel		=> sel(1),
					A			=> voltage_mult,
					B			=>	distance,
					C			=> binary
					);
					
					
binary_bcd_ins: binary_bcd                               
   PORT MAP(
      clk      => clk,                          
      reset    => reset,                                 
      ena      => '1',                           
      binary   => binary,    
      busy     => open,                         
      bcd      => bcdOut    
      );
distanceOut <= distance;
binaryOut <= binary;	
voltage_mult <= std_logic_vector(resize(unsigned(voltage)*2500*2/4096,voltage_mult'length));
VoltageAvgOut <= AvgVoltage;
end connections;