-- --- Seven segment component
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_misc.all;

entity SevenSegment is
    Port ( switch																  : in std_logic;
			  --DP_in                                                 : in  STD_LOGIC_VECTOR (5 downto 0);
           Num_Hex0,Num_Hex1,Num_Hex2,Num_Hex3,Num_Hex4,Num_Hex5 : in  STD_LOGIC_VECTOR (3 downto 0);
           HEX0,HEX1,HEX2,HEX3,HEX4,HEX5                         : out STD_LOGIC_VECTOR (7 downto 0)
          );
end SevenSegment;


	
architecture Behavioral of SevenSegment is

--Note that component declaration comes after architecture and before begin (common source of error).
   Component SevenSegment_decoder is 
      port(  H     : out STD_LOGIC_VECTOR (7 downto 0);
             input : in  STD_LOGIC_VECTOR (3 downto 0);
             DP    : in  STD_LOGIC                               
          );                  
   end  Component;  

Component mux is
	generic(bits : integer);
	port(
		sel	: in std_logic;
		A		: in std_logic_vector(bits-1 downto 0);
		B		: in std_logic_vector(bits-1 downto 0);
		C		: out std_logic_vector(bits-1 downto 0)
		);
end component;
	
type mat1 is array (0 to 5) of std_logic_vector (3 downto 0); -- bcd number
signal Num_Hex: mat1;

type mat2 is array (0 to 5) of std_logic_vector (7 downto 0); -- segments to be lit
signal HEX: mat2;

signal z : std_logic;
signal error_sel, error_sel1: std_logic_vector(0 to 0); --internal signal for the mux

Signal DP_in_volt, dp_in_dist, dp_in :   STD_LOGIC_VECTOR (5 downto 0);

begin

Num_Hex(0) <= Num_Hex0;
Num_Hex(1) <= Num_Hex1;
Num_Hex(2) <= Num_Hex2;
--Num_Hex(3) <= Num_Hex3; -- blank when '0'
Num_Hex(4) <= Num_Hex4;
Num_Hex(5) <= Num_Hex5;


DP_in_volt    <= "001000";-- position of the decimal point in the display
DP_in_dist	  <= "000100";

--Hex0 <= Hex(0);
--Hex1 <= Hex(1);
--Hex2 <= Hex(2);
--Hex3 <= Hex(3);
--Hex4 <= Hex(4);
Hex5 <= Hex(5);

z <= or_reduce(num_hex3);
mux_blank : mux
				generic map(bits => 4)
				port map(
					sel => z,
					A 	=> Num_Hex3,
					B	=> "1111",
					C	=> Num_Hex(3)
					);

error_sel1(0) <= or_reduce(Num_Hex0) or or_reduce(Num_Hex1) or or_reduce(Num_Hex2) or or_reduce(Num_Hex3); -- error_sel = 0 for error, and 1 for no error

mux_error_sel : mux
				generic map(bits => 1)
				port map(
					sel => switch,
					A 	=> "1",
					B	=> error_sel1, -- 'E'
					C	=> error_sel
					);



mux_error4 : mux
				generic map(bits => 8)
				port map(
					sel => error_sel(0),
					A 	=> hex(4),
					B	=> "10000110", -- 'E'
					C	=> hex4
					);

mux_error3 : mux
				generic map(bits => 8)
				port map(
					sel => error_sel(0),
					A 	=> hex(3),
					B	=> "10101111", -- 'r'
					C	=> hex3
					);
					
mux_error2 : mux
				generic map(bits => 8)
				port map(
					sel => error_sel(0),
					A 	=> hex(2),
					B	=> "10101111", -- 'r'
					C	=> hex2
					);
mux_error1 : mux
				generic map(bits => 8)
				port map(
					sel => error_sel(0),
					A 	=> hex(1),
					B	=> "10100011", -- 'o'
					C	=> hex1
					);
mux_error0 : mux
				generic map(bits => 8)
				port map(
					sel => error_sel(0),
					A 	=> hex(0),
					B	=> "10101111", -- 'E'
					C	=> hex0
					);

					
mux_dist_dp: mux
				generic map(bits=> 6)
				port map(
					sel => switch,
					A 	=> dp_in_volt,
					B	=> dp_in_dist,
					C	=> dp_in
					);

--Note that port mapping begins after begin (common source of error).
gen_decoder:
for i in 0 to 5 generate
	decoderX: SevenSegment_decoder port map 
	(
		H		=> hex(i),
		input	=> Num_Hex(i),
		DP		=> DP_in(i)
	);
end generate gen_decoder;


                           
end Behavioral;