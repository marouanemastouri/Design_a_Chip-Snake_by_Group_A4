library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL; 

architecture behaviour of h_cnt_control_tb is
   component h_cnt_control
      port(clk           : in  std_logic;
           reset         : in  std_logic;
           h_count       : in  std_logic_vector(8 downto 0);
           h_sync        : out std_logic;
           h_count_reset : out std_logic;
           h_video_on    : out std_logic);
   end component;
   signal clk           : std_logic;
   signal reset         : std_logic;
   signal h_count       : std_logic_vector(8 downto 0);
   signal h_sync        : std_logic;
   signal h_count_reset : std_logic;
   signal h_video_on    : std_logic;
	signal hcount, new_hcount:  unsigned(8 downto 0);

begin
test: h_cnt_control port map (clk, reset, h_count, h_sync, h_count_reset, h_video_on);
   clk <=	'1' after 0 ns,
			 '0' after 40 ns when clk /= '0' else '1' after 40 ns;
   reset <=	'1' after 0 ns,
				'0' after 80 ns;

-- process intended to generate the horizontal counter
	process(clk) begin
		if(clk = '1' and clk'event) then
			if(reset = '1') then
				hcount <= (others => '0');
			else
				hcount <= new_hcount;
			end if;
		end if;	
	end process;
	
	process(h_count, h_count_reset)begin
		if(h_count_reset) then
			new_hcount <= (others => '0');
		else
				new_hcount <= hcount + 1;
		end if;
	end process;
	h_count <= std_logic_vector(hcount);

end behaviour;

