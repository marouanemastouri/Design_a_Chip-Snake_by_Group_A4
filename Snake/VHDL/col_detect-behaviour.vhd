library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

architecture behaviour of col_detect is
    type col_detect_state is (IDLE, CHECK_COL, COL_ITEM_ONE, COL_ITEM_TWO, COL_SNAKE);
    signal state, new_state: col_detect_state;

begin

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

    lbl2: process (state, ig_item_loc_set, ig_item_loc, st_req_item_clear, st_req_item_exists, st_item_loc, x_range, y_range, so_range_set, tail)
    begin
        case state is
            when IDLE =>
                --------------------
                -- Initial values --
                --------------------
                ig_item_loc_clear <= '0';
                ig_item_ok <= '0';
                --
                st_req_item_set <= '0';
                st_req_item_no <= '0';
                --
                so_range_clear <= '0';
                so_reset <= '0';
                ----


                if (ig_item_loc_set = '1') then
                    -- Check the new item location
                    new_state <= CHECK_COL;
                else
                    new_state <= IDLE;
                end if;
                
            when CHECK_COL =>
                --------------------
                -- Initial values --
                --------------------
                ig_item_loc_clear <= '0';
                ig_item_ok <= '0';
                --
                st_req_item_set <= '0';
                st_req_item_no <= '0';
                --
                so_range_clear <= '0';
                so_reset <= '0';
                ----


                if (ig_item_loc_set = '1') then
                    if ig_item_loc(4 downto 0) = "00000" or ig_item_loc(4 downto 0) = "11111" or ig_item_loc(9 downto 5) = "00000" or ig_item_loc(9 downto 5) = "11000" then
                        -- There is a collision with the wall. 
                        -- Signal IG to generate a new location
                        ig_item_loc_clear <= '1'; -- Signal that the location has been processed
                        ig_item_ok <= '0'; -- Location not available
                        
                        new_state <= IDLE;
                    else
                        -- check for collision with the items in the field
                        -- First check if there are items in the field (there should be at least one food item in the field, and additionally there could be a pu item also)

                        -- Retrieve the first item from the storage
                        st_req_item_set <= '1';
                        st_req_item_no <= '0';

                        new_state <= COL_ITEM_ONE;    
                    end if;
                else
                    -- TEMPORARY CODE
                    new_state <= IDLE;
                end if;

             when COL_ITEM_ONE =>
                --------------------
                -- Initial values --
                --------------------
                ig_item_loc_clear <= '0';
                ig_item_ok <= '0';
                --
                st_req_item_set <= '0';
                st_req_item_no <= '0';
                --
                so_range_clear <= '0';
                so_reset <= '0';
                ----


                -- Check for a collision with the first item (if available, which it should be)
                st_req_item_set <= '1';

                if (st_req_item_clear = '1') and (st_req_item_exists = '1') then
                    st_req_item_set <= '0';
                    
                    if (st_item_loc = ig_item_loc) then
                        -- This location is already occupied
                        ig_item_loc_clear <= '1';
                        ig_item_ok <= '0';

                        new_state <= IDLE;
                     else
                        -- new_item passed this check
                        new_state <= COL_ITEM_TWO;
                     end if;
                elsif (st_req_item_clear = '1') and (st_req_item_exists = '0') then
                    st_req_item_set <= '0';
                    
                    -- skip this item because it does not exist (what is actually weird, as there should always be one food item in the field)
                    new_state <= COL_ITEM_TWO;
                else 
                    new_state <= COL_ITEM_ONE;
                end if;

            when COL_ITEM_TWO =>
                --------------------
                -- Initial values --
                --------------------
                ig_item_loc_clear <= '0';
                ig_item_ok <= '0';
                --
                st_req_item_set <= '0';
                st_req_item_no <= '0';
                --
                so_range_clear <= '0';
                so_reset <= '0';
                ----

                -- Check for a collision with the second item 
                st_req_item_set <= '1';

                if (st_req_item_clear = '1') and (st_req_item_exists = '1') then
                    st_req_item_set <= '0';
                    
                    if (st_item_loc = ig_item_loc) then
                        -- This location is already occupied
                        ig_item_loc_clear <= '1';
                        ig_item_ok <= '0';

                        new_state <= IDLE;
                     else
                        -- new_item passed this check
                        new_state <= COL_SNAKE;
                     end if;
                elsif (st_req_item_clear = '1') and (st_req_item_exists = '0') then
                    st_req_item_set <= '0';
                    
                    -- skip this item because it does not exist (what is actually weird, as there should always be one food item in the field)
                    new_state <= COL_SNAKE;
                else 
                    new_state <= COL_ITEM_TWO;
                end if;

            when COL_SNAKE =>
                --------------------
                -- Initial values --
                --------------------
                ig_item_loc_clear <= '0';
                ig_item_ok <= '0';
                --
                st_req_item_set <= '0';
                st_req_item_no <= '0';
                --
                so_range_clear <= '0';
                so_reset <= '0';
                ----
                

                
                -- Check for a collision with the snake
                -- The first time we enter this case the two corners correspond to the head of the snake and the first next corner. 
                -- So we need to loop this case until we had the whole snake (which is indicated by the is_tail flag

                
                if (so_range_set = '1') then
                    if (tail = '1') then
                        -- This is the last check we will perform. If it succeeds the generation was succesfull
                        
                    else
                        -- Check if the line is horizontal or vertical
                        if (x_range(9 downto 5) = x_range(4 downto 0)) then
                            -- Vertical line
                            if (ig_item_loc(4 downto 0) = x_range(4 downto 0)) then
                                -- Possible collision
                                if (ig_item_loc(9 downto 5) < y_range(4 downto 0)) or (ig_item_loc(9 downto 5) > y_range(9 downto 5)) then
                                    -- No collision
                                    -- Check the next line of the snake

                                    so_range_clear <= '1'; -- request new part of snake

                                    new_state <= COL_SNAKE;
                                    
                                else
                                    -- Collision
                                    ig_item_loc_clear <= '1';
                                    ig_item_ok <= '0';

                                    
                                    so_reset <= '1'; -- EVEN KIJKEN HOE WE DIT GAAN IMPLEMENTEREN

                                    new_state <= IDLE;
                                end if;
                            else
                                -- No collision
                                -- Check the next line of the snake

                                so_range_clear <= '1'; -- request new part of snake

                                new_state <= COL_SNAKE;
                        end if;
                        else
                            -- Now we assume that y_range(start) = y_range(end). If somewhere this is fucked up, this will result in unwanted behaviour
                            -- Horizontal line
                            if (ig_item_loc(9 downto 5) = y_range(4 downto 0)) then
                                -- Possible collision
                                if (ig_item_loc(4 downto 0) < x_range(4 downto 0)) or (ig_item_loc(4 downto 0) > x_range(9 downto 0)) then
                                    -- No collision
                                    -- Check the next line of the snake

                                    so_range_clear <= '1'; -- request new part of snake

                                    new_state <= COL_SNAKE;
                                else 
                                    -- Collision
                                    ig_item_loc_clear <= '1';
                                    ig_item_ok <= '0';
                                    
                                    so_reset <= '1';
                                    
                                    new_state <= IDLE;
                                end if;
                            else
                                -- No collision
                                -- Check the next line of the snake

                                so_range_clear <= '1'; -- request new part of snake

                                new_state <= COL_SNAKE;
                            end if; 
                        end if;
                    end if;
                else
                    new_state <= COL_SNAKE;
                end if;
        end case;
    end process;
end behaviour;
