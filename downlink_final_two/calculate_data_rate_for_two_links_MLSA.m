function [final_load_assign] = calculate_data_rate_for_two_links_MLSA(channel_occupancy, percentage_available_channel, rate, mlo_umac, n_new_flows)

    channel_occupancy = channel_occupancy(1:2);
    %percentage_available_channel = 1-channel_occupancy;
 
    final_load_assign = zeros(n_new_flows, 2);
    tentative_load_assign = zeros(n_new_flows, 2);

    k = 1;


    for i = mlo_umac.active_index_end - n_new_flows + 1 : mlo_umac.active_index_end
        
        app_flow = mlo_umac.flow_details(i).flow; 
        
        %tentative flow assign according to algo
    
        tentative_load_assign(k, 1)= app_flow/n_interfaces; 
        tentative_load_assign(k, 2)= app_flow/n_interfaces; 
        
        %find increase in channel occ
        increase_ch_occ = tentative_load_assign(k,:)/rate; 
        channel_occupancy_in_function = channel_occupancy_in_function + increase_ch_occ;
       
    
        %if channel occupancy exceeds 100% flow can't be assigned.
        %Assign it 0mbps so it works with the code flow
        if percentage_available_channel_in_function(1) == 0
            final_load_assign(k, 1) = 0;
        else
            final_load_assign(k, 1) = app_flow/n_interfaces;
        end
        
        
        if percentage_available_channel_in_function(2) == 0
            final_load_assign(k, 2) = 0;
        else
            final_load_assign(k, 2) = app_flow/n_interfaces;
        end
 


        k = k+1;
    end

end