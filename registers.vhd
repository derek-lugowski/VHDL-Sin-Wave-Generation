-- in the process 'clk' was the only signal on the sensitivity list.
-- but in the code the reset was setup to be asynchronous.
-- this can be fixed by adding reset to the sensitivity list or by making the reset synchronous.
-- We chose to make the reset synchronous.
-- We added to the if statement to make it:
-- if (rising_edge(clk) and reset = '1') then ... to make it synchronous.

library ieee;
use ieee.std_logic_1164.all;

entity registers is

generic(bits : integer := 1);
 
port( 
	  clk       : in  std_logic;
	  reset     : in  std_logic;
	  enable    : in  std_logic;
     d_inputs  : in  std_logic_vector(bits-1 downto 0);
	  q_outputs : out std_logic_vector(bits-1 downto 0)	
    );
end entity;

architecture rtl of registers is
begin

   process (clk)
   begin
      if (rising_edge(clk) and reset = '1') then
		   q_outputs <= (others=>'0');
		elsif (rising_edge(clk)) then
		   if (enable = '1') then
            q_outputs <= d_inputs;
			end if;
      end if;
   end process;

end;
