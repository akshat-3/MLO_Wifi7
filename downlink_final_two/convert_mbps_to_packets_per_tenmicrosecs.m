function ans = convert_mbps_to_packets_per_tenmicrosecs(datarate_in_mbps)
    
    size_one_packet = 12000; %bits
    no_of_its_per_sec = datarate_in_mbps * 1e+6;
    no_of_packets_per_sec = no_of_its_per_sec/size_one_packet;
    ans = no_of_packets_per_sec * 10e-6;
    
end