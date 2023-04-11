function [interface] = allocate_slo_flow(interface, sample_no, is_interface_one, interface_one_primary_channel, interface_two_primary_channel, historical_occupancy_matrix, rate)
    
    n_active_umac_slo_interface_flows = interface.slo_umac.active_index_end;
    n_active_lmac_slo_interface_flows = interface.slo_lmac.active_index_end;
    n_new_slo_flows_arrived = n_active_umac_slo_interface_flows - n_active_lmac_slo_interface_flows;

    for i = 1:n_new_slo_flows_arrived
        interface.slo_lmac.active_index_end = interface.slo_lmac.active_index_end + 1;
    end

    %out of old flows check which flows were assigned 0 the last time
    %allocation took place (if at both interface the flow was asssigned 0, it implies that flow wasn't allocated)
    %and add those flow to n_new_slo_flows_arrived
    %since we will try to allocate them this time 
    for i = 1 : n_active_lmac_slo_interface_flows

        if interface.slo_lmac.flow_details(i).flow == 0 
            %this means flow was not allocated to lmac
            n_new_slo_flows_arrived = n_new_slo_flows_arrived + 1;
        end

    end

    %check the increase in channel occupancy when load is assigned.
    %if channel occupancy > 1 then don't assign
    channel_occupancy = calculate_channel_occupancy(interface_one_primary_channel, interface_two_primary_channel, -1, 2, historical_occupancy_matrix);  

    if is_interface_one
        channel_occupancy = channel_occupancy(1);
    else
        channel_occupancy = channel_occupancy(2);
    end
        
    %for unallocated flows do calculations
    for i = n_active_umac_slo_interface_flows - n_new_slo_flows_arrived + 1 : n_active_umac_slo_interface_flows

        tentative_load_assign = interface.slo_umac.flow_details(i).flow;
        increase_ch_occ = tentative_load_assign/rate; 
        channel_occupancy = channel_occupancy + increase_ch_occ;

        if channel_occupancy > 1
            interface.slo_lmac.flow_details(i).flow = 0;
        else
            interface.slo_lmac.flow_details(i).flow = interface.slo_umac.flow_details(i).flow;
        end
        
        [interface.slo_lmac.flow_details] = calculate_packets_per_sample(interface.slo_lmac.flow_details, interface.slo_lmac.flow_details(i).flow, i); %can be 2 packets/sample of 2 packets per 3 samples 
        interface.slo_lmac.flow_details(i).x = interface.slo_lmac.flow_details(i).x_; %for countdown  
        if interface.slo_lmac.flow_details(i).flow > 0
            interface.slo_lmac.flow_details(i).flow_allocated_to_LMAC_at_sample = sample_no;
        end
    end
end