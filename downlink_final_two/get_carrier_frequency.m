function carrier_frequency = get_carrier_frequency(primary_channel, bw)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    if bw == 20
        if primary_channel == 1
            carrier_frequency = 5.18;
        elseif primary_channel == 2
            carrier_frequency = 5.20;
        elseif primary_channel == 3
            carrier_frequency = 5.22;
        elseif primary_channel == 4
            carrier_frequency = 5.24;
        elseif primary_channel == 5
            carrier_frequency = 5.26;
        elseif primary_channel == 6
            carrier_frequency = 5.28;
        elseif primary_channel == 7
            carrier_frequency = 5.30;
        elseif primary_channel == 8
            carrier_frequency = 5.32;
        elseif primary_channel == 9
            carrier_frequency = 5.5;
        elseif primary_channel == 10
            carrier_frequency = 5.52;
        elseif primary_channel == 11
            carrier_frequency = 5.54;
        elseif primary_channel == 12
            carrier_frequency = 5.56;
        elseif primary_channel == 13
            carrier_frequency = 5.58;
        elseif primary_channel == 14
            carrier_frequency = 5.60;
        elseif primary_channel == 15
            carrier_frequency = 5.62;
        elseif primary_channel == 16
            carrier_frequency = 5.64;
        elseif primary_channel == 17
            carrier_frequency = 5.66;
        elseif primary_channel == 18
            carrier_frequency = 5.68;
        elseif primary_channel == 19
            carrier_frequency = 5.70;
        elseif primary_channel == 20
            carrier_frequency = 5.72;
        elseif primary_channel == 21
            carrier_frequency = 5.745;
        elseif primary_channel == 22
            carrier_frequency = 5.765;
        elseif primary_channel == 23
            carrier_frequency = 5.785;
        else
            carrier_frequency = 5.805;
        end


    

    elseif bw == 40

        if primary_channel == 1 || primary_channel == 2
            carrier_frequency = 5.19;
        elseif primary_channel == 3 || primary_channel == 4
            carrier_frequency = 5.23;
        elseif primary_channel == 5 || primary_channel == 6
            carrier_frequency = 5.27;
        elseif primary_channel == 7 || primary_channel == 8
            carrier_frequency = 5.31;
        elseif primary_channel == 9 || primary_channel == 10
            carrier_frequency = 5.51;
        elseif primary_channel == 11 || primary_channel == 12
            carrier_frequency = 5.55;
        elseif primary_channel == 13 || primary_channel == 14
            carrier_frequency = 5.59;
        elseif primary_channel == 15 || primary_channel == 16
            carrier_frequency = 5.63;
        elseif primary_channel == 17 || primary_channel == 18
            carrier_frequency = 5.67;
        elseif primary_channel == 19 || primary_channel == 20
            carrier_frequency = 5.71;
        elseif primary_channel == 21 || primary_channel == 22
            carrier_frequency = 5.755;
        else
            carrier_frequency = 5.795;
        end

    elseif bw == 80
        if primary_channel>=1 && primary_channel <= 4
            carrier_frequency = 5.21;
        elseif primary_channel>=5 && primary_channel <= 8
            carrier_frequency = 5.290;
        elseif primary_channel>=9 && primary_channel <= 12
            carrier_frequency = 5.530;
        elseif primary_channel>=13 && primary_channel <= 16
            carrier_frequency = 5.610;
        elseif primary_channel>=17 && primary_channel <= 20
            carrier_frequency = 5.690;
        elseif primary_channel>=21 && primary_channel <= 24
            carrier_frequency = 5.775;
        end
    elseif bw == 160
        if primary_channel>=1 && primary_channel <=8
            carrier_frequency = 5.250;
        end
    end
end