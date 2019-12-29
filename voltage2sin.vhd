library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity voltage2sin is

	port(
		volt_avg_in				: in	std_logic_vector(11 downto 0);
		clk, reset, enable	: in	std_logic;
		switch					: in std_logic;
		sin_out					: out	std_logic_vector(9 downto 0)
		);
end entity;

architecture connections of voltage2sin is

-- ~~~ SIGNALS ~~~ --
signal skip_value_from_table, skip_value : std_logic_vector(8 downto 0);
signal sin_table_index : std_logic_vector(14 downto 0);
signal state  : std_logic := '0';
signal sin_from_table : std_logic_vector(4 downto 0);
signal sin_multiplied : std_logic_vector(9 downto 0);
signal amplitude_from_table, amplitude : std_logic_vector(4 downto 0);
--signal sin_MSB : std_logic_vector(8 downto 0);
signal sin_offset, sin_MSB_padded : std_logic_vector(9 downto 0);



--constant offset : 
-- ~~~ COMPONENTS ~~~ --
component LUT_skip is 
	port(
		index		: in	std_logic_vector(11 downto 0);
		skip		: out	std_logic_vector(8 downto 0)
		);
end component;

component sinval IS
   PORT(
      clk            :  IN    STD_LOGIC;                                
      reset          :  IN    STD_LOGIC;                                
      index          :  IN    STD_LOGIC_VECTOR(14 DOWNTO 0);                       
      sin            :  OUT   STD_LOGIC_VECTOR(4 DOWNTO 0));
END component;

component add_and_subtract is
	port(
		clk					: in std_logic;
		reset					: in std_logic;
		enable				: in std_logic;
		skip_value			: in std_logic_vector(8 downto 0);
		index_out			: out std_logic_vector(14 downto 0);
		state_out			: out std_logic
		);
end component;

component ampfactor IS
   PORT(                                
      distance       :  IN    STD_LOGIC_VECTOR(11 DOWNTO 0);                       
      ampfac         :  OUT   STD_LOGIC_VECTOR(4 DOWNTO 0));
END component;

-- ~~~ BEGIN ~~~ --
begin

sin_multiplied <= std_logic_vector(unsigned(amplitude) * unsigned(sin_from_table));

--sin_MSB <= sin_multiplied(19 downto 11);
--sin_MSB_padded <= std_logic_vector(resize(signed(sin_multiplied), 10));

sin_out <= sin_offset;						--std_logic_vector(signed(sin_MSB_padded) + 511);





--sin_out <= sin_multiplied(19 downto 10);

offset : process(clk)
begin
	if(rising_edge(clk)) then
		if(reset = '1') then
			sin_offset <= (others => '0');
		else -- not reset
			if(state = '0') then --positive sin wave
				sin_offset <= std_logic_vector(511 + unsigned(sin_multiplied));
			else --negitive sin wave
				sin_offset <= std_logic_vector(511 - unsigned(sin_multiplied));
			end if;
		end if;
	end if;
end process;

mux_amplitude_switch : process(clk)
begin
	if(rising_edge(clk)) then
		if(switch = '0') then
			amplitude <= amplitude_from_table;
		else
			amplitude <= "11111";
		end if;
	end if;
end process;


mux_frequency_switch : process(clk)
begin
	if(rising_edge(clk)) then
		if(switch = '1') then
			skip_value <= skip_value_from_table;
		else
			skip_value <= std_logic_vector(to_unsigned(468, 9));
		end if;
	end if;
end process;



skip_lookup : LUT_skip
		port map(
			index		=>	volt_avg_in,
			skip		=>	skip_value_from_table
		);

sin_table : sinval
		port map(
			clk 	=> clk,
			reset	=> reset,
			index	=> sin_table_index,
			sin	=> sin_from_table
			);
		
index_skip : add_and_subtract
		port map(
			clk		=> clk,
			reset		=> reset,
			enable	=> '1',
			skip_value=> skip_value,
			index_out=> sin_table_index,
			state_out=> state
			);
		
LUT_amplify : ampfactor
		port map(
			distance		=> volt_avg_in,
			ampfac		=> amplitude_from_table
			);

end connections;