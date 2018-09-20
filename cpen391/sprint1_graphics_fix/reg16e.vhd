library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg16e is
   port
   (
      Clk : in std_logic;
      E : in std_logic;
      D : in std_logic;
      Q : out std_logic
   );
end entity reg16e;
 
architecture Behavioral of reg16e is
begin
   process (clk) is
   begin
      if rising_edge(clk) then  
         if (E='1') then   
            Q <= D;
         end if;
      end if;
   end process;
end architecture Behavioral;