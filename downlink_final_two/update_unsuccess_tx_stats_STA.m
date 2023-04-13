function [ap_interface, sta_interface] = update_unsuccess_tx_stats(ap_interface, sta_interface, sample_no)
    
    global s_SIFS;
    global s_BACK;
    if sta_interface.time_first_packet_tx == -1

        sta_interface.time_first_packet_tx = sample_no - ap_interface.s_DATA - s_SIFS - s_BACK;
        
    end
    sta_to_tx_interface.is_collision = false;
    ap_interface.ACK_received = -1;
    ap_interface.n_collision = ap_interface.n_collision + 1;
    sta_interface.n_collision = sta_interface.n_collision + 1;
    ap_interface.num_samples_in_tx = ap_interface.num_samples_in_tx + ap_interface.s_FULL_TX;
    sta_interface.num_samples_in_tx = sta_interface.num_samples_in_tx + ap_interface.s_FULL_TX;
    
end