function [soft_threshold, hard_threshold, final_load_assign, percentage_available_channel, nint, app_flow] = calculate_data_rate_for_two_links_MLSA(channel_occupancy, soft_threshold, hard_threshold, round_no, percentage_available_channel, nint, rate, mlo_umac)

    channel_occupancy = channel_occupancy(1:2);
    %percentage_available_channel = 1-channel_occupancy;
 
    total_active_flows = mlo_umac.active_index_end;
    final_load_assign = zeros(total_active_flows, 2);


    for i = 1:total_active_flows
 
          app_flow = mlo_umac.flow_details(i).flow;
          final_load_assign(i, 1) = app_flow/n_interfaces;
          final_load_assign(i, 2) = app_flow/n_interfaces;

    end

end