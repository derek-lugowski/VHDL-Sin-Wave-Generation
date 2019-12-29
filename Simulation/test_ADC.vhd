
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity test_DE10_Lite is
    Port(      MAX10_CLK1_50		 : in  STD_LOGIC;
					response_valid_out : out STD_LOGIC;		-- added this line
					ADC_out				 : out STD_LOGIC_VECTOR (11 downto 0)
					);
End entity;
ARCHITECTURE behavior OF test_DE10_Lite IS
Signal counter:STD_LOGIC_VECTOR(3 downto 0):=(others=>'0');
Signal response_valid_out_i : std_logic;
begin

response_valid_out <= response_valid_out_i;
      response_valid_out_process: process -- This models a 1 MSps ADC output
         begin                            -- However, your ADC has 25 kHz ADC output
              response_valid_out_i<='0';
              wait for 980 ns;
              response_valid_out_i<='1';
              wait for 20 ns; 
      end process;
		
		  ADC_out(11 downto 3)<="100011000";
		  
		ADC_out_process  :Process (response_valid_out_i)
			begin
			if rising_edge(response_valid_out_i) then
					Case counter is
						when "0000" => 
							ADC_out(2 downto 0)<="000";
							counter<="0001";
						when "0001" => 
							ADC_out(2 downto 0)<="100";
							counter<="0010";							
						when "0010" => 
							ADC_out(2 downto 0)<="010";
							counter<="0011";
						when "0011" => 
							ADC_out(2 downto 0)<="000";
							counter<="0100";
						when "0100" => 
							ADC_out(2 downto 0)<="111";
							counter<="0101";
						when "0101" =>
							ADC_out(2 downto 0)<="101";
							counter<="0110";
						when "0110" => 
							ADC_out(2 downto 0)<="011";
							counter<="0111";
						when "0111" => 
							ADC_out(2 downto 0)<="110";
							counter<="1000";
						when "1000" => 
							ADC_out(2 downto 0)<="110";
							counter<="1001";
						when "1001" => 
							ADC_out(2 downto 0)<="101";
							counter<="1011";
						When others => 
							ADC_out(2 downto 0)<="111";
							counter<="0000";
					End Case;
				end if;
		 End Process;
		  
		  

end behavior;