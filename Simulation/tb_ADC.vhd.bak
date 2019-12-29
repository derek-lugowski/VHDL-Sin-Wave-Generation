library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
 

entity tb_DE10_Lite is
end tb_DE10_Lite;

architecture Behavioral of tb_DE10_Lite is
    constant clk_period: time:=20ns; -- 50 MHz
component test_DE10_Lite is
    Port(      
					MAX10_CLK1_50		 : in STD_LOGIC;
					response_valid_out : out STD_LOGIC; -- added this line
					ADC_out				 : out STD_LOGIC_VECTOR (11 downto 0)
					);
End component;

Signal	clk:  								STD_LOGIC;
Signal	response_valid_out_i1:	    	STD_LOGIC_VECTOR (0  downto 0);
Signal 	ADC_read:  							STD_LOGIC_VECTOR (11 downto 0);

begin

DE10_Lite_ins: 	test_DE10_Lite  PORT MAP( 
						 --ADC_CLK_10			=>			ADC_CLK_10,
						 MAX10_CLK1_50			=>			clk,
						 --MAX10_CLK2_50		=>			MAX10_CLK2_50,
						 response_valid_out  =>       response_valid_out_i1(0), -- added this line
						 ADC_out					=>			ADC_read);
clk_process: process
	 begin
		  clk<='0';
		  wait for clk_period/2;
		  clk<='1';
		  wait for clk_period/2;
end process; 												 

												 
end behavioral;
