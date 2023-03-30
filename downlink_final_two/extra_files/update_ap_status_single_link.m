function [ap, sta] = update_ap_status_single_link(ap, num_samples, s, sta)

   
    global occupancy_matrix;
    global rssi_matrix;
    %AP and STA both SLO operating on 5th sub-channel


    %%WIFI PARAMETERS
    max_num_pkts_agg = 64; %change acc to 802.11be
    L_D = 12000; %size of data packet in bits
    T_SAMPLE = 10*1E-6;
    CW = 16; %contention window
    CW_max = 512;
    MCS = 8; 
    T_TXOP_FULL_TX = 5 * 1E-3;  % Time channel will be reserved. Max DATA TXOP in 11ax [5.4 ms]
    %T_TXOP_FULL_TX = 999999 * 1E-3;  % Time channel will be reserved. Max DATA TXOP in 11ax [5.4 ms]
    n_spatial_streams = 1;
    n_MAX_TX_ATTEMPTS = 4;
    NUM_RFs = 24;
    
    [L_MH,L_BACK,L_RTS,L_CTS,L_SF,L_MD,L_TB,L_ACK] = ieee11axMACParams();
    T_DIFS = 50*1E-6 ;
    T_SIFS = 10*1E-6;
    Te = 10*1E-6;
    T_BO = (CW-1)/2 * Te;
    T_RTS = 52*1E-6;
    T_CTS = 44*1E-6;
    T_BACK = 50*1E-6;
    T_PIFS = 25*1E-6;
    T_EMPTY = 9*1E-6;
    BW_SC = 20;
    
    % Convert durations from time to samples (1 sample ---> 10 us)
    s_BO_ORIGINAL = round(T_BO / T_SAMPLE);
    m_BO = 0;
    m_BO_max = 5;
    s_RTS = round(T_RTS / T_SAMPLE);
    s_CTS = round(T_CTS / T_SAMPLE);
    s_BACK = round(T_BACK / T_SAMPLE);
    s_DIFS = round(T_DIFS / T_SAMPLE);
    s_SIFS = round(T_SIFS / T_SAMPLE);
    s_PIFS = round(T_PIFS / T_SAMPLE);
    s_EMPTY = round(T_EMPTY / T_SAMPLE);
    s_TXOP_FULL_TX = round(T_TXOP_FULL_TX / T_SAMPLE);
    
    % T_success = T_RTS + T_SIFS + T_CTS + T_SIFS + T_DATA + T_SIFS + T_BACK + T_DIFS + Te
    s_OVERHEAD = s_RTS + 2 * s_SIFS + s_CTS;
     
    
    
    %%EXPERIMENT PARAMETERS
    STATE_IDLE = -1;    
    STATE_DIFS = 0;
    STATE_BO = 1;
    STATE_PIFS = 2;
    STATE_TX = 3;
    STATE_SIFS = 4;

            
    flow_arrives = false;
    flow_stops = false;
    [ap, sta, flow_arrives, flow_stops] = update_flows(ap, s, ap.association_start, ap.association_end, sta, flow_arrives, flow_stops);

    sample_busy = occupancy_matrix(s, ap.interface_one.primary_channel);%acc to s as s1 not required
            
    switch ap.interface_one.state

        case STATE_IDLE

            if (ap.len_umac) ~= 0 %packet in q`
                ap.interface_one.state = STATE_DIFS;
            end
        
        case STATE_DIFS
       
            % Idle sample
            if ~sample_busy
                if ap.interface_one.difs < s_DIFS
                    ap.interface_one.difs = ap.interface_one.difs + 1;
                    ap.interface_one.state = STATE_DIFS;
                else
                    if ap.interface_one.bo == 0 %check if we are in difs because of frozen backoff or not
                        CW = ap.interface_one.CW;
                        ap.interface_one.s_BO = round(1+(CW-1)*rand()); %choose a random backoff
                    end
                    ap.interface_one.state = STATE_BO;
                end
            % Busy sample
            else
                ap.interface_one.difs = 0;
                ap.interface_one.state = STATE_DIFS;
            end

        case STATE_BO
            
            if ~sample_busy % Idle sample
                if ap.interface_one.bo < ap.interface_one.s_BO

                    ap.interface_one.bo = ap.interface_one.bo + 1;
                    ap.interface_one.state = STATE_BO;

                else
                    
                    num_channels1 = 1; %will be 1 coz not considering channel bonding at interface one
                    ch_range1 = ap.interface_one.primary_channel:ap.interface_one.primary_channel;
                    bw1 = 1 * BW_SC; %since we are considering only single channel
                    
                    [packets_to_tx, ap, ap.interface_one] = get_packets_to_tx(ap, ap.interface_one, max_num_pkts_agg);
                    %check which STA to transmit to
                    sta_at_front = ap.q_umac.Data;
                    sta_to_tx = sta_at_front;

                    curr_node = ap.q_umac;
                    packets_to_tx = 0;
                    
                    %continuous packets of same STA in queue
                    while (~isempty(curr_node)) && packets_to_tx <= max_num_pkts_agg
                        
                        if curr_node.Data ~= sta_to_tx
                            break;
                        end

                        curr_node = curr_node.Next;
                        packets_to_tx = packets_to_tx + 1;


                    end
                   
                    %non continuous packets of same STA in queue
                    search_space = max_num_pkts_agg - packets_to_tx;
                    while search_space > 0 && isempty(curr_node) == false
                        search_space = search_space - 1;
                        next_node = curr_node.Next;
                        prev_node = curr_node.Prev;

                        if curr_node.Data == sta_to_tx

                            removeNode(curr_node);
                            insertAfter(curr_node, ap.q_umac);
                            fprintf("doing this\n");
                           
                            
                            if isempty(next_node) == true
                                ap.tail_umac = prev_node;  
                            end

                            packets_to_tx = packets_to_tx + 1;
                            
                        end

                        curr_node = next_node;
                        
                    end
                    %fprintf("packets to tx = %d, len umac = %d\n", packets_to_tx, ap.len_umac);
                

%                     %OPTIMIZE THIS SEARCH SPACE
%                     search_space = min(ap.len_umac, max_num_pkts_agg);
%                     packets_to_tx = 1;
% 
%                     if search_space > 1
% 
%                         curr_node = ap.q_umac.Next;
% 
%                         for i = 2:search_space
%                             prev_node = curr_node.Prev;
%                             next_node = curr_node.Next;
%                             
%                             if curr_node.Data == sta_to_tx
%                                 
%                                 if curr_node == ap.tail_umac && ap.len_umac > 2
%                                     ap.tail_umac = prev_node;
%                                 end
%                                 
%                                 if ap.q_umac.Next ~= curr_node
%                                     %if head->next is curr node no need to
%                                     %do anything just make changes
%                                     curr_node.insertAfter(ap.q_umac);
%                                     prev_node.Next = next_node;
%                                     next_node.Prev = prev_node;
%                                 end
%                                
%                                packets_to_tx = packets_to_tx + 1;
%                                           
%                             end
% 
%                             curr_node = next_node;
%                             
%                         end
% 
%                     end

                    N_agg_max1 = packets_to_tx; %no of ones in q1. it should be minimum of i1 and limit(64)
             
                    [ap.interface_one.s_FULL_TX, ap.interface_one.s_DATA, ap.interface_one.n_agg] = find_max_pkts_aggregated(N_agg_max1, bw1, s_TXOP_FULL_TX, s_OVERHEAD, MCS, L_D);
                    ap.interface_one.bw = bw1;
                    ap.interface_one.current_rx_sta = sta_to_tx;
                    
                    if(s+ap.interface_one.s_FULL_TX <= num_samples) %changed s1 to s
                        %some part deleted check throughtput_hinder of
                        %original authors
                        ap.interface_one.state = STATE_TX;
                        %ap.interface_one.num_samples_in_tx = ap.interface_one.num_samples_in_tx + ap.interface_one.s_DATA;

                    else
                        ap.interface_one.state = STATE_DIFS;
	                    ap.interface_one.difs = 0;
	                    ap.interface_one.bo = 0;
                    end
                end
                
            else % sample busy
                ap.interface_one.difs = 0;
                ap.interface_one.state = STATE_DIFS;
            end

        case STATE_TX
            
            %occupancy_matrix(s, ap.interface_one.primary_channel) = 1;

            power_interference = rssi_to_dBm(rssi_matrix(s, ap.interface_one.primary_channel),3);
            distance_in_meter = 10;
            ap.interface_one.is_collision = is_collision_caused(ap.interface_one.primary_channel, ap.interface_one.bw, power_interference, MCS, distance_in_meter);
           
            if ap.interface_one.tx == 0
                
                ap.interface_one.tx = ap.interface_one.s_FULL_TX; %num of samples for which machine will stay in TX state
                ap.interface_one.tx = ap.interface_one.tx - 1; %transmit
                ap.interface_one.n_channel_access = ap.interface_one.n_channel_access + 1;

            elseif ap.interface_one.tx == 1
                
                ap.interface_one.tx = ap.interface_one.tx - 1; %transmit
                ap.interface_one.state = STATE_SIFS;
                ap.interface_one.sifs = 0;

            else
                ap.interface_one.tx = ap.interface_one.tx - 1; %transmit
            end

        case STATE_PIFS

        case STATE_SIFS
            
            if ap.interface_one.sifs < (s_SIFS+s_BACK)

                if ap.interface_one.sifs == s_SIFS && ap.interface_one.is_collision == true
                    %unsuccessful tx

                    ap.interface_one.is_collision = false;
                    ap.interface_one.n_collision = ap.interface_one.n_collision + 1;
                    current_tx_sta = ap.interface_one.current_rx_sta;
                    sta(current_tx_sta).interface_one.n_collision = sta(current_tx_sta).interface_one.n_collision + 1;
                    ap.interface_one.num_samples_in_tx = ap.interface_one.num_samples_in_tx + ap.interface_one.s_FULL_TX;
                    sta(current_tx_sta).interface_one.num_samples_in_tx = sta(current_tx_sta).interface_one.num_samples_in_tx + ap.interface_one.s_FULL_TX;

                    if ap.interface_one.n_tx_attempts == n_MAX_TX_ATTEMPTS

                        %drop packets since max attempts reached

                        packets_to_remove = ap.interface_one.n_agg;
        
                        %go to new head, remove everything else before head
                        new_head = ap.q_umac;

                        while packets_to_remove > 0
                            next = new_head.Next;
                            removeNode(new_head);
                            clear new_head;
                            new_head = next;
                            packets_to_remove = packets_to_remove - 1;
                        end
                        
                        

                        ap.q_umac = new_head;
                        if isempty(new_head) == true
                            
                            %whole q trasnmitted
                            ap.tail_umac = ap.q_umac;
                        end
                        ap.len_umac = ap.len_umac - ap.interface_one.n_agg;

                        %change state
                        if (ap.len_umac) ~= 0 %packet in q`
                            ap.interface_one.state = STATE_DIFS;
                        else
                            ap.interface_one.state = STATE_IDLE;
                        end

                        ap.interface_one.CW = CW;
                        ap.interface_one.n_tx_attempts = 0;
                        
                    else

                        %double contention window
                        if ap.interface_one.CW < CW_max
                            ap.interface_one.CW = ap.interface_one.CW*2;
                        end
                        %contend for channel access again
                        ap.interface_one.state = STATE_DIFS;
                        ap.interface_one.n_tx_attempts = ap.interface_one.n_tx_attempts + 1;

                    end
                    ap.interface_one.difs = 0;
	                ap.interface_one.bo = 0;
                end
                
                ap.interface_one.sifs = ap.interface_one.sifs + 1;
                

            else
                %successful tx
                %update AP as well as STA stats
                current_tx_sta= ap.interface_one.q.Data;  
                [ap.interface_one, sta(current_tx_sta).interface_one ] = update_success_tx_stats(ap.interface_one, sta(current_tx_sta).interface_one, L_D);

                %update u_mac queue

                packets_to_remove = ap.interface_one.n_agg;

                %go to new head, remove everything else before head
                new_head = ap.q_umac;

                while packets_to_remove > 0
                    next = new_head.Next;
                    removeNode(new_head);
                    clear new_head;
                    new_head = next;
                    packets_to_remove = packets_to_remove - 1;
                end
                
                

                ap.q_umac = new_head;
                if isempty(new_head) == true
                    
                    %whole q trasnmitted
                    ap.tail_umac = ap.q_umac;
                end
                ap.len_umac = ap.len_umac - ap.interface_one.n_agg;

                
                ap.interface_one.CW = CW;
                ap.interface_one.n_tx_attempts = 0;

                %change state
                if (ap.len_umac) ~= 0 %packet in q`
                    ap.interface_one.state = STATE_DIFS;
                else 
                    ap.interface_one.state = STATE_IDLE;
                end

                ap.interface_one.difs = 0;
	            ap.interface_one.bo = 0;

            end
        
        otherwise
            error('State is not valid!')
    end 
end               

%% - Function: Compute data and ack transmission times
function [t_data, t_ack] = get_data_tx_duration(n_agg, BW, MCS,L_D)
    [L_MH,L_BACK,L_RTS,L_CTS,L_SF,L_MD,L_TB,L_ACK] = ieee11axMACParams() ;
    [r,r_leg,T_OFDM,T_OFDM_leg,T_PHY_leg,T_PHY_HE_SU] = ieee11axPHYParams(BW,MCS,1); %1 is spatial stream
    r = r*(1e+6);
    r_leg = r_leg*(1e+6);
    if n_agg == 1
        t_data = T_PHY_HE_SU + ceil( ( L_SF + L_MH + L_D + L_TB) / r) * T_OFDM;
        t_ack  = T_PHY_leg + ceil( (L_SF + L_ACK + L_TB) / r_leg ) * T_OFDM_leg;
        %t_data= 1000*1E-6;
        %t_ack= 6*1E-6; 
    else
        t_data = T_PHY_HE_SU + ceil( ( L_SF + n_agg * (L_MD + L_MH + L_D) + L_TB) / r) * T_OFDM;
        t_ack  = T_PHY_leg + ceil( (L_SF + L_BACK + L_TB) / r_leg ) * T_OFDM_leg;
        %t_data= (1000*1E-6)*n_agg;
        %t_ack= 5*1E-6; 
    end
end


 
function [s_full_tx, s_data, num_pkts_agg] = find_max_pkts_aggregated(max_num_pkts_agg, bw, s_TXOP, s_OVERHEAD, MCS, L_D)
            
    %max_num_pkts_agg = number of ones in the q.
    
    num_pkts_agg = max_num_pkts_agg;
   
    s_data = 0;
    s_full_tx = 0;
    T_SAMPLE = 10*1E-6;

    %we will try to agg the max amount of packets we can
    %if we fail then decrement the num of agg packets and try again
    while num_pkts_agg > 0
    
        % Compute data TX duration according to BW (11ax or not)
        if bw == 20 || bw == 40 || bw == 80 || bw == 160
            %printf('bw is 11ax')
            t_data = get_data_tx_duration(num_pkts_agg, bw, MCS, L_D);
        else
            %printf('bw is NOT 11ax')
            t_data_sc = get_data_tx_duration(num_pkts_agg, BW_SC, MCS, L_D);
            num_channels_aux = bw / BW_SC;
            t_data = t_data_sc / num_channels_aux;
        end
        
        s_BACK = 5;
        s_data = round(t_data / T_SAMPLE);
        s_full_tx = s_data + s_OVERHEAD;
        %fprintf('s_full_tx (%d) [s_data (%d)] <? s_TXOP_11ax(%d)', s_full_tx, s_data, s_TXOP)

        rate_tx_in_mbps = (num_pkts_agg*L_D)/(s_full_tx*10);
        link_capacity = ieee11axPHYParams(bw,MCS,1);

        
        if s_full_tx <= s_TXOP %&& rate_tx_in_mbps <= link_capacity
            while rate_tx_in_mbps > link_capacity

                s_data = s_data + 1;
                s_full_tx = s_full_tx+1;
                rate_tx_in_mbps = (num_pkts_agg*L_D)/(s_full_tx*10);
                
            end

            if s_full_tx > s_TXOP
                num_pkts_agg = num_pkts_agg - 1;
                continue;
            end

            break;     
        else
            num_pkts_agg = num_pkts_agg - 1;
        end
        
    end
            
end