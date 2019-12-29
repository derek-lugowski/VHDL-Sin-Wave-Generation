library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity add_and_subtract is
	port(
		clk					: in std_logic;
		reset					: in std_logic;
		enable				: in std_logic;
		skip_value			: in std_logic_vector(8 downto 0);
		index_out			: out std_logic_vector(14 downto 0);
		state_out			: out std_logic
		);
end entity;

architecture logic of add_and_subtract is

signal sin_table_index : std_logic_vector(14 downto 0) := (others => '0');
signal state : std_logic := '0';

begin

index_out <= sin_table_index;
state_out <= state;
counter : process(clk)
begin
	if(rising_edge(clk)) then
		if(reset = '1') then
			sin_table_index <= (others => '0');
			state <= '0';
		else
			if(unsigned(sin_table_index) + unsigned(skip_value) > 18000) then --end of count
				sin_table_index <= std_logic_vector(unsigned(sin_table_index) + unsigned(skip_value) - 18001);
				if(state = '0') then
					state <= '1';
				else
					state <= '0';
				end if;
			else --normal counting
				sin_table_index <= std_logic_vector(unsigned(sin_table_index) + unsigned(skip_value));
				state <= state;
			end if;
		end if;
	end if;
end process;



--add_or_sub : process(clk)
--begin
--	if(rising_edge(clk)) then
--		if(reset = '1') then
--			sin_table_index <= (others => '0');
--		elsif(enable = '1') then
--		
--			if(state = "00") then
--				if(sin_table_index > std_logic_vector(8999 - unsigned(skip_value))) then --switch to next state
--					sin_table_index <= std_logic_vector(to_unsigned(8999, 14)); --or just use  std_logic_vector(17998-unsigned(skip_value)-unsigned(sin_table_index))
--					state <= "01";
--				else
--					sin_table_index <= std_logic_vector(unsigned(sin_table_index) + unsigned(skip_value)); -- continue in state
--					state <= "00";
--				end if;
--				
--			elsif(state = "01") then
--				if(sin_table_index < skip_value) then --switch to next state
--					sin_table_index <= (others => '0');-- or just use  std_logic_vector(unsigned(skip_value)-unsigned(sin_table_index))
--					state <= "10";
--				else
--					sin_table_index <= std_logic_vector(unsigned(sin_table_index) - unsigned(skip_value));
--					state <= "01";
--				end if;
--			
--			elsif(state = "10") then 
--				if(sin_table_index < std_logic_vector(8999 - unsigned(skip_value))) then --switch to next state
--					sin_table_index <= std_logic_vector(to_unsigned(8999, 14)); --std_logic_vector(17998 - unsigned(skip_value) - unsigned(sin_table_index))
--					state <= "11";
--				else
--					sin_table_index <= std_logic_vector(unsigned(sin_table_index) + unsigned(skip_value));
--					state <= "10";
--				end if;
--			
--			elsif(state = "11") then
--				if(sin_table_index < skip_value) then --switch to next state
--					sin_table_index <= (others => '0'); --std_logic_vector(unsigned(skip_value) - unsigned(sin_table_index))
--					state <= "00";
--				else
--					sin_table_index <= std_logic_vector(unsigned(sin_table_index) - unsigned(skip_value));
--					state <= "11";
--				end if;
--			end if;
--		end if;
--	end if;
--end process;

end logic;