function  [ap_interface, current_tx_sta_interface ] = update_success_tx_stats(ap_interface, current_tx_sta_interface, L_D, sample_no)
    
    global s_SIFS;
    global s_BACK;
    ap_interface.num_samples_in_tx = ap_interface.num_samples_in_tx + ap_interface.s_FULL_TX;
    ap_interface.num_samples_in_tx_success = ap_interface.num_samples_in_tx_success + ap_interface.s_FULL_TX;
    ap_interface.n_successful_tx = ap_interface.n_successful_tx + 1;
    ap_interface.num_txs = ap_interface.num_txs + 1;
    ap_interface.num_data_bits_sent = ap_interface.num_data_bits_sent + ap_interface.n_agg * L_D;
    ap_interface.num_pkt_sent = ap_interface.num_pkt_sent + ap_interface.n_agg;
    
    if current_tx_sta_interface.time_first_packet_tx == -1

        current_tx_sta_interface.time_first_packet_tx = sample_no - ap_interface.s_DATA - s_SIFS - s_BACK;
    end
    current_tx_sta_interface.sendMSG = 1;
    current_tx_sta_interface.time_last_packet_rx = sample_no;
    current_tx_sta_interface.num_samples_in_tx = current_tx_sta_interface.num_samples_in_tx + ap_interface.s_FULL_TX;
    current_tx_sta_interface.num_samples_in_tx_success = current_tx_sta_interface.num_samples_in_tx_success + ap_interface.s_FULL_TX;
    current_tx_sta_interface.n_successful_tx = current_tx_sta_interface.n_successful_tx + 1;
    current_tx_sta_interface.num_data_bits_received = current_tx_sta_interface.num_data_bits_received + ap_interface.n_agg * L_D;
    current_tx_sta_interface.num_pkts_received = current_tx_sta_interface.num_pkts_received + ap_interface.n_agg;
end