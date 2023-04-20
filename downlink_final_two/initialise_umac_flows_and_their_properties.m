function [ap] = initialise_umac_flows_and_their_properties(ap, sta, app_start_time, app_end_time, app_flow)

%functions sorts flows according to their start time ands them to slo_umac,
%mlo_umac queues according to if the sta is slo or mlo


app_start_time_ = [949    10373000    29740000    30215000    54683000    72483000, ...
    95705    14330000    16773000    25864000    49543000    79667000, ...
    29569000    30104000    32854000    36985000    37158000    40549000];

%sorting apps/flows according to their start time

[sorted_start_time, idx_before_sort] = sort(app_start_time_);


n_sta = ap.n_sta;
n_apps = ap.n_apps_per_sta;

for i = 1: (n_sta * n_apps)

    sta_no = (fix((idx_before_sort(i)-1)/n_apps))+1;
    app_no = rem(idx_before_sort(i), n_apps);
    
    fprintf("sta_no is: %d app_no is: %d\n", sta_no, app_no)
    if app_no == 0
        app_no = n_apps;
    end
   
    %add calculation for total packets possible

    if (rem(sta_no, 2) == 0) || sta_no == 9 %these sta's are MLO
        
        ap.mlo_umac.length = ap.mlo_umac.length + 1; %ap.mlo_umac.length initial value is 0
        ap.mlo_umac.flow_details(ap.mlo_umac.length).flow = app_flow(sta_no, app_no);
        ap.mlo_umac.flow_details(ap.mlo_umac.length).app_no = app_no;
        ap.mlo_umac.flow_details(ap.mlo_umac.length).sta_no = sta_no;
        ap.mlo_umac.flow_details(ap.mlo_umac.length).start = sorted_start_time(i);
        ap.mlo_umac.flow_details(ap.mlo_umac.length).stop = app_end_time(sta_no, app_no);
        ap.mlo_umac.flow_details(ap.mlo_umac.length).packets_used = 0;
        
        [ap.mlo_umac.flow_details] = calculate_packets_per_sample(ap.mlo_umac.flow_details, ap.mlo_umac.flow_details(ap.mlo_umac.length).flow, ap.mlo_umac.length);  
       
        duration = (app_end_time(sta_no, app_no) -  sorted_start_time(i));
        samples_to_wait = ap.mlo_umac.flow_details(ap.mlo_umac.length).samples_to_wait_before_allocating_q; %app specific
        packets_to_add = ap.mlo_umac.flow_details(ap.mlo_umac.length).packets_to_add_in_q; %app specific
        ap.mlo_umac.flow_details(ap.mlo_umac.length).total_packets_possible = fix((duration * packets_to_add)/samples_to_wait);
       % fprintf("app_no is: %d sta_no is: %d, duration is %d totalpacketsposisble is %d\n", app_no, sta_no, duration, ap.mlo_umac.flow_details(ap.mlo_umac.length).total_packets_possible);
        
        %initailiz packets to wait to 0
        %be generated
    else
        %these stas are SLO
        if sta(sta_no).primary_ch == ap.interface_two.primary_channel %this slo sta is associated- on interface two

            ap.interface_two.slo_umac.length = ap.interface_two.slo_umac.length + 1; %ap.interface_two.slo_umac.length initial value is 0
            ap.interface_two.slo_umac.flow_details(ap.interface_two.slo_umac.length).flow = app_flow(sta_no, app_no);
            ap.interface_two.slo_umac.flow_details(ap.interface_two.slo_umac.length).app_no = app_no;
            ap.interface_two.slo_umac.flow_details(ap.interface_two.slo_umac.length).sta_no = sta_no;
            ap.interface_two.slo_umac.flow_details(ap.interface_two.slo_umac.length).start = app_start_time(i);
            ap.interface_two.slo_umac.flow_details(ap.interface_two.slo_umac.length).stop = app_end_time(sta_no, app_no);
            ap.interface_two.slo_umac.flow_details(ap.interface_two.slo_umac.length).packets_used = 0;
            [ap.interface_two.slo_umac.flow_details] = calculate_packets_per_sample(ap.interface_two.slo_umac.flow_details, ap.interface_two.slo_umac.flow_details(ap.interface_two.slo_umac.length).flow, ap.interface_two.slo_umac.length);  
       
            duration = (app_end_time(sta_no, app_no) -  sorted_start_time(i));
            samples_to_wait = ap.interface_two.slo_umac.flow_details(ap.interface_two.slo_umac.length).samples_to_wait_before_allocating_q; %app specific
            packets_to_add = ap.interface_two.slo_umac.flow_details(ap.interface_two.slo_umac.length).packets_to_add_in_q; %app specific
            ap.interface_two.slo_umac.flow_details(ap.interface_two.slo_umac.length).total_packets_possible = fix((duration * packets_to_add)/samples_to_wait);
      %      fprintf("app_no is: %d sta_no is: %d, duration is %d totalpacketsposisble is %d\n", app_no, sta_no, duration, ap.interface_two.slo_umac.flow_details(ap.interface_two.slo_umac.length).total_packets_possible);
        
        else

            ap.interface_one.slo_umac.length = ap.interface_one.slo_umac.length + 1; %ap.interface_one.slo_umac.length initial value is 0
            ap.interface_one.slo_umac.flow_details(ap.interface_one.slo_umac.length).flow = app_flow(sta_no, app_no);
            ap.interface_one.slo_umac.flow_details(ap.interface_one.slo_umac.length).app_no = app_no;
            ap.interface_one.slo_umac.flow_details(ap.interface_one.slo_umac.length).sta_no = sta_no;
            ap.interface_one.slo_umac.flow_details(ap.interface_one.slo_umac.length).start = app_start_time(i);
            ap.interface_one.slo_umac.flow_details(ap.interface_one.slo_umac.length).stop = app_end_time(sta_no, app_no);
            ap.interface_one.slo_umac.flow_details(ap.interface_one.slo_umac.length).packets_used = 0;
            [ap.interface_one.slo_umac.flow_details] = calculate_packets_per_sample(ap.interface_one.slo_umac.flow_details, ap.interface_one.slo_umac.flow_details(ap.interface_one.slo_umac.length).flow, ap.interface_one.slo_umac.length);  
       
            duration = (app_end_time(sta_no, app_no) -  sorted_start_time(i));
            samples_to_wait = ap.interface_one.slo_umac.flow_details(ap.interface_one.slo_umac.length).samples_to_wait_before_allocating_q; %app specific
            packets_to_add = ap.interface_one.slo_umac.flow_details(ap.interface_one.slo_umac.length).packets_to_add_in_q; %app specific
            ap.interface_one.slo_umac.flow_details(ap.interface_one.slo_umac.length).total_packets_possible = fix((duration * packets_to_add)/samples_to_wait);
         %    fprintf("app_no is: %d sta_no is: %d, duration is %d totalpacketsposisble is %d\n", app_no, sta_no, duration,  ap.interface_one.slo_umac.flow_details(ap.interface_one.slo_umac.length).total_packets_possible);
        
        end
    end
 
end

end