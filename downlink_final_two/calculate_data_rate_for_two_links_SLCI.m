function [soft_threshold, hard_threshold, final_load_assign, percentage_available_channel, nint, app_flow] = calculate_data_rate_for_two_links_SLCI(channel_occupancy, soft_threshold, hard_threshold, round_no, percentage_available_channel, nint, rate, mlo_umac)

    
    channel_occupancy_in_function = channel_occupancy(1:2);
    percentage_available_channel = percentage_available_channel(1:2);
    rate = rate(1:2);

    total_active_flows = mlo_umac.active_index_end;
    final_load_assign = zeros(total_active_flows, 2);

    
    for i = 1 : total_active_flows
        
        %assign flow according to algo
        [B3, I3]=sort(channel_occupancy_in_function);
        app_flow = mlo_umac.flow_details(i).flow;
        final_load_assign(i, I3(1))=app_flow;
        final_load_assign(i, I3(2))=0;

        %find increase in channel occ
        increase_ch_occ = final_load_assign(i,:)/rate; 
        channel_occupancy_in_function = channel_occupancy_in_function + increase_ch_occ;
       
    end
        
       
    
 

end