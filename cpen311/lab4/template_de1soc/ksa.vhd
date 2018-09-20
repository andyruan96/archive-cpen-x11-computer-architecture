library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ksa is
  port(
    CLOCK_50            : in  std_logic;  -- Clock pin
    KEY                 : in  std_logic_vector(3 downto 0);  -- push button switches
    SW                 : in  std_logic_vector(9 downto 0);  -- slider switches
    LEDR : out std_logic_vector(9 downto 0);  -- red lights
    HEX0 : out std_logic_vector(6 downto 0);
    HEX1 : out std_logic_vector(6 downto 0);
    HEX2 : out std_logic_vector(6 downto 0);
    HEX3 : out std_logic_vector(6 downto 0);
    HEX4 : out std_logic_vector(6 downto 0);
    HEX5 : out std_logic_vector(6 downto 0));
end ksa;

architecture rtl of ksa is
   COMPONENT SevenSegmentDisplayDecoder IS
    PORT
    (
        ssOut : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        nIn : IN STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
    END COMPONENT;
	
	COMPONENT lab4 IS
	PORT(
		clock: IN STD_LOGIC;
		reset: IN STD_LOGIC;
		ledr: OUT STD_LOGIC_VECTOR(9 downto 0);
		out_key_value: OUT STD_LOGIC_VECTOR(23 downto 0)
	);
	END COMPONENT;
	
    -- clock and reset signals  
	 signal clk, reset_n : std_logic;
	 signal secret_key_value: std_LOGIC_VECTOR(23 downto 0); 
									
	
begin

    clk <= CLOCK_50;
    reset_n <= KEY(3);
	
	
	lab4_init: lab4
		port map(
		clk,
		reset_n,
		LEDR,
		secret_key_value
		);
	
	hex0_init: SevenSegmentDisplayDecoder
		port map(
			HEX0,
			secret_key_value(3 downto 0)
		);
	hex1_init: SevenSegmentDisplayDecoder
		port map(
			HEX1,
			secret_key_value(7 downto 4)
		);
	hex2_init: SevenSegmentDisplayDecoder
		port map(
			HEX2,
			secret_key_value(11 downto 8)
		);
	hex3_init: SevenSegmentDisplayDecoder
		port map(
			HEX3,
			secret_key_value(15 downto 12)
		);
	hex4_init: SevenSegmentDisplayDecoder
		port map(
			HEX4,
			secret_key_value(19 downto 16)
		);
	hex5_init: SevenSegmentDisplayDecoder
		port map(
			HEX5,
			secret_key_value(23 downto 20)
		);

end RTL;


