function [interface_flow] = calculate_packets_per_sample(interface_flow, app_flow, idx)
    %can be 2 packets/sample of 2 packets per 3 samples   
                
    if app_flow == 0
        interface_flow(idx).packets_to_add_in_q = 0;
        interface_flow(idx).samples_to_wait_before_allocating_q = 0;
        interface_flow(idx).x_ = 0;
        return;
    end
   
    %convt data rate in mbps to packets for 10 micro sec(data rate)
    link_one_data_rate_in_packets_per_tenmicrosecs = convert_mbps_to_packets_per_tenmicrosecs(app_flow);

    %above ans will be in decimal eg: 0.004 packets per 10 microsecond.
    %convert it to something like allot 4 packets after x number of
    %samples

    [interface_flow(idx).samples_to_wait_before_allocating_q, link_one_data_rate_in_packets_per_tenmicrosecs] = calculate_samples_to_wait_before_alloc(link_one_data_rate_in_packets_per_tenmicrosecs);
    
    interface_flow(idx).packets_to_add_in_q = link_one_data_rate_in_packets_per_tenmicrosecs;

    if interface_flow(idx).packets_to_add_in_q ~= 0
        
        if interface_flow(idx).packets_to_add_in_q > interface_flow(idx).samples_to_wait_before_allocating_q
            interface_flow(idx).packets_to_add_in_q = ceil(interface_flow(idx).packets_to_add_in_q);
       
            g_c_d = gcd( interface_flow(idx).samples_to_wait_before_allocating_q, interface_flow(idx).packets_to_add_in_q );
            interface_flow(idx).samples_to_wait_before_allocating_q = interface_flow(idx).samples_to_wait_before_allocating_q/g_c_d;
            interface_flow(idx).packets_to_add_in_q = interface_flow(idx).packets_to_add_in_q/g_c_d; %suppose from above calculations we get 105 packets / 100 samples. make it 21 packets/20 samples.
        else
            interface_flow(idx).samples_to_wait_before_allocating_q = floor(interface_flow(idx).samples_to_wait_before_allocating_q/interface_flow(idx).packets_to_add_in_q);
            interface_flow(idx).packets_to_add_in_q = 1;  %suppose from above calculations we get 4 packets / 100 samples. make it 1 packet/25 samples.
        end
       
        %suppose from above calculations we get 4 packets / 100 samples. make it 1 packet/25 samples.
    end

    interface_flow(idx).x_ = interface_flow(idx).samples_to_wait_before_allocating_q;
    
 
end