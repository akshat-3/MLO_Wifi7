function [n_samples_to_wait_before_allocating_to_queue, link_rate_in_packets_per_tenmicrosecs] = calculate_samples_to_wait_before_alloc(link_rate_in_packets_per_tenmicrosecs)
%link_rate in packet/10micro secs is something like 0.04 packets/ 10 micro
%seconds
%convert it to something like allot 4 packets after x number of samples
    n_samples_to_wait_before_allocating_to_queue = 1;
            
    while link_rate_in_packets_per_tenmicrosecs < 1
        n_samples_to_wait_before_allocating_to_queue = n_samples_to_wait_before_allocating_to_queue * 10;
        link_rate_in_packets_per_tenmicrosecs = link_rate_in_packets_per_tenmicrosecs * 10;
    end
end


