library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is 

	generic(bits : integer := 1);
	
	port (
		sel	: in 	std_logic;
		A		: in 	std_logic_vector(bits-1 downto 0);
		B		: in 	std_logic_vector(bits-1 downto 0);
		C		: out	std_logic_vector(bits-1 downto 0)
		);
	end entity;
	
	
architecture behaviour of mux is

	begin
mux :	process(sel, A, B)
		begin
		case sel is
			when '0' => C <= B;
			when '1' => C <= A;
			when others => C <= (others => '0');
				
		end case;
		
	end process mux;

end behaviour;