library IEEE;
use IEEE.std_logic_1164.ALL;

architecture behaviour of mux is
	component and2 is
		port(a, b: in std_logic; z: out std_logic);
	end component;
	component or2 is
		port(a, b: in std_logic; z: out std_logic);
	end component;
	component inverter is
		port(a: in std_logic; z: out std_logic);
	end component;
signal s1, s2, s3 : std_logic;
begin
	inv_1: inverter port map (x, s1);
	and_1: and2 port map (a, s1, s2);
	and_2: and2 port map (x, b, s3);
	or_1: or2 port map (s2, s3, z);
end behaviour;

