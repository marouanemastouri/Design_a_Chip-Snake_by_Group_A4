library IEEE;
use IEEE.std_logic_1164.ALL;

architecture behaviour of itemgenerator is
component shift_register is
    port (clk, reset, enable, D : in std_logic; Q : out std_logic_vector(11 downto 0));
end component;

component counter4 is
    port (clk, reset, manual_reset, enable : in std_logic; z_out: out std_logic_vector(3 downto 0));
end component;

-- component rng is
--    port (etc...)
-- end component;

    type itemGenerator_state is (IDLE, GEN_TYPE, GEN_TYPE_PU_ONE, GEN_TYPE_PU_TWO, SHIFT_FOOD_ONE, SHIFT_FOOD_TWO, GEN_LOC, SHIFT_REG_ONE, SHIFT_REG_TWO, CHECK_LOC, SEND_LOC);
    signal state, new_state: itemGenerator_state;
    signal counter_out, count_comp: std_logic_vector(3 downto 0);
    signal counter_enable, counter_reset, register_enable, register_D: std_logic;
    --signal rng_out: std_logic;  -- only enable this signal when the rng is finished 
    signal register_Q: std_logic_vector(11 downto 0);
    signal flagREE: std_logic;

begin
    
    count4: counter4 port map (clk=>clk, reset=>reset, manual_reset=>counter_reset, enable=>counter_enable, z_out=>counter_out);
    shift_reg: shift_register port map (clk=>clk, reset=>reset, enable=>register_enable, D=>register_D, Q=>register_Q);
    -- IG_rng: rng port map (etc...);

    lbl1: process (clk)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                state <= IDLE;
            else
                state <= new_state;
            end if;
        end if;
    end process;

    lbl2: process(state, item_set, req_item, item_loc_clear, item_ok, rng_out, new_item_clear, counter_out, register_Q)
    begin
        case state is
            when IDLE =>
                --------------------
                -- Initial values --
                --------------------
                item_clear <= '0';
                item_loc_set <= '0';
                item_loc <= (others => '0');
                new_item_set <= '0';
                new_item <= (others => '0');
                -----
                counter_reset <= '1';
                counter_enable <= '0';
                register_enable <= '0';
                register_D <= '0';
                -----


                -- Now check if snake wants us to generate a new item (and what
                -- for type of item)
                if (item_set = '1') and (req_item = '0') then
                    -- Generate a food item "00"

                    -- Let Snake know that we proccessed the request
                    item_clear <= '1';
                    
                    -- Now loop through the states that put the item type bits 
                    -- into the shift register
                    new_state <= SHIFT_FOOD_ONE;
                elsif (item_set = '1') and (req_item = '1') then
                    -- Wait between 8 and 16 seconds somehow and then generate the pu item

                    -- Let Snake know that we proccessed the request
                    item_clear <= '1';

                    new_state <= IDLE;
                elsif (item_set = '0') and (count_done = '1') then
                    -- count_done is defined as the moment that enough time has passed to start generating the pu
                    -- Generate the power-up
                    new_state <= GEN_TYPE;
                else
                    new_state <= IDLE;
                end if;

            when GEN_TYPE =>
                --------------------
                -- Initial values --
                --------------------
                item_clear <= '0';
                item_loc_set <= '0';
                item_loc <= (others => '0');
                new_item_set <= '0';
                new_item <= (others => '0');
                -----
                counter_reset <= '1';
                counter_enable <= '0';
                register_enable <= '0';
                register_D <= '0';
                -----

                if (rng_out = '0') then
                    -- The only possible outcome of the second bit is now 1, as 0 means 'food'
                    register_enable <= '1';
                    register_D <= rng_out;

                    new_state <= GEN_TYPE_PU_ONE;
                else
                    register_enable <= '1';
                    register_D <= rng_out;

                    new_state <= GEN_TYPE_PU_TWO;
                end if;

            when GEN_TYPE_PU_ONE =>
                --------------------
                -- Initial values --
                --------------------
                item_clear <= '0';
                item_loc_set <= '0';
                item_loc <= (others => '0');
                new_item_set <= '0';
                new_item <= (others => '0');
                -----
                counter_reset <= '1';
                counter_enable <= '0';
                register_enable <= '0';
                register_D <= '0';
                -----

                register_enable <= '1';
                register_D <= '1';

                new_state <= GEN_LOC;

            when GEN_TYPE_PU_TWO =>
                --------------------
                -- Initial values --
                --------------------
                item_clear <= '0';
                item_loc_set <= '0';
                item_loc <= (others => '0');
                new_item_set <= '0';
                new_item <= (others => '0');
                -----
                counter_reset <= '1';
                counter_enable <= '0';
                register_enable <= '0';
                register_D <= '0';
                -----

                register_enable <= '1';
                register_D <= rng_out;

                new_state <= GEN_LOC;

            when SHIFT_FOOD_ONE =>
                --------------------
                -- Initial values --
                --------------------
                item_clear <= '0';
                item_loc_set <= '0';
                item_loc <= (others => '0');
                new_item_set <= '0';
                new_item <= (others => '0');
                -----
                counter_reset <= '1';
                counter_enable <= '0';
                register_enable <= '0';
                register_D <= '0';
                -----


                -- Shift the LSB of food ("00") into the Shift Register
                register_enable <= '1';
                register_D <= '0';

                new_state <= SHIFT_FOOD_TWO;

            when SHIFT_FOOD_TWO =>
                --------------------
                -- Initial values --
                --------------------
                item_clear <= '0';
                item_loc_set <= '0';
                item_loc <= (others => '0');
                new_item_set <= '0';
                new_item <= (others => '0');
                -----
                counter_reset <= '1';
                counter_enable <= '0';
                register_enable <= '0';
                register_D <= '0';
                -----

                -- Shift the second bit of food ("00") into the SR 
                register_enable <= '1';
                register_D <= '0';

                new_state <= GEN_LOC;

            when GEN_LOC =>
                --------------------
                -- Initial values --
                --------------------
                item_clear <= '0';
                item_loc_set <= '0';
                item_loc <= (others => '0');
                new_item_set <= '0';
                new_item <= (others => '0');
                -----
                counter_reset <= '1';
                counter_enable <= '0';
                register_enable <= '0';
                register_D <= '0';
                -----
                

                -- Start the internal counter
                counter_enable <= '1';
                counter_reset <= '0';

                if (counter_out = "1010") then      -- "1010" equals decimal 10
                    counter_enable <= '0';
                    -- Is it good habit to reset counter already? Or just leave it as it will be resetted just before another location generation anyway?
                    new_state <= CHECK_LOC;
                else
                    -- Add new random bit to the shift register
                    -- There should be implemented a check here, that checks if the x coordinate is not out of bounds, otherwise make it fit inside the grid.
                    counter_enable <= '1';
                    register_enable <= '1';
                    register_D <= rng_out;

                    new_state <= GEN_LOC;
                end if;

            when CHECK_LOC =>
                --------------------
                -- Initial values --
                --------------------
                item_clear <= '0';
                item_loc_set <= '0';
                item_loc <= (others => '0');
                new_item_set <= '0';
                new_item <= (others => '0');
                -----
                counter_reset <= '1';
                counter_enable <= '0';
                register_enable <= '0';
                register_D <= '0';
                -----


                item_loc_set <= '1';

                if (item_loc_clear = '0') then
                    item_loc <= register_Q(11 downto 2);

                    new_state <= CHECK_LOC;
                elsif (item_loc_clear = '1') and (item_ok = '1') then 
                    item_loc_set <= '0';

                    new_state <= SEND_LOC;
                elsif (item_loc_clear = '1') and (item_ok = '0') then
                    -- Calculate a new location
                    new_state <= SHIFT_REG_ONE;
                else 
                    new_state <= CHECK_LOC;
                end if;

            when SHIFT_REG_ONE =>
                --------------------
                -- Initial values --
                --------------------
                item_clear <= '0';
                item_loc_set <= '0';
                item_loc <= (others => '0');
                new_item_set <= '0';
                new_item <= (others => '0');
                -----
                counter_reset <= '1';
                counter_enable <= '0';
                register_enable <= '0';
                register_D <= '0';
                -----

                register_enable <= '1';
                register_D <= register_Q(0);

                new_state <= SHIFT_REG_TWO;

            when SHIFT_REG_TWO =>
                --------------------
                -- Initial values --
                --------------------
                item_clear <= '0';
                item_loc_set <= '0';
                item_loc <= (others => '0');
                new_item_set <= '0';
                new_item <= (others => '0');
                -----
                counter_reset <= '1';
                counter_enable <= '0';
                register_enable <= '0';
                register_D <= '0';
                -----

                register_enable <= '1';
                register_D <= register_Q(0);

                new_state <= GEN_LOC;

            when SEND_LOC =>
                --------------------
                -- Initial values --
                --------------------
                item_clear <= '0';
                item_loc_set <= '0';
                item_loc <= (others => '0');
                new_item_set <= '0';
                new_item <= (others => '0');
                -----
                counter_reset <= '1';
                counter_enable <= '0';
                register_enable <= '0';
                register_D <= '0';
                -----


                new_item_set <= '1';

                if (new_item_clear = '1') then
                    new_item_set <= '0';

                    new_state <= IDLE;
                else 
                    new_item <= register_Q;

                    new_state <= SEND_LOC;
                end if;
                -- If the storage fails to respond with an send_storage_succes, then this will hang forever: IG = kapot
        end case;
    end process;

    count_comp <= "1010";
end behaviour;
