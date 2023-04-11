function [interface_one, interface_two, mlo_umac, time, soft_threshold, hard_threshold, nint] = allocate_mlo_flow_dynamic(ap, interface_one, interface_two, mlo_umac, historical_occupancy_matrix, soft_threshold, hard_threshold, nint, rate_mcs_latest, time, sample_no)

    %how many new mlo flows arrived?
    n_active_umac_mlo_flows = mlo_umac.active_index_end;
    n_active_lmac_mlo_flows = interface_two.mlo_lmac.active_index_end;
    n_new_mlo_flows_arrived = n_active_umac_mlo_flows - n_active_lmac_mlo_flows;

    if n_new_mlo_flows_arrived > 0
        fprintf("mlo flow arrived\n");
    end

    for i =1:n_new_mlo_flows_arrived
        interface_one.mlo_lmac.active_index_end = interface_one.mlo_lmac.active_index_end + 1;
        interface_two.mlo_lmac.active_index_end = interface_two.mlo_lmac.active_index_end + 1;
    end


    %calculate channel occupancy
    channel_occupancy = calculate_channel_occupancy(interface_one.primary_channel, interface_two.primary_channel, -1, 2, historical_occupancy_matrix);  
   
    
    %run allocation algo. change name of algo accordingly
    tic;
    %for each new mlo flow which has arrived check how the flow should
    %be divided between interfaces
    [ap.soft_threshold, ap.hard_threshold, ap.n_int, mlo_load_assign] = ...
        calculate_data_rate_for_two_links_MCAA_dynamic(channel_occupancy, ap.soft_threshold, ap.hard_threshold, ap.n_int, ap.rate_mcs_latest, mlo_umac);
    
    fprintf("load assigned is after algo is \n");
    disp( mlo_load_assign); 
    time = time + toc;
 
    k = 1;

    %do calculations for all flows
    %FOR DYNAMIC MAKE SEPARATE
    %LOOPS FOR OLD ALLOCATED FLOWS AND NEWLY ALLOCATED FLOWS BECAUSE OF 
    %interface_two.mlo_lmac.flow_details(i).flow_allocated_to_LMAC_at_sample = sample_no;
    %above line is only for new flows
    %We need flow_allocated_to_LMAC_at_sample to check how much time has passed since it was allocated
    %and how many packets need to be added since then. check
    %update_mlo_umac_and_lmac

    for i = 1 : mlo_umac.active_index_end
        
        %assign the calculated flow division to the interfaces
       
        %mlo link one flows
        interface_one.mlo_lmac.flow_details(i).flow = mlo_load_assign(k, 1);
        [interface_one.mlo_lmac.flow_details] = calculate_packets_per_sample(interface_one.mlo_lmac.flow_details, interface_one.mlo_lmac.flow_details(i).flow, i); %can be 2 packets/sample of 2 packets per 3 samples
        interface_one.mlo_lmac.flow_details(i).x = interface_one.mlo_lmac.flow_details(i).x_;
        if interface_one.mlo_lmac.flow_details(i).flow > 0
            interface_one.mlo_lmac.flow_details(i).flow_allocated_to_LMAC_at_sample = sample_no;
        end

        %mlo link two flows
        interface_two.mlo_lmac.flow_details(i).flow = mlo_load_assign(k, 2);
        [interface_two.mlo_lmac.flow_details] = calculate_packets_per_sample(interface_two.mlo_lmac.flow_details, interface_two.mlo_lmac.flow_details(i).flow, i); %can be 2 packets/sample of 2 packets per 3 samples 
        interface_two.mlo_lmac.flow_details(i).x = interface_two.mlo_lmac.flow_details(i).x_;
        if interface_two.mlo_lmac.flow_details(i).flow > 0
            interface_two.mlo_lmac.flow_details(i).flow_allocated_to_LMAC_at_sample = sample_no;
        end
        
        k = k+1;

    end 
    


end