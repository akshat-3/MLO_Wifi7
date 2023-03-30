function channel_occupancy = calculate_channel_occupancy(primary_channel_interface1, primary_channel_interface2, primary_channel_interface3, n_interfaces, occupancy_matrix)
    
    channel_occupancy = [1.0, 1.0, 1.0];
    
    start_row = 1;
    stop_row = 100;
    
    %calculating for interface one
    start_col = primary_channel_interface1;
    stop_col = primary_channel_interface1;
    channel_occupancy(1) = sum(occupancy_matrix(start_row:stop_row, start_col:stop_col))/100;

    %calculating for interface two
    start_col = primary_channel_interface2;
    stop_col = primary_channel_interface2;
    channel_occupancy(2) = sum(occupancy_matrix(start_row:stop_row, start_col:stop_col))/100;
    
    
end