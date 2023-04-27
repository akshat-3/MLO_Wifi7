function [ap_interface,sta_interface] = did_STA_receive_packet(ap_interface,sta_interface)
    if ap_interface.is_collision == true || ap_interface.tx_collision == true
        sta_interface.packets_received = 0;
    else
        sta_interface.packets_received = ap_interface.n_agg;
    end