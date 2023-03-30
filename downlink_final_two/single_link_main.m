tic;
%get occupancy matrix and rssi matrix
num_iterations = 1; % max value 2001
num_rssi_samples_per_iter = 10000;
NUM_RFs = 24;
peak_threshold = 150; %in WACA code  its 150. for testing purpose taking it as 50
%global occupancy_matrix;
%global rssi_matrix;
piece = num_iterations * num_rssi_samples_per_iter;
rssi_matrix = zeros(piece+num_rssi_samples_per_iter,NUM_RFs);
occupancy_matrix = zeros(piece+num_rssi_samples_per_iter,NUM_RFs);
[occupancy_matrix, rssi_matrix] = get_occupancy_matrix_in_pieces(peak_threshold, num_iterations, num_rssi_samples_per_iter, NUM_RFs, 1, piece+num_rssi_samples_per_iter, occupancy_matrix, rssi_matrix);
num_samples = 500 * num_iterations * num_rssi_samples_per_iter;
T_SAMPLE = 10*1E-6;

n_sta = 4; %CHANGE IN MULTI LINK
n_apps = 5;
[sta_association_start, non_mlo_association_start, mlo_association_start, sta_association_end, ...
    non_mlo_association_end, mlo_association_end, app_start_time, app_end_time, mlo_app_start_time, non_mlo_app_start_time,...
    mlo_app_end_time, non_mlo_app_end_time] = sta_apps_time();

%% AP PARAMETERS

ap.q_umac = zeros(1, 1); %UMAC queue
%ap.tail_umac = dlnode(nan);
ap.len_umac = 0;
ap.n_sta = n_sta;
ap.n_apps_per_sta = n_apps;
ap.total_flow = 0;
ap.load_assign = [0.0, 0.0];
ap.throughput = 0;
ap.percent_air_time = 0;
ap.percent_success_air_time = 0;
ap.n_packet_drop = 0;
ap.channel_occupancy = [0.0, 0.0];

%AP and STA
ap.non_mlo_association_start = non_mlo_association_start;
ap.non_mlo_association_end = non_mlo_association_end;
ap.association_start = ap.non_mlo_association_start; %ONLY FOR SLO STAs
ap.association_end = ap.non_mlo_association_end; %ONLY FOR SLO STAs
ap.total_mlo_flow = 0;
ap.is_MLO_flow_changed_from_zero = false;
ap.total_slo_flow_interface_one = 0;
ap.total_slo_flow_interface_two = 0;

%%AP INTERFACE 1
%iterator
ap.interface_one.i = 0; %index of last packet in m1's queue 
ap.interface_one.difs = 0;  % interface 1 DIFS counter
ap.interface_one.bo = 0;  % interface 1 BO counter
ap.interface_one.sifs = 0;  %interface 1 SIFS counter
ap.interface_one.tx = 0; %machine 1 transmission counter
ap.interface_one.pifs = 0; %pifs counter
ap.interface_one.s_BO = 0;
ap.interface_one.s_FULL_TX = 0;
ap.interface_one.s_DATA = 0;
ap.interface_one.n_agg = 0;
ap.interface_one.CW = 16;
ap.interface_one.current_rx_sta = -1;
ap.interface_one.bw = 0;
ap.interface_one.count_below_snr = 0;


%l_mac queue
ap.interface_one.sta_packet_map = zeros(n_sta, 1); %size needs to be corrected
ap.interface_one.q = zeros(1);
ap.interface_one.len_q = 0;
ap.interface_one.n_channel_access = 0;%n_first_channel_gains_access = 0;
ap.interface_one.link_rate = 0;%link_one_data_rate = 0;
ap.interface_one.slo.samples_to_wait_before_allocating_q = -1; %n_samples_to_wait_before_allocating_to_queue1
ap.interface_one.slo.packets_to_add_in_q = -1;%n_packets_to_add_in_queue1
ap.interface_one.slo.x = 0;%x1
ap.interface_one.slo.x_ = 0;%x_1
ap.interface_one.slo.flow_allocation_rate = 0;
ap.interface_one.mlo.samples_to_wait_before_allocating_q = -1; %n_samples_to_wait_before_allocating_to_queue1
ap.interface_one.mlo.packets_to_add_in_q = -1;%n_packets_to_add_in_queue1
ap.interface_one.mlo.x = 0;%x1
ap.interface_one.mlo.x_ = 0;%x_1
ap.interface_one.mlo.flow_allocation_rate = 0;
ap.interface_one.flow_allocation_rate = ap.interface_one.slo.flow_allocation_rate + ap.interface_one.mlo.flow_allocation_rate;

%interface1 stats
ap.interface_one.state = -1; %state_interface1
ap.interface_one.num_data_bits_sent = 0; %num_data_bits_sent_interface1 = 0
ap.interface_one.num_txs = 0; %num_txs_interface1 = 0
ap.interface_one.primary_channel = 5; %primary_channel_interface1
ap.interface_one.num_pkt_sent = 0; %num_pkt_sent_interface1
ap.interface_one.is_collision = false;
ap.interface_one.n_tx_attempts = 0;
ap.interface_one.n_collision = 0;
ap.interface_one.throughput = 0;
ap.interface_one.num_samples_in_tx_success = 0;
ap.interface_one.num_samples_in_tx = 0;
ap.interface_one.n_successful_tx = 0;
ap.interface_one.percent_air_time = 0;
ap.interface_one.percent_success_air_time = 0;
ap.interface_one.n_packet_drop = 0;

%%AP INTERFACE 2
%iterator
ap.interface_two.i = 0; %index of last packet in m1's queue 
ap.interface_two.difs = 0;  % interface 1 DIFS counter
ap.interface_two.bo = 0;  % interface 1 BO counter
ap.interface_two.sifs = 0;  %interface 1 SIFS counter
ap.interface_two.tx = 0; %machine 1 transmission counter
ap.interface_two.pifs = 0; %pifs counter
ap.interface_two.s_BO = 0;
ap.interface_two.s_FULL_TX = 0;
ap.interface_two.s_DATA = 0;
ap.interface_two.n_agg = 0;
ap.interface_two.CW = 16;
ap.interface_two.current_rx_sta = -1;
ap.interface_two.bw  = 0;
ap.interface_two.count_below_snr = 0;

%l_mac queue
ap.interface_two.sta_packet_map = zeros(n_sta, 1); %size needs to be corrected
ap.interface_two.q = zeros(1);
ap.interface_two.len_q = 0;
ap.interface_two.n_channel_access = 0;%n_first_channel_gains_access = 0;
ap.interface_two.link_rate = 0;%link_one_data_rate = 0;
ap.interface_two.slo.samples_to_wait_before_allocating_q = -1; %n_samples_to_wait_before_allocating_to_queue1
ap.interface_two.slo.packets_to_add_in_q = -1;%n_packets_to_add_in_queue1
ap.interface_two.slo.x = 0;%x1
ap.interface_two.slo.x_ = 0;%x_1
ap.interface_two.slo.flow_allocation_rate = 0;
ap.interface_two.mlo.samples_to_wait_before_allocating_q = -1; %n_samples_to_wait_before_allocating_to_queue1
ap.interface_two.mlo.packets_to_add_in_q = -1;%n_packets_to_add_in_queue1
ap.interface_two.mlo.x = 0;%x1
ap.interface_two.mlo.x_ = 0;%x_1
ap.interface_two.mlo.flow_allocation_rate = 0;
ap.interface_two.flow_allocation_rate = ap.interface_two.slo.flow_allocation_rate + ap.interface_two.mlo.flow_allocation_rate;

%interface 2 stats
ap.interface_two.state = -1; %state_interface1
ap.interface_two.num_data_bits_sent = 0;% num_data_bits_sent_interface1 = 0;
ap.interface_two.num_txs = 0; %num_txs_interface1 = 0;
ap.interface_two.primary_channel = 23; %primary_channel_interface1 its actually channel no 23 but since occupancy_matrix is sliced in new matrix channel num = 11
ap.interface_two.num_pkt_sent = 0; %num_pkt_sent_interface1
ap.interface_two.is_collision = false; 
ap.interface_two.n_tx_attempts = 0;
ap.interface_two.n_collision = 0;
ap.interface_two.throughput = 0;
ap.interface_two.num_samples_in_tx_success = 0;
ap.interface_two.num_samples_in_tx = 0;
ap.interface_two.n_successful_tx = 0;
ap.interface_two.percent_air_time = 0;
ap.interface_two.percent_success_air_time = 0;
ap.interface_two.n_packet_drop = 0;

sta = struct();

%initialize STA
%sta should have a association begin and association end time (not possion distribution). they should
%stay associated for 15-30 minutes

for i = 1: n_sta
    %association start and end
    sta(i).association_start = non_mlo_association_start(i);
    sta(i).association_stop = non_mlo_association_end(i);
    sta(i).is_mlo = false;
    sta(i).throughput = 0;
    sta(i).percent_success_air_time = 0;
    sta(i).percent_air_time = 0;
    
    %interface1 stats
   
    sta(i).interface_one.num_data_bits_received = 0; 
    sta(i).interface_one.num_pkts_received = 0; %num_pkt_sent_interface1
    sta(i).interface_one.throughput = 0;
    sta(i).interface_one.num_samples_in_tx_success = 0;
    sta(i).interface_one.num_samples_in_tx = 0; 
    sta(i).interface_one.n_collision = 0;
    sta(i).interface_one.n_successful_tx = 0;
    sta(i).interface_one.percent_air_time = 0;
    sta(i).interface_one.percent_success_air_time = 0;
    sta(i).interface_one.n_packet_drop = 0;

    %interface2 stats
   
    sta(i).interface_two.num_data_bits_received = 0; 
    sta(i).interface_two.num_pkts_received = 0; %num_pkt_sent_interface1
    sta(i).interface_two.throughput = 0;
    sta(i).interface_two.num_samples_in_tx_success = 0;
    sta(i).interface_two.num_samples_in_tx = 0;
    sta(i).interface_two.n_collision = 0;
    sta(i).interface_two.n_successful_tx = 0;
    sta(i).interface_two.percent_air_time = 0;
    sta(i).interface_two.percent_success_air_time = 0;
    sta(i).interface_two.n_packet_drop = 0;
    

end

% for i = 1:8
%     if i == 3 || i==6 || i==5
%         sta(i).primary_ch = 23;
%     else
%         sta(i).primary_ch = 5;
%     end
% end

for i = 1:5
    if i == 3 || i == 4
        sta(i).primary_ch = 23;
    else
        sta(i).primary_ch = 5;
    end
end

%initialize apps for each node
ap.app_collection = struct();
flow_type = 3; %1=>high flow(30-50mbps), 2=>med flow(15-30 mbps), 3=>low flow(5-15 mbps)
[app_flow] = get_app_flow(flow_type);
app_flow = [app_flow(1, :); app_flow(3, :); app_flow(5, :); app_flow(7, :); app_flow(9, :);]; %app_flow has flows for non MLO apps as well.

for i = 1: n_sta


    ap.app_collection(i).apps = struct();
    ap.app_collection(i).apps = initialise_apps(n_apps);
    ap.app_collection(i).n_app_started = 0;
    ap.app_collection(i).n_app_stopped = 0;
    flow_arrival = non_mlo_app_start_time (i, :); %change
    flow_stop = non_mlo_app_end_time(i, :);
    ap.app_collection(i).flow_arrival = flow_arrival;
    ap.app_collection(i).flow_stop = flow_stop;
    
    %add flow to each app
    for j = 1: n_apps
        ap.app_collection(i).apps(j).flow = app_flow(i, j);
    end

   % app_collection(i).successful_bits_sent = 0;
    
end



%RUN AP STATE MACHINE
time = 0; %total time taken by mlo algo to take decision across all samples
k=1;
for s=1:num_samples   
%    if s == num_samples
%        break;
%    end
   if rem(s, piece) == 0
       %reallocate occupancy and rssi matrix
       start = s-num_rssi_samples_per_iter;
       stop = s+piece;
       [occupancy_matrix, rssi_matrix] = get_occupancy_matrix_in_pieces(peak_threshold, num_iterations, num_rssi_samples_per_iter, NUM_RFs, 1, 101+piece, occupancy_matrix, rssi_matrix);
       %fprintf("new occupancy matrix loaded. new start at sample %d and new stop at sample %d\n ",start, stop);
       k = num_rssi_samples_per_iter;
       
   end
   if rem (s, 1000000) == 0
       fprintf("we are on sample no %d\n",s);
   end
   if k <= 100
       start_row_occupancy_matrix = 1;
   else
       start_row_occupancy_matrix = k-100;
   end
   [ap, sta, time] = update_slo_mlo_flows_dynamic(ap, s, sta, occupancy_matrix(start_row_occupancy_matrix:k, :), time);
   sta_to_tx = NaN;
   if ap.interface_one.len_q > 0
        sta_to_tx = sta(ap.interface_one.q(1));
   end   
   [ap.interface_one, sta_to_tx] = update_interface_status(ap.interface_one, num_samples, s, sta_to_tx, rssi_matrix(k, :), occupancy_matrix(start_row_occupancy_matrix:k, :), false);
   
   if ap.interface_two.len_q > 0
       sta_to_tx = sta(ap.interface_two.q(1));
   end
   [ap.interface_two, sta_to_tx] = update_interface_status(ap.interface_two, num_samples, s, sta_to_tx, rssi_matrix(k, :), occupancy_matrix(start_row_occupancy_matrix:k, :), true);
   k = k+1;
   
end

%COMPUTE THROUGHPUT OF APs AND STAs
for i = 1:n_sta

     sta(i).interface_one.throughput = (sta(i).interface_one.num_data_bits_received)/((sta(i).association_stop - sta(i).association_start) * T_SAMPLE * 1e+6);
    sta(i).interface_one.percent_air_time = (sta(i).interface_one.num_samples_in_tx/(sta(i).association_stop - sta(i).association_start))*100;
    sta(i).interface_one.percent_success_air_time = (sta(i).interface_one.num_samples_in_tx_success/(sta(i).association_stop - sta(i).association_start))*100;
    sta(i).interface_two.throughput = (sta(i).interface_two.num_data_bits_received)/((sta(i).association_stop - sta(i).association_start) * T_SAMPLE * 1e+6);
    sta(i).interface_two.percent_air_time = (sta(i).interface_two.num_samples_in_tx/(sta(i).association_stop - sta(i).association_start))*100;
    sta(i).interface_two.percent_success_air_time = (sta(i).interface_two.num_samples_in_tx_success/(sta(i).association_stop - sta(i).association_start))*100;
    sta(i).throughput = sta(i).interface_one.throughput + sta(i).interface_two.throughput;
    sta(i).percent_air_time = ((sta(i).interface_one.num_samples_in_tx + sta(i).interface_two.num_samples_in_tx)/num_samples)*100;
    sta(i).percent_success_air_time =((sta(i).interface_one.num_samples_in_tx_success + sta(i).interface_two.num_samples_in_tx_success)/num_samples)*100;
    sta(i).n_packet_drop = sta(i).interface_one.n_packet_drop + sta(i).interface_two.n_packet_drop;

end

[ap] = compute_final_ap_stats(ap, num_samples);
time_taken = toc;

 fprintf('This message is sent at time %s\n', datestr(now,'HH:MM:SS.FFF'));