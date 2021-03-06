library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity tb_voltmeter is
end tb_voltmeter;

architecture behaviour of tb_voltmeter is 
	constant clk_period: time:=20ns;

component Voltmeter is
    Port ( clk                           : in  STD_LOGIC;
           reset                         : in  STD_LOGIC;
           LEDR                          : out STD_LOGIC_VECTOR (9 downto 0);
           HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : out STD_LOGIC_VECTOR (7 downto 0);
	--added for switch
	switch : in STD_LOGIC_vector (0 to 1)
          );
           
end component;

	signal clk: std_logic;
	signal reset: std_logic;
	signal led: std_logic_vector (9 downto 0);
	signal hex0, hex1, hex2, hex3, hex4, hex5 : std_logic_vector (7 downto 0);
	signal switch: std_logic_vector(0 to 1);

begin


voltmeter_instance: Voltmeter PORT MAP(
		clk	=> clk,
		reset	=> reset,
		LEDR	=> led,
		hex0	=> hex0,
		hex1	=> hex1,
		hex2	=> hex2,
		hex3	=> hex3,
		hex4	=> hex4,
		hex5	=> hex5,
--add switch to port map due to mux being added
		switch => switch
--end of code change
		);

clk_process: process

begin
	clk <= '0';
	wait for clk_period/2;
	clk <= '1';
	wait for clk_period/2;
end process;

reset_process: process
begin
	reset <= '0';
	wait for 10*clk_period;
	reset <= '1';
	wait for 10*clk_period;
	reset <= '0';
	wait;
end process;

switch_process: process
begin
	switch <= "00";
	wait for clk_period*5;
	switch <= "01";
	wait for clk_period*5;
	switch <= "10";
	wait for clk_period*5;
	switch <= "11";
	wait for clk_period*5;

end process;
--end of code change



end behaviour;