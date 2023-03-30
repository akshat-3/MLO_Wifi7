function [num_channels, ch_left, ch_right] = channel_bonding_wifi_ax(occupancy_at_access,primary_ch, ch_range)
%UNTITLED Summary of this function goes here
%NOTE CHANNEL BONDING BEHAVIOUR FOR CH 23 HAS BEEN CHANGED FOR SIMULATION!


num_channels = 1;
    if (primary_ch >=1 && primary_ch<=12) || primary_ch == 24 || primary_ch == 19
        %no channel bonding in first interface
        %sub ch 24 and 19 cant be bonded due to ieee rules
        num_channels = 1;
        ch_left = primary_ch;
        ch_right = primary_ch;
    else
        if(primary_ch >= 13 && primary_ch<=16)
            ch_left_limit = 13;
            ch_right_limit = 16;
    
            ch_left = primary_ch;
            ch_right = primary_ch;

            %try for 40mhz
            if primary_ch == 13 || primary_ch == 15
                if occupancy_at_access(1, primary_ch+1) == 0
                    ch_right = primary_ch  + 1;
                    num_channels = num_channels + 1;
                end
            else 
                if occupancy_at_access(1, primary_ch-1) == 0
                    ch_left = primary_ch - 1;
                    num_channels = num_channels + 1;
                end
            end

            %if 40mhz successful try for 80mhz

            if num_channels > 1
                checker = (occupancy_at_access(1, 13:16) == 0);
                isFree = true;

                for i = 1:4
                    if (checker(1, i) == 1)
                        isFree = false;
                        break;
                    end
                end

                if isFree == true
                    ch_left = 13;
                    ch_right = 16;
                    num_channels = 4;
                end
            end   
        end


        if(primary_ch >= 17 && primary_ch<=18)
            ch_left_limit = 17;
            ch_right_limit = 18;
    
            ch_left = primary_ch;
            ch_right = primary_ch;

            %try for 40mhz
            if primary_ch == 17
                if occupancy_at_access(1, primary_ch+1) == 0
                    ch_right = primary_ch  + 1;
                    num_channels = num_channels + 1;
                end
            else 
                if occupancy_at_access(1, primary_ch-1) == 0
                    ch_left = primary_ch - 1;
                    num_channels = num_channels + 1;
                end
            end          
        end

        if(primary_ch >= 20 && primary_ch<=23)
            ch_left_limit = 20;
            ch_right_limit = 23;
    
            ch_left = primary_ch;
            ch_right = primary_ch;

            %try for 40mhz
            if primary_ch == 20 || primary_ch == 22
                if occupancy_at_access(1, primary_ch+1) == 0
                    ch_right = primary_ch  + 1;
                    num_channels = num_channels + 1;
                end
            else 
                if occupancy_at_access(1, primary_ch-1) == 0
                    ch_left = primary_ch - 1;
                    num_channels = num_channels + 1;
                end
            end

            %if 40mhz successful try for 80mhz

            if num_channels > 1
                checker = (occupancy_at_access(1, 20:23) == 0);
                isFree = true;

                for i = 1:4
                    if (checker(1, i) == 1)
                        isFree = false;
                        break;
                    end
                end

                if isFree == true
                    ch_left = 20;
                    ch_right = 23;
                    num_channels = 4;
                end
            end   
        end

    end
end

