function [interface] = get_tx_params(interface, is_bonding, occupancy_at_access)
%calculate tranmission parameters like bw, num samples req to tx, num
%packets aggregated
    
    L_D = 12000; %size of data packet in bits
    T_SAMPLE = 10*1E-6;
    MCS = 8; 
    T_TXOP_FULL_TX = 5 * 1E-3;  % Time channel will be reserved. Max DATA TXOP in 11ax [5.4 ms]
    
    T_DIFS = 50*1E-6 ;
    T_SIFS = 10*1E-6;
    T_RTS = 52*1E-6;
    T_CTS = 44*1E-6;
    T_BACK = 50*1E-6;
    T_PIFS = 25*1E-6;
    T_EMPTY = 9*1E-6;
    BW_SC = 20;
    
    % Convert durations from time to samples (1 sample ---> 10 us)
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
    
    search_space_lmac = 256; %max aggregation possible
    if is_bonding
       
        [num_channels, ch_left, ch_right] = channel_bonding_wifi_ax_acc_to_sliced_occ_matrix(occupancy_at_access, interface.primary_channel);
        bw = num_channels * BW_SC;

    else

        num_channels = 1; %will be 1 coz not considering channel bonding at interface one
        bw = num_channels * BW_SC; %since we are considering only single channel
        
    end

    %[packets_to_tx, interface] = get_packets_to_tx(interface, search_space_lmac);
    packets_to_tx = 1;
    N_agg_max = packets_to_tx; %no of ones in q1. it should be minimum of i1 and limit(64)
    [interface.s_FULL_TX, interface.s_DATA, interface.n_agg] = find_max_pkts_aggregated(N_agg_max, bw, s_TXOP_FULL_TX, s_OVERHEAD, MCS, L_D);   
    
    interface.bw = bw;

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