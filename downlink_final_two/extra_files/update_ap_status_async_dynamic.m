function [ap, sta] = update_ap_status_async_dynamic(ap, num_samples, s, sta, rssi, occupancy_matrix)
 
    sample_no_occupancy_matrix_ = size(occupancy_matrix);
    sample_no_occupancy_matrix = sample_no_occupancy_matrix_(1);

    %%WIFI PARAMETERS 
    L_D = 12000; %size of data packet in bits
    T_SAMPLE = 10*1E-6;
    CW = 16; %contention window
    CW_max = 512;
    MCS = 8; 
    T_TXOP_FULL_TX = 5 * 1E-3;  % Time channel will be reserved. Max DATA TXOP in 11ax [5.4 ms]
    %T_TXOP_FULL_TX = 999999 * 1E-3;  % Time channel will be reserved. Max DATA TXOP in 11ax [5.4 ms]
    n_spatial_streams = 1;
    n_MAX_TX_ATTEMPTS = 4;
    
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
    NUM_RFs = 24;
    
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

    %run machine on interface_one
    sample_busy = occupancy_matrix(sample_no_occupancy_matrix, ap.interface_one.primary_channel);%acc to s as s1 not required
            
    switch ap.interface_one.state

        case STATE_IDLE
           
            %s1 = s1 + 1;
            if (ap.interface_one.len_q) ~= 0 %packet in q`
                ap.interface_one.state = STATE_DIFS;
            end
        
        case STATE_DIFS
            %s1 = s1 + 1;

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
            
            %s1 = s1 + 1;
            if ~sample_busy % Idle sample
                if ap.interface_one.bo < ap.interface_one.s_BO

                    ap.interface_one.bo = ap.interface_one.bo + 1;
                    ap.interface_one.state = STATE_BO;

                else
                    occupancy_at_access = occupancy_matrix(sample_no_occupancy_matrix-1,:);
                    
                    [ap.interface_one] = get_tx_params(ap.interface_one, false, occupancy_at_access);
                                
                    if(s+ap.interface_one.s_FULL_TX <= num_samples) %changed s1 to s
                        
                        ap.interface_one.state = STATE_TX;
                       
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

            power_interference = rssi_to_dBm(rssi(1, ap.interface_one.primary_channel),3);
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
                    current_tx_sta = ap.interface_one.q(1);
                    [ap.interface_one, sta(current_tx_sta).interface_one] = update_unsuccess_tx_stats(ap.interface_one, sta(current_tx_sta).interface_one);
                    
                    if ap.interface_one.n_tx_attempts == n_MAX_TX_ATTEMPTS

                        %drop packets since max attempts reached
                        [ap.interface_one, sta(current_tx_sta).interface_one] = update_dropped_packet_stats(ap.interface_one, sta(current_tx_sta).interface_one);
                       
                        %remove packets from q
                        [ap.interface_one] = update_packets_dropped_or_txed(ap.interface_one, current_tx_sta);

                        %change state
                        if (ap.interface_one.len_q) ~= 0 %packet in q`
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
                current_tx_sta= ap.interface_one.q(1);  
                [ap.interface_one, sta(current_tx_sta).interface_one ] = update_success_tx_stats(ap.interface_one, sta(current_tx_sta).interface_one, L_D);

                %remove packets from q
                [ap.interface_one] = update_packets_dropped_or_txed(ap.interface_one, current_tx_sta);
                
                %change state
                if (ap.interface_one.len_q) ~= 0 %packet in q`
                    ap.interface_one.state = STATE_DIFS;
                else 
                    ap.interface_one.state = STATE_IDLE;
                end

                ap.interface_one.difs = 0;
	            ap.interface_one.bo = 0;
                ap.interface_one.CW = CW;
                ap.interface_one.n_tx_attempts = 0;
            end
        
        otherwise
            error('State is not valid!')
    end 


%run machine on interface_two
sample_busy = occupancy_matrix(sample_no_occupancy_matrix, ap.interface_two.primary_channel);%acc to s as s1 not required
            
    switch ap.interface_two.state

        case STATE_IDLE
           
            %s1 = s1 + 1;
            if (ap.interface_two.len_q) ~= 0 %packet in q`
                ap.interface_two.state = STATE_DIFS;
            end
        
        case STATE_DIFS
            %s1 = s1 + 1;

            % Idle sample
            if ~sample_busy
                if ap.interface_two.difs < s_DIFS
                    ap.interface_two.difs = ap.interface_two.difs + 1;
                    ap.interface_two.state = STATE_DIFS;
                else
                    if ap.interface_two.bo == 0 %check if we are in difs because of frozen backoff or not
                        CW = ap.interface_two.CW;
                        ap.interface_two.s_BO = round(1+(CW-1)*rand()); %choose a random backoff
                    end
                    ap.interface_two.state = STATE_BO;
                end
            % Busy sample
            else
                ap.interface_two.difs = 0;
                ap.interface_two.state = STATE_DIFS;
            end

        case STATE_BO
            
            %s1 = s1 + 1;
            if ~sample_busy % Idle sample
                if ap.interface_two.bo < ap.interface_two.s_BO

                    ap.interface_two.bo = ap.interface_two.bo + 1;
                    ap.interface_two.state = STATE_BO;

                else
                    
                   
                    
                    occupancy_at_access = occupancy_matrix(sample_no_occupancy_matrix-1,:);
                    [ap.interface_two] = get_tx_params(ap.interface_two, true, occupancy_at_access);
%                     [packets_to_tx, ap.interface_two] = get_packets_to_tx(ap.interface_two, search_space_lmac);
%                     
%                     N_agg_max2 = packets_to_tx; %no of ones in q1. it should be minimum of i1 and limit(64)
%              
%                     [ap.interface_two.s_FULL_TX, ap.interface_two.s_DATA, ap.interface_two.n_agg] = find_max_pkts_aggregated(N_agg_max2, bw2, s_TXOP_FULL_TX, s_OVERHEAD, MCS, L_D);
%                     ap.interface_two.bw = bw2;
                   
                    
                    if(s+ap.interface_two.s_FULL_TX <= num_samples) %changed s1 to s
                        %some part deleted check throughtput_hinder of
                        %original authors
                        ap.interface_two.state = STATE_TX;
                        %ap.interface_one.num_samples_in_tx = ap.interface_one.num_samples_in_tx + ap.interface_one.s_DATA;

                    else
                        ap.interface_two.state = STATE_DIFS;
	                    ap.interface_two.difs = 0;
	                    ap.interface_two.bo = 0;
                    end
                end
                
            else % sample busy
                ap.interface_two.difs = 0;
                ap.interface_two.state = STATE_DIFS;
            end

        case STATE_TX
            
            %occupancy_matrix(s, ap.interface_two.primary_channel) = 1;

            [ap.interface_two, max_interference_channel] = get_max_interference_channel(ap.interface_two, rssi);
            power_interference = rssi_to_dBm(rssi(1, max_interference_channel),3);
            distance_in_meter = 10;
            ap.interface_two.is_collision = is_collision_caused(ap.interface_two.primary_channel, ap.interface_two.bw, power_interference, MCS, distance_in_meter);

            if ap.interface_two.tx == 0
                
                ap.interface_two.tx = ap.interface_two.s_FULL_TX; %num of samples for which machine will stay in TX state
                ap.interface_two.tx = ap.interface_two.tx - 1; %transmit
                ap.interface_two.n_channel_access = ap.interface_two.n_channel_access + 1;

            elseif ap.interface_two.tx == 1
                
                ap.interface_two.tx = ap.interface_two.tx - 1; %transmit
                ap.interface_two.state = STATE_SIFS;
                ap.interface_two.sifs = 0;

            else
                ap.interface_two.tx = ap.interface_two.tx - 1; %transmit
            end

        case STATE_PIFS

        case STATE_SIFS
            
            if ap.interface_two.sifs < (s_SIFS+s_BACK)

                if ap.interface_two.sifs == s_SIFS && ap.interface_two.is_collision == true
                    %unsuccessful tx
                    current_tx_sta = ap.interface_two.q(1);
                    [ap.interface_two, sta(current_tx_sta).interface_two] = update_unsuccess_tx_stats(ap.interface_two, sta(current_tx_sta).interface_two);

                    if ap.interface_two.n_tx_attempts == n_MAX_TX_ATTEMPTS

                        %drop packets since max attempts reached
                        [ap.interface_two, sta(current_tx_sta).interface_two] = update_dropped_packet_stats(ap.interface_two, sta(current_tx_sta).interface_two);
                        
                        %remove packets from q
                        [ap.interface_two] = update_packets_dropped_or_txed(ap.interface_two, current_tx_sta);

                        %change state
                        if (ap.interface_two.len_q) ~= 0 %packet in q`
                            ap.interface_two.state = STATE_DIFS;
                        else
                            ap.interface_two.state = STATE_IDLE;
                        end

                        ap.interface_two.CW = CW;
                        ap.interface_two.n_tx_attempts = 0;
                        
                    else

                        %double contention window
                        if ap.interface_two.CW < CW_max
                            ap.interface_two.CW = ap.interface_two.CW*2;
                        end
                        %contend for channel access again
                        ap.interface_two.state = STATE_DIFS;
                        ap.interface_two.n_tx_attempts = ap.interface_two.n_tx_attempts + 1;

                    end
                    ap.interface_two.difs = 0;
	                ap.interface_two.bo = 0;
                end
                
                ap.interface_two.sifs = ap.interface_two.sifs + 1;
                

            else
                %successful tx
                %update AP as well as STA stats
                current_tx_sta= ap.interface_two.q(1);  
                [ap.interface_two, sta(current_tx_sta).interface_two ] = update_success_tx_stats(ap.interface_two, sta(current_tx_sta).interface_two, L_D);
                
                %remove packets from lmac queue
                
                [ap.interface_two] = update_packets_dropped_or_txed(ap.interface_two, current_tx_sta);

                %change state
                if (ap.interface_two.len_q) ~= 0 %packet in q`
                    ap.interface_two.state = STATE_DIFS;
                else 
                    ap.interface_two.state = STATE_IDLE;
                end

                ap.interface_two.difs = 0;
	            ap.interface_two.bo = 0;
                ap.interface_two.CW = CW;
                ap.interface_two.n_tx_attempts = 0;

            end
        
        otherwise
            error('State is not valid!')
    end 
 end 


