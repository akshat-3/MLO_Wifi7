function [final_load_assign] = calculate_data_rate_for_two_links_MCAA(channel_occupancy, percentage_available_channel, rate, mlo_umac, n_new_flows)
   
    channel_occupancy_in_function = channel_occupancy(1:2);
    percentage_available_channel_in_function = 1-channel_occupancy_in_function;  
    final_load_assign = zeros(n_new_flows, 2);
    tentative_load_assign = zeros(n_new_flows, 2);

    k = 1;

    for i = mlo_umac.active_index_end - n_new_flows + 1 : mlo_umac.active_index_end
        app_flow = mlo_umac.flow_details(i).flow; 

        %tentatively assign load
        tentative_load_assign(k, 1) = app_flow * (percentage_available_channel_in_function(1)/sum(percentage_available_channel_in_function));
        tentative_load_assign(k, 2) = app_flow * (percentage_available_channel_in_function(2)/sum(percentage_available_channel_in_function));
    
        %calculate channel occupancy after tentatively assigning load
        increase_ch_occ = tentative_load_assign(k,:)/rate; 
        channel_occupancy_in_function = channel_occupancy_in_function + increase_ch_occ;
        percentage_available_channel_in_function = 1 - channel_occupancy_in_function;
    
        %if channel occupancy exceeds 100%/ percentage avail channel == 0 flow can't be assigned.
        %Assign it 0mbps so it works with the code flow
    
        if percentage_available_channel_in_function(1) == 0
            final_load_assign(k, 1) = 0;
        else
            final_load_assign(k, 1) = app_flow*(percentage_available_channel_in_function(1)/sum(percentage_available_channel_in_function));
        end
        
        
        if percentage_available_channel_in_function(2) == 0
            final_load_assign(k, 2) = 0;
        else
            final_load_assign(k, 2) = app_flow*(percentage_available_channel_in_function(2)/sum(percentage_available_channel_in_function));
        end

        k = k+1;
    end

       
 
    
end