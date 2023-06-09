function [interface, sta_to_tx_interface] = update_interface_status(interface, num_samples, sample_no, sta_to_tx_interface, rssi, occupancy_matrix, is_channel_bonding, occupancy_at_access)
 

    %%WIFI PARAMETERS 
    L_D = 12000; %size of data packet in bits
    T_SAMPLE = 10*1E-6;
    CW = 16; %contention window
    CW_max = 512;
    MCS = 8; 
    T_TXOP_FULL_TX = 5 * 1E-3;  % Time channel will be reserved. Max DATA TXOP in 11ax [5.4 ms]
    %T_TXOP_FULL_TX = 999999 * 1E-3;  % Time channel will be reserved. Max DATA TXOP in 11ax [5.4 ms]
    n_spatial_streams = 1;
    global n_MAX_TX_ATTEMPTS;
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
    global s_BACK;
    s_BACK = round(T_BACK / T_SAMPLE);
    s_DIFS = round(T_DIFS / T_SAMPLE);
    global s_SIFS;
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
    STATE_RECEIVE = 5;

    max_percent_failed_samples_allowed = 20; %in one tx if %failed samples are above this percentage the collision. failed sample => snr threshold falls below threshold

    %run machine on interface_one
    sample_busy = occupancy_matrix(1, interface.primary_channel);%acc to s as s1 not required
            
    switch interface.state

        case STATE_RECEIVE
            interface.state = interface.previous_state;

        case STATE_IDLE
           
            %s1 = s1 + 1;
            if (interface.len_q) ~= 0 %packet in q`
                interface.state = STATE_DIFS;
            end
        
        case STATE_DIFS
            %s1 = s1 + 1;
            interface.contention_time = interface.contention_time + 1; 
            % Idle sample
            if ~sample_busy
                if interface.difs < s_DIFS

                    interface.difs = interface.difs + 1;
                    interface.state = STATE_DIFS;

                else
                    if interface.bo == 0 %check if we are in difs because of frozen backoff or not
                        
                        CW = interface.CW;
                        interface.s_BO = round(1+(CW-1)*rand()); %choose a random backoff

                    end
                    interface.state = STATE_BO;
                end
            % Busy sample
            else
                interface.difs = 0;
                interface.state = STATE_DIFS;
            end

        case STATE_BO
            interface.contention_time = interface.contention_time + 1; 
            %s1 = s1 + 1;
            if ~sample_busy % Idle sample
                if interface.bo < interface.s_BO

                    interface.bo = interface.bo + 1;
                    interface.state = STATE_BO;

                else
                  
                    [interface] = get_tx_params(interface, is_channel_bonding, occupancy_at_access,sta_to_tx_interface.number);
                                
                    if(sample_no+interface.s_FULL_TX <= num_samples) %changed s1 to s
                        
                        interface.state = STATE_TX;

                        %can this be optimised?
                        for i = 1:interface.n_agg

                            if isempty(interface.packet_level_details(i).time_tx1)
                               
                                interface.packet_level_details(i).time_tx1 = sample_no;
                                interface.packet_level_details(i).time_tx2 = sample_no;
                                interface.packet_level_details(i).n_tx_attempts = 1;
                            else
                                interface.packet_level_details(i).time_tx2 = sample_no;
                                interface.packet_level_details(i).n_tx_attempts = interface.packet_level_details(i).n_tx_attempts + 1;
                            end

                        end

                    else
                        interface.state = STATE_DIFS;
	                    interface.difs = 0;
	                    interface.bo = 0;
                    end
                end
                
            else % sample busy
                interface.difs = 0;
                interface.state = STATE_DIFS;
            end

        case STATE_TX
            %node stays in this state for T_RTS+T_SIFS+T_CTS+T_SIFS+T_DATA
           % occupancy_matrix(1, interface.primary_channel) = 1;
            power_interference = rssi_to_dBm(rssi(1, interface.primary_channel),3);
            distance_in_meter = 10;
            interface.count_below_snr = count_below_snr(interface.primary_channel, interface.bw, power_interference, MCS, distance_in_meter, interface.count_below_snr);

            if interface.tx == 0
                
                interface.tx = interface.s_FULL_TX;
                interface.tx = interface.tx - 1; %transmit
                interface.n_channel_access = interface.n_channel_access + 1;

            elseif interface.tx == 1
                
                interface.tx = interface.tx - 1; %transmit
                interface.is_collision = is_collision_caused(interface.count_below_snr, interface.s_DATA, max_percent_failed_samples_allowed);
                interface.count_below_snr = 0;
                interface.state = STATE_SIFS;
                interface.sifs = 0;
                %[interface,sta_to_tx_interface] = did_STA_receive_packet(interface, sta_to_tx_interface);


            else
                interface.tx = interface.tx - 1; %transmit
            end

            
            %check if RTS/CTS frames transmitted correctly 
            %if not transmitted then go to SIFS
            %if RTS/CTS transmitted correctly then stay in TX
            if interface.tx == interface.s_DATA
                interface.is_collision = is_collision_caused(interface.count_below_snr, interface.s_FULL_TX - interface.s_DATA, max_percent_failed_samples_allowed);
                if interface.is_collision
                    
                    interface.state = STATE_SIFS;
                    interface.sifs = 0;
                    %[interface,sta_to_tx_interface] = did_STA_receive_packet(interface, sta_to_tx_interface);
                    
                end
                interface.count_below_snr = 0;
            end
                
          
        case STATE_PIFS

        case STATE_SIFS
            
            if interface.sifs < (s_SIFS+s_BACK)

                if (interface.sifs == s_SIFS) && (interface.is_collision == true || interface.tx_collision == true)
                    %unsuccessful tx
                    sta_to_tx_number = interface.q(1);
                    [interface, sta_to_tx_interface] = update_unsuccess_tx_stats(interface, sta_to_tx_interface, sample_no);
                    
                    if interface.packet_level_details(1).n_tx_attempts == n_MAX_TX_ATTEMPTS

                        %remove packets from q and update packet latency
                        is_packet_drop = true;
                        [interface, sta_to_tx_interface] = update_packets_dropped_or_txed(interface, sta_to_tx_number, sta_to_tx_interface, sample_no, is_packet_drop);

                        %change state
                        if (interface.len_q) ~= 0 %packet in q`
                            interface.state = STATE_DIFS;
                        else
                            interface.state = STATE_IDLE;
                        end

                        interface.CW = CW;
                        
                        
                    else
                        
                        %double contention window
                        if interface.CW < CW_max
                            interface.CW = interface.CW*2;
                        end
                        %contend for channel access again
                        interface.state = STATE_DIFS;
                        

                    end
                    interface.difs = 0;
	                interface.bo = 0;
                end
                
                interface.sifs = interface.sifs + 1;
                

            else
                %successful tx
                %update AP as well as STA stats
                sta_to_tx_number= interface.q(1);  
                [interface, sta_to_tx_interface] = update_success_tx_stats(interface, sta_to_tx_interface, L_D, sample_no);

             
                %remove packets from q and update packet latency
                is_packet_drop = false;
                [interface, sta_to_tx_interface] = update_packets_dropped_or_txed(interface, sta_to_tx_number, sta_to_tx_interface, sample_no, is_packet_drop);
                
                %change state
                if (interface.len_q) ~= 0 %packet in q`
                    interface.state = STATE_DIFS;
                else 
                    interface.state = STATE_IDLE;
                end

                interface.difs = 0;
	            interface.bo = 0;
                interface.CW = CW;
               
                
            end
        
        otherwise
            error('State is not valid!')
    end

    
end
