library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity tb_volt2dist is
end tb_volt2dist;

architecture behaviour of tb_volt2dist is 


component volt2dist is
	port(
		volt		: in	std_logic_vector(11 downto 0);
		dist		: out	std_logic_vector(12 downto 0)
		);
end component;

           


signal	volt	: 	std_logic_vector(11 downto 0);
signal	dist	:	std_logic_vector(12 downto 0);

begin

uut_volt2dist: volt2dist PORT MAP(

volt => volt,
dist => dist
);



volt2dist_process: process 
begin
wait for 10 ns;
volt <= "000000000000";
wait for 10 ns;
volt <= "111000111000";
wait for 10 ns;
end process;

end behaviour;


