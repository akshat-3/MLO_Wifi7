function [soft_threshold, hard_threshold, nint, final_load_assign] = calculate_data_rate_for_two_links_MCAA_dynamic(channel_occupancy, soft_threshold, hard_threshold, nint, rate, mlo_umac)

    channel_occupancy_in_function = channel_occupancy(1:2);
    percentage_available_channel_in_function = 1-channel_occupancy_in_function;  
    total_active_flows = mlo_umac.active_index_end;
    final_load_assign = zeros(total_active_flows, 2);
    tentative_load_assign = zeros(total_active_flows, 2);
    
   
    %all loads will be reassigned
    for i = 1:total_active_flows
        
        app_flow = mlo_umac.flow_details(i).flow;

        %tentative assignment of load
        tentative_load_assign(i, 1) = app_flow * (percentage_available_channel_in_function(1)/sum(percentage_available_channel_in_function));
        tentative_load_assign(i, 2) = app_flow * (percentage_available_channel_in_function(2)/sum(percentage_available_channel_in_function));
    
        %calculate channel occupancy after tentatively assigning load
        increase_ch_occ = tentative_load_assign(i,:)/rate; 
        channel_occupancy_in_function = channel_occupancy_in_function + increase_ch_occ;
        percentage_available_channel_in_function = 1 - channel_occupancy_in_function;
    
        %if channel occupancy exceeds 100%/ percentage avail channel == 0 flow can't be assigned.
        %Assign it 0mbps so it works with the code flow
    
        if percentage_available_channel_in_function(1) == 0
            final_load_assign(i, 1) = 0;
        else
            final_load_assign(i, 1) = app_flow*(percentage_available_channel_in_function(1)/sum(percentage_available_channel_in_function));
        end
        
        
        if percentage_available_channel_in_function(2) == 0
            final_load_assign(i, 2) = 0;
        else
            final_load_assign(i, 2) = app_flow*(percentage_available_channel_in_function(2)/sum(percentage_available_channel_in_function));
        end

        k = k+1;

    end
    
end