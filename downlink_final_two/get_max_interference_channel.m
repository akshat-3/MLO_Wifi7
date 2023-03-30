function [interface, max_interference_channel] = get_max_interference_channel(interface, rssi)
    
   
    max_interference_channel = interface.primary_channel;

    if interface.bw == 40 && (interface.primary_channel == 21 || interface.primary_channel == 23)
        
        if rssi(1, interface.primary_channel) < rssi(1, interface.primary_channel+1)
            max_interference_channel = interface.primary_channel + 1;
        end

    elseif interface.bw == 80

        if rssi(1, interface.primary_channel) < rssi(1, interface.primary_channel+1)
            max_interference_channel = interface.primary_channel + 1;
        end

        if rssi(1, max_interference_channel) < rssi(1, interface.primary_channel-1)
            max_interference_channel = interface.primary_channel - 1;
        end

        if rssi(1, max_interference_channel) < rssi(1, interface.primary_channel-2)
            max_interference_channel = interface.primary_channel - 2;
        end

    else
        %160bw not possible for channel no 23
    end


end