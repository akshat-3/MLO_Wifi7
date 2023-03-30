function [n_samples_to_wait, n_packets_to_add_in_queue] = get_packets_per_sample(rate_in_mbps)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    rate_in_mbps_in_packets_per_tenmicrosecs = convert_mbps_to_packets_per_tenmicrosecs(rate_in_mbps);
            
    %above ans will be in decimal eg: 0.004 packets per 10 microsecond.
    %convert it to something like allot 4 packets after x number of
    %samples
    [n_samples_to_wait, rate_in_mbps_in_packets_per_tenmicrosecs] = calculate_samples_to_wait_before_alloc(rate_in_mbps_in_packets_per_tenmicrosecs);
    
    n_packets_to_add_in_queue = rate_in_mbps_in_packets_per_tenmicrosecs;
    if n_packets_to_add_in_queue > n_samples_to_wait
        n_packets_to_add_in_queue = ceil(n_packets_to_add_in_queue);
       
        g_c_d = gcd(n_samples_to_wait, n_packets_to_add_in_queue);
        n_samples_to_wait = n_samples_to_wait/g_c_d;
        n_packets_to_add_in_queue = n_packets_to_add_in_queue/g_c_d; %suppose from above calculations we get 105 packets / 100 samples. make it 21 packets/20 samples.
    else
        n_samples_to_wait = floor(n_samples_to_wait/n_packets_to_add_in_queue);
        n_packets_to_add_in_queue = 1;  %suppose from above calculations we get 4 packets / 100 samples. make it 1 packet/25 samples.
    end
end