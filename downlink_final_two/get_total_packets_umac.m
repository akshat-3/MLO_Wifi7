function [total_packets_umac] = get_total_packets_umac(n_sta, n_apps)
    
    total_packets_umac = zeros(n_sta, n_apps);
    
    [sta_association_start, non_mlo_association_start, mlo_association_start, sta_association_end, ...
        non_mlo_association_end, mlo_association_end, app_start_time, app_end_time, mlo_app_start_time, non_mlo_app_start_time,...
        mlo_app_end_time, non_mlo_app_end_time] = sta_apps_time();
    
    app_flow = get_app_flow(3);
    
    for sta_no = 1:n_sta
        for app_flow_no = 1:n_apps
            [samples_to_wait, packets_to_add] = get_packets_per_sample(app_flow(sta_no, app_flow_no));
            start_time = app_start_time(sta_no, app_flow_no);
            end_time = app_end_time(sta_no, app_flow_no);
            duration = end_time - start_time;
    
            total_packets_umac(sta_no, app_flow_no) = (duration/samples_to_wait)*packets_to_add;
            if rem(duration, samples_to_wait) ~= 0
                total_packets_umac(sta_no, app_flow_no) = total_packets_umac(sta_no, app_flow_no) + packets_to_add;
            end
    
        end
    end
end