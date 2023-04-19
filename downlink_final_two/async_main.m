diary slci_logs_twenty_mins.txt;
fprintf('This message is sent at time %s\n', datestr(now,'HH:MM:SS.FFF'));
tic;
file=fopen('uplink.txt','w');
%get occupancy matrix and rssi matrix
%remember to change offset on get occupancy matrix by piece
num_iterations = 200; % max value 2001 %800
num_rssi_samples_per_iter = 10000;%100000
NUM_RFs = 24; 
peak_threshold = 150; %in WACA code  its 150. for testing purpose taking it as 50
historical_samples_req = 100; %donot start an MLO flow at <= this sample number %this is done specifically at for our algorithms

rssi_matrix = zeros(num_rssi_samples_per_iter, NUM_RFs);
occupancy_matrix = zeros(num_rssi_samples_per_iter, NUM_RFs);

iteration_no = 1;
[occupancy_matrix, rssi_matrix] = ...
    get_occupancy_matrix_in_pieces(peak_threshold, num_rssi_samples_per_iter, NUM_RFs, iteration_no, occupancy_matrix, rssi_matrix);        

historical_occupancy_matrix = zeros(historical_samples_req, NUM_RFs);

num_samples = num_iterations * num_rssi_samples_per_iter;
global T_SAMPLE;
T_SAMPLE = 10*1E-6;

n_sta = 10; %CHANGE IN MULTI LINK
n_apps = 6;
n_mlo_sta = 6;
n_slo_sta_interface_one = 3;
n_slo_sta_interface_two = 1;
[sta_association_start, non_mlo_association_start, mlo_association_start, sta_association_end, ...
    non_mlo_association_end, mlo_association_end, app_start_time, app_end_time, mlo_app_start_time, non_mlo_app_start_time,...
    mlo_app_end_time, non_mlo_app_end_time] = sta_apps_time();

flow_type = 3;
[app_flow] = get_app_flow(flow_type);

%% AP PARAMETERS

ap.n_apps_per_sta = n_apps;
ap.n_mlo_sta = n_mlo_sta;
ap.n_slo_sta_interface_one = n_slo_sta_interface_one;
ap.n_slo_sta_interface_two = n_slo_sta_interface_two;
ap.n_sta = n_sta;
ap.total_flow = 0;
ap.throughput = 0;
ap.percent_air_time = 0;
ap.percent_success_air_time = 0;
ap.n_packet_drop = 0;
ap.time_first_packet_tx = -1; %thorughput calc
ap.time_last_packet_rx = -1; %if simulation time over but we still are in TX state then what? 


%AP UMAC MLO QUEUE
ap.mlo_umac = struct(); 
ap.mlo_umac.flow_details = struct(); %contains info about flows. flows are sorted in ascending order of starting time
ap.mlo_umac.length = 0;
ap.mlo_umac.active_index_end = 0;

%AP UMAC SLO QUEUE
%separate for interface one and two
ap.interface_one.slo_umac = struct();
ap.interface_one.slo_umac.flow_details = struct();
ap.interface_one.slo_umac.length = 0;
ap.interface_one.slo_umac.active_index_end = 0; %1 to active_index_end number of flows are active. denotes the index of last flow which is active

ap.interface_two.slo_umac = struct();
ap.interface_two.slo_umac.flow_details = struct();
ap.interface_two.slo_umac.length = 0;
ap.interface_two.slo_umac.active_index_end = 0;

%AP MLO Parameters
ap.soft_threshold = [0.4,0.5,0.5];  %this should be input to MLO algo. keep changing
ap.hard_threshold = [0.7,0.85,0.8]; %this should be input to MLO algo. keep changing
ap.percentage_available_channel = [0.0, 0.0, 0.0];
ap.channel_occupancy = [0.0, 0.0];
ap.rate_mcs_latest = [97.5, 97.5]; %in ieee phy params
ap.nint = 2;

%AP and STA
ap.association_start = sta_association_start; %time at which sta get associated to ap
ap.association_end = sta_association_end; %dummy variable created only to keep a check 
% on when an app which sends traffic to a particular sta stops generating
% traffic (time at which app stops generating packets <= ap.association_end)
%actual sta association end time is when all packets to that sta are
%transmitted. 

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
ap.interface_one.sta_packet_map = zeros(1, 1);  
ap.interface_one.q = zeros(1);
ap.interface_one.len_q = 0;
%lmac mlo flow details
ap.interface_one.mlo_lmac = struct();
ap.interface_one.mlo_lmac.flow_details = struct();
ap.interface_one.mlo_lmac.active_index_end = 0;
%lmac slo flow details
ap.interface_one.slo_lmac = struct();
ap.interface_one.slo_lmac.flow_details = struct();
ap.interface_one.slo_lmac.active_index_end = 0;

%packet_level_details
ap.interface_one.packet_level_details = struct('time_UMAC', {}, 'time_LMAC', {}, 'time_tx1', {}, 'time_tx2', {}, ...
    'time_rx', {},'n_tx_attempts', {},'sta_no', {},'app_no', {},'interface_no', {}); 
%struct will contain:
%i)time at which packet entered UMAC ii)time at which packet entered LMAC
%iii)time of first tx at,tempt iv)time of last tx attempt v)time rx/drop 
%vi)num of attempts taken to transmit/drop. vii)app_no viii)sta_no 
%ix)interface number
ap.interface_one.packet_level_details_iterator = 0; %points to the last packet detail in this struct
%currently zero packets so iterator = 0
%note after every rx successful/packet drop, packet info is saved in a csv
%file and iterator is decreased since some packet details will be moved to
%the csv file.
%packet level details are modified in add_packets_to_lmac_queue(),
%update_packets_dropped_or_txed() and update_interface_status()

%interface1 stats
ap.interface_one.state = -1; %state_interface1
ap.interface_one.num_data_bits_sent = 0; %num_data_bits_sent_interface1 = 0
ap.interface_one.num_txs = 0; %num_txs_interface1 = 0
ap.interface_one.primary_channel = 3; %primary_channel_interface1
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
ap.interface_one.time_first_packet_tx = -1; %throughput calc
ap.interface_one.time_last_packet_rx = -1; %throughput calc
ap.interface_one.n_channel_access = 0;%n_first_channel_gains_access = 0;
ap.interface_one.link_rate = 0;%link_one_data_rate = 0;
ap.interface_one.retransmit = zeros(1, 2); %num packets, sample no
ap.interface_one.contention_time = 0;
ap.interface_one.ACK_received = 0;

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
%lmac mlo flows
ap.interface_two.mlo_lmac = struct();
ap.interface_two.mlo_lmac.flow_details = struct();
ap.interface_two.mlo_lmac.active_index_end = 0;
%lmac slo flows
ap.interface_two.slo_lmac = struct();
ap.interface_two.slo_lmac.flow_details = struct();
ap.interface_two.slo_lmac.active_index_end = 0;

%packet_level_details
ap.interface_two.packet_level_details = struct('time_UMAC', {}, 'time_LMAC', {}, 'time_tx1', {}, 'time_tx2', {}, ...
    'time_rx', {},'n_tx_attempts', {},'sta_no', {},'app_no', {},'interface_no', {}); 
ap.interface_two.packet_level_details_iterator = 0; %points to the last packet detail in this struct


%interface 2 stats
ap.interface_two.state = -1; %state_interface1
ap.interface_two.num_data_bits_sent = 0;% num_data_bits_sent_interface1 = 0;
ap.interface_two.num_txs = 0; %num_txs_interface1 = 0;
ap.interface_two.primary_channel = 21; %primary_channel_interface1 its actually channel no 23 but since occupancy_matrix is sliced in new matrix channel num = 11
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
ap.interface_two.time_first_packet_tx = -1; %throughput calc
ap.interface_two.time_last_packet_rx = -1; %thorughput calc
ap.interface_two.n_channel_access = 0;%n_first_channel_gains_access = 0;
ap.interface_two.link_rate = 0;%link_one_data_rate = 0;
ap.interface_two.retransmit = zeros(1, 2); %num packets, sample no
ap.interface_two.contention_time = 0;
ap.interface_two.ACK_received = 0;

sta = struct();

%initialize STA
%sta should have a association begin and association end time (not possion distribution). they should
%stay associated for 15-30 minutes

for i = 1: n_sta
    %association start and end
    sta(i).association_start  = sta_association_start(i);
    sta(i).association_stop = sta_association_end(i);
    if rem(i,2) == 0 || i==9
        sta(i).is_mlo = true;
    else
        sta(i).is_mlo = false;
    end
    sta(i).throughput = 0;
    sta(i).percent_success_air_time = 0;
    sta(i).percent_air_time = 0;
    sta(i).packets_not_sent_since_sta_disassociated = 0;
    %sta(i).time_first_packet_tx = -1;
    %sta(i).time_last_packet_rx = -1;
    
    %interface1 stats
    sta(i).interface_one.state = -1; %state_interface1
    sta(i).interface_one.difs = 0;  % interface 1 DIFS counter
    sta(i).interface_one.bo = 0;  % interface 1 BO counter
    sta(i).interface_one.CW = 16;
    sta(i).interface_one.s_BO = 0;
    sta(i).interface_one.s_FULL_TX = 0;
    sta(i).interface_one.n_agg = 1;
    sta(i).interface_one.count_below_snr = 0;
    sta(i).interface_one.bw  = 0;
    sta(i).interface_one.tx = 0;
    sta(i).interface_one.s_FULL_TX  = 0;
    sta(i).interface_one.n_channel_access = 0;
    sta(i).interface_one.is_collision = false;
    sta(i).interface_one.s_DATA = 0;
    sta(i).interface_one.sifs = 0;
    sta(i).interface_one.primary_channel = 3;
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
    sta(i).interface_one.time_first_packet_tx = -1; %thorughput calc
    sta(i).interface_one.time_last_packet_rx = -1;%thorughput calc
    %sta(i).interface_one.latency_stats = zeros(1, 3); %[packet_arrives_at_umac packet_gets_txed packet_gets_rxed]
    sta(i).interface_one.iterator_packet_at_umac = 0;
    sta(i).interface_one.iterator_packet_tx = 0;
    sta(i).interface_one.iterator_packet_rx = 0;
    sta(i).interface_one.latency_dataset_number = 0;
    sta(i).interface_one.latency_stats = zeros(1, 4);%[time_packet_enters_umac, time_packet_enters_lmac, time_packet_tx, time_packet_rx]
    sta(i).interface_one.all_four_times_recorded_latency_idx = 0;
    sta(i).interface_one.contention_time = 0;
    sta(i).interface_one.sendMSG = 0;
    sta(i).interface_one.packet_level_details = struct('time_UMAC', {}, 'time_LMAC', {}, 'time_tx1', {}, 'time_tx2', {}, ...
    'time_rx', {},'n_tx_attempts', {},'sta_no', {},'app_no', {},'interface_no', {}); 
    sta(i).interface_one.packet_level_details_iterator = 0;
    len = 1;
    sta(i).interface_one.packet_level_details_iterator =  sta(i).interface_one.packet_level_details_iterator + 1;
    sta(i).interface_one.packet_level_details(len).interface_no = 1;
    sta(i).interface_one.no_of_tx_state_received = 0;
    %interface2 stats
    sta(i).interface_two.state = -1; %state_interface2
    sta(i).interface_two.difs = 0;  % interface 2 DIFS counter
    sta(i).interface_two.bo = 0; %backoff counter
    sta(i).interface_two.CW = 16;
    sta(i).interface_two.s_BO = 0;
    sta(i).interface_two.s_FULL_TX = 0;
    sta(i).interface_two.n_agg = 1;
    sta(i).interface_two.count_below_snr = 0;
    sta(i).interface_two.bw  = 0;
    sta(i).interface_two.tx = 0;
    sta(i).interface_two.s_FULL_TX  = 0;
    sta(i).interface_two.n_channel_access = 0;
    sta(i).interface_two.is_collision = false;
    sta(i).interface_two.s_DATA = 0;
    sta(i).interface_two.sifs = 0;
    sta(i).interface_two.primary_channel = 21;
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
    sta(i).interface_two.time_first_packet_tx = -1; %thorughput calc
    sta(i).interface_two.time_last_packet_rx = -1; %thorughput calc
   % sta(i).interface_two.latency_stats = zeros(1, ); %[packet_arrives_at_umac packet_gets_txed packet_gets_rxed]
    sta(i).interface_two.iterator_packet_at_umac = 0;
    sta(i).interface_two.iterator_packet_tx = 0;
    sta(i).interface_two.iterator_packet_rx = 0;
    sta(i).interface_two.latency_dataset_number = 0;
    sta(i).interface_two.latency_stats = zeros(1, 4);%[time_packet_enters_umac, time_packet_enters_lmac, time_packet_tx, time_packet_rx]
    sta(i).interface_two.all_four_times_recorded_latency_idx = 0;
    sta(i).interface_two.contention_time = 0;
    sta(i).interface_two.sendMSG = 0;
    sta(i).interface_two.packet_level_details = struct('time_UMAC', {}, 'time_LMAC', {}, 'time_tx1', {}, 'time_tx2', {}, ...
    'time_rx', {},'n_tx_attempts', {},'sta_no', {},'app_no', {},'interface_no', {}); 
    sta(i).interface_two.packet_level_details_iterator = 0;
    len = 1;
    sta(i).interface_two.packet_level_details_iterator =  sta(i).interface_two.packet_level_details_iterator + 1;
    sta(i).interface_two.packet_level_details(len).interface_no = 2;
    sta(i).interface_two.no_of_tx_state_received = 0;
end

%this property should only be used for SLO stas. this tells which is the
%primary sta's channel
for i = 1:n_sta
    %FOR SLO STATIONS ONLY
    if i == 7 
        sta(i).primary_ch = ap.interface_two.primary_channel;
    else
        sta(i).primary_ch = ap.interface_one.primary_channel;
    end

end

%initialize umac mlo and slo flows' properties
%umac structure has the attributes: flow_details, length(which is the
%length of flow_details) and active_index_end which points to 
%the latest flow which started generating packets. So at the beginning of
%the simulation active_index_end = 0 (since no flow is active) but length
%will be initialized in the below function to the total number of mlo flows
%expected in the duration
%flow_details has the flowing properties:1) flow(mbps), 2) sta no., 3) app no.
%corresponding to that sta no., 4) flow start sample no, 5) flow stop sample no.,
%6) samples_to_wait, 7) packets_to_add (mbps->packets/sample )
%8) packets_used which accounts for the number of packets transmitted to LMAC at the current sample number. at
%sample no 0, packets used will be 0
%9) x_ which is basically the counter which countsdown to samples_to_wait and
%after that packets_to_add number of packets get added to the q
%10) total_packets_possible: which is the no of packets an app can generate
%given its rate, start time and end time. 
[ap] = initialise_umac_flows_and_their_properties(ap, sta, app_start_time, app_end_time, app_flow);


time = 0; %total time taken by mlo algo to take decision across all samples

%RUN AP STATE MACHINE
k = 1;
occupancy_at_access = zeros(1, NUM_RFs);
sample_no = 1; %this iterator actually tells which sample number we are on

for s=(historical_samples_req+1):num_samples   %the iterator s accounts for historical occupancy matrix
 
   if s == 2000*1000000
       break;
   end

   if rem (s, 1000000) == 0
       fprintf("we are on sample no %d\n",s);
   end

   %LOAD OCCUPANCY MATRIX 
   if rem(s, num_rssi_samples_per_iter) == 0

       %reallocate occupancy and rssi matrix
       iteration_no= iteration_no + 1;
       historical_occupancy_matrix = occupancy_matrix(end - historical_samples_req + 1:end,:); 
       [occupancy_matrix, rssi_matrix] = ...
            get_occupancy_matrix_in_pieces(peak_threshold, num_rssi_samples_per_iter, NUM_RFs, iteration_no, occupancy_matrix, rssi_matrix);        
     
       k = 1;  

   end 
   if k>1
       %historical occupancy matrix
       occupancy_at_access = occupancy_matrix(k-1,:);
       historical_occupancy_matrix = [historical_occupancy_matrix(2:end, :); occupancy_at_access];   
   end

   
   %UPDATE UMAC, LMAC QUEUES. RUN FLOW ALLOCATION ALGORITHM IF REQUIRED
    [ap, sta, time] = update_slo_mlo_flows(ap, sample_no, sta, time, historical_occupancy_matrix);
  
   
   %If interface is in BO/TX state, check which station it is trying to
   %transmit to
  
    sta_no = 1;
    if ap.interface_one.len_q > 0
        sta_no = ap.interface_one.q(1);
    end
   %UPDATE INTERFACE ONE STATE
 
    [ap.interface_one, sta(sta_no).interface_one] = update_interface_status(ap.interface_one, num_samples, sample_no, sta(sta_no).interface_one, rssi_matrix(k, :), occupancy_matrix(k, :), false, occupancy_at_access);
    %create a for loop to update all the sta's interface one state
    for i = 1:n_sta
        [ap.interface_one, sta(i).interface_one] = update_interface_status_STA(ap.interface_one, num_samples, sample_no, sta(i).interface_one, rssi_matrix(k, :), occupancy_matrix(k, :), false, occupancy_at_access);
    end
   %If interface is in BO/TX state, check which station it is trying to
   %transmit to 
    sta_no = 1;
    if ap.interface_two.len_q > 0
        sta_no = ap.interface_two.q(1);
    end 
   %UPDATE INTERFACE TWO STATE
   
    [ap.interface_two, sta(sta_no).interface_two] = update_interface_status(ap.interface_two, num_samples, sample_no, sta(sta_no).interface_two, rssi_matrix(k, :), occupancy_matrix(k, :), true, occupancy_at_access);
    for i = 1:n_sta
        [ap.interface_two, sta(i).interface_two] = update_interface_status_STA(ap.interface_two, num_samples, sample_no, sta(i).interface_two, rssi_matrix(k, :), occupancy_matrix(k, :), true, occupancy_at_access);
    end
   k = k+1;
   sample_no = sample_no + 1;

end

fprintf("\n %d ap i1 bits", ap.interface_one.num_data_bits_sent);
fprintf("\n %d ap i2 bits", ap.interface_two.num_data_bits_sent);
for i = 1:n_sta
    fprintf("\n %d sta(%d) i1 bits", sta(i).interface_one.num_data_bits_received,i);
    fprintf("\n %d sta(%d) i2 bits", sta(i).interface_two.num_data_bits_received,i);
end

interface_one_time_ap_sent_first_packet = inf;
interface_one_time_ap_sent_last_packet = -inf;
interface_two_time_ap_sent_first_packet = inf;
interface_two_time_ap_sent_last_packet = -inf;


%COMPUTE THROUGHPUT OF APs AND STAs
for i = 1:n_sta
    
    %note the below line
    %sta dissociates when all packets are sent.
    if (sta(i).is_mlo == false && sta(i).primary_ch == ap.interface_two.primary_channel) || sta(i).interface_one.time_first_packet_tx == -1

        sta(i).interface_one.throughput = 0;
        sta(i).interface_one.percent_air_time = 0;
        sta(i).interface_one.percent_success_air_time = 0;

    else
        interface_one_time_ap_sent_first_packet = min(interface_one_time_ap_sent_first_packet, sta(i).interface_one.time_first_packet_tx);
        interface_one_time_ap_sent_last_packet = max(interface_one_time_ap_sent_last_packet, sta(i).interface_one.time_last_packet_rx );
        sta_interface_one_duration = sta(i).interface_one.time_last_packet_rx - sta(i).interface_one.time_first_packet_tx;
        sta(i).interface_one.throughput = (sta(i).interface_one.num_data_bits_received)/(sta_interface_one_duration * T_SAMPLE * 1e+6);
        sta(i).interface_one.percent_air_time = (sta(i).interface_one.num_samples_in_tx/sta_interface_one_duration)*100;
        sta(i).interface_one.percent_success_air_time = (sta(i).interface_one.num_samples_in_tx_success/sta_interface_one_duration)*100;
    end
    
    if (sta(i).is_mlo == false && sta(i).primary_ch == ap.interface_one.primary_channel) || sta(i).interface_two.time_first_packet_tx == -1
        sta(i).interface_two.throughput = 0;
        sta(i).interface_two.percent_air_time = 0;
        sta(i).interface_two.percent_success_air_time = 0;
    else
        
        interface_two_time_ap_sent_first_packet = min(interface_two_time_ap_sent_first_packet, sta(i).interface_two.time_first_packet_tx);
        interface_two_time_ap_sent_last_packet = max(interface_two_time_ap_sent_last_packet, sta(i).interface_two.time_last_packet_rx );
        sta_interface_two_duration = sta(i).interface_two.time_last_packet_rx - sta(i).interface_two.time_first_packet_tx;
        sta(i).interface_two.throughput = (sta(i).interface_two.num_data_bits_received)/(sta_interface_two_duration * T_SAMPLE * 1e+6);
        sta(i).interface_two.percent_air_time = (sta(i).interface_two.num_samples_in_tx/sta_interface_two_duration)*100;
        sta(i).interface_two.percent_success_air_time = (sta(i).interface_two.num_samples_in_tx_success/sta_interface_two_duration)*100;
    end

    if isnan(sta(i).interface_one.throughput)
        sta(i).interface_one.throughput = 0;
    end

    if isnan(sta(i).interface_two.throughput)
        sta(i).interface_two.throughput = 0;
    end
    sta(i).throughput = sta(i).interface_one.throughput + sta(i).interface_two.throughput;
%     sta(i).percent_air_time = ((sta(i).interface_one.num_samples_in_tx + sta(i).interface_two.num_samples_in_tx)/(2 * sta_association_duration))*100;
%     sta(i).percent_success_air_time = ((sta(i).interface_one.num_samples_in_tx_success + sta(i).interface_two.num_samples_in_tx_success)/(2 * sta_association_duration))*100;
    sta(i).n_packet_drop = sta(i).interface_one.n_packet_drop + sta(i).interface_two.n_packet_drop;

end

ap_interface_one_duration = interface_one_time_ap_sent_last_packet - interface_one_time_ap_sent_first_packet; 
ap.interface_one.throughput = ap.interface_one.num_data_bits_sent/(ap_interface_one_duration * T_SAMPLE * 1e+6);
ap_interface_two_duration = interface_two_time_ap_sent_last_packet - interface_two_time_ap_sent_first_packet; 
ap.interface_two.throughput = ap.interface_two.num_data_bits_sent/(ap_interface_two_duration * T_SAMPLE * 1e+6);

ap.throughput = ap.interface_one.throughput + ap.interface_two.throughput;


count_slo = 0;
interface_one_slo_throughput = 0;
count_interface_one_slo = 0;
interface_two_slo_throughput = 0;
count_interface_two_slo = 0;

count_mlo = 0;
interface_one_mlo_throughput = 0;
interface_two_mlo_throughput = 0;

for i = 1:n_sta
    if ~sta(i).is_mlo
        if sta(i).primary_ch == ap.interface_one.primary_channel
            %interface one
            interface_one_slo_throughput = interface_one_slo_throughput + sta(i).interface_one.throughput;
            count_interface_one_slo = count_interface_one_slo + 1;
        else
            %interface two
            interface_two_slo_throughput = interface_two_slo_throughput  + sta(i).interface_two.throughput;
            count_interface_two_slo = count_interface_two_slo + 1;
        end
    else
        interface_one_mlo_throughput = interface_one_mlo_throughput + sta(i).interface_one.throughput;  
        interface_two_mlo_throughput = interface_two_mlo_throughput + sta(i).interface_two.throughput;

        count_mlo = count_mlo + 1;
    end
end

interface_one_slo_throughput = interface_one_slo_throughput/count_interface_one_slo;
interface_two_slo_throughput = interface_two_slo_throughput/count_interface_two_slo;
total_slo_throughput = interface_one_slo_throughput + interface_two_slo_throughput;

interface_one_mlo_throughput = interface_one_mlo_throughput/count_mlo;
interface_two_mlo_throughput = interface_two_mlo_throughput/count_mlo;
total_mlo_throughput = interface_one_mlo_throughput + interface_two_mlo_throughput;

%when sta is dissociated?when all of the packets generated by apps
%corresponding to that sta are sent
 
[ap] = compute_final_ap_stats(ap, num_samples);
time_taken = toc; 
fprintf('This message is sent at time %s\n', datestr(now,'HH:MM:SS.FFF'));
diary off;
