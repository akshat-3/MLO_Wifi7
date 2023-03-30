function [num_channels, ch_left, ch_right] = channel_bonding_wifi_ax_acc_to_sliced_occ_matrix(occupancy_at_access,primary_ch)
%this is according to the sliced occupancy matrix. due to slicing channel
%ni 23 is now channel no 11. go to channel_bonding_wifi_ax() to get
%according to unsliced occupancy matrix

    num_channels = 1;
    ch_left = primary_ch;
    ch_right = primary_ch;


    if(primary_ch >= 9 && primary_ch<=11)

        ch_left = primary_ch;
        ch_right = primary_ch;

        %try for 40mhz
        if primary_ch == 9 || primary_ch == 11 || primary_ch == 21 %only for emulation forpose 21 is here
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
        if primary_ch == 21 %only for emulation purpose
            return;
        end

        if num_channels > 1
            checker = (occupancy_at_access(1, 9:12) == 0);
            isFree = true;

            for i = 1:4
                if (checker(1, i) == 1)
                    isFree = false;
                    break;
                end
            end

            if isFree == true
                ch_left = 9;
                ch_right = 12;
                num_channels = 4;
            end
        end   
    end

end

