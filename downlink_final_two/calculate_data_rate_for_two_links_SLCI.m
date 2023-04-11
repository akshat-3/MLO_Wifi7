function [final_load_assign] = calculate_data_rate_for_two_links_SLCI(channel_occupancy, percentage_available_channel, rate, mlo_umac, n_new_flows)


    
    channel_occupancy_in_function = channel_occupancy(1:2);
    final_load_assign = zeros(n_new_flows, 2);
    tentative_load_assign = zeros(n_new_flows, 2);

    k = 1;

    for i = mlo_umac.active_index_end - n_new_flows + 1 : mlo_umac.active_index_end
        
        app_flow = mlo_umac.flow_details(i).flow; 
        %tentative flow assign according to algo
        [B3, I3]=sort(channel_occupancy_in_function);
    
        tentative_load_assign(k, I3(1))= app_flow; 
        tentative_load_assign(k, I3(2))= app_flow; 
        
        %find increase in channel occ
        increase_ch_occ = tentative_load_assign(k,:)/rate; 
        channel_occupancy_in_function = channel_occupancy_in_function + increase_ch_occ;
       
    
        %if channel occupancy exceeds 100% flow can't be assigned.
        %Assign it 0mbps so it works with the code flow
        if channel_occupancy_in_function(I3(1)) >= 1 %1 => 100% channel occ
            final_load_assign(k, I3(1))= 0;
        else
            final_load_assign(k, I3(1))= app_flow; 
        end
       
        final_load_assign(k, I3(2))=0;
        k = k+1;
        
    end
    
end