function [soft_threshold, hard_threshold, final_load_assign, percentage_available_channel, nint, app_flow] = calculate_data_rate_for_two_links_MCAA(channel_occupancy, soft_threshold, hard_threshold, round_no, percentage_available_channel, nint, rate, mlo_umac)
   
    channel_occupancy_in_function = channel_occupancy(1:2);
    percentage_available_channel_in_function = 1-channel_occupancy_in_function;  
    total_active_flows = mlo_umac.active_index_end;
    final_load_assign = zeros(total_active_flows, 2);
   
    
    for i = 1:n_interfaces
        %assign load

        app_flow = mlo_umac.flow_details(i).flow;
        final_load_assign(i, 1) = app_flow*(percentage_available_channel_in_function(1)/sum(percentage_available_channel_in_function));
        final_load_assign(i, 2) = app_flow*(percentage_available_channel_in_function(2)/sum(percentage_available_channel_in_function));
        
        %find increase in channel occ due to assigned load this occupancy
        %will be used to find next assigned load
        increase_ch_occ = final_load_assign(i, :) / rate; 
        channel_occupancy_in_function = channel_occupancy_in_function + increase_ch_occ;
        percentage_available_channel_in_function = 1-channel_occupancy_in_function;
        if percentage_available_channel_in_function(1) < 0
            percentage_available_channel_in_function(1) = 0;
        end

        if percentage_available_channel_in_function(2) < 0
            percentage_available_channel_in_function(2) = 0;
        end

        %chances of flow not being assigned

    end
end