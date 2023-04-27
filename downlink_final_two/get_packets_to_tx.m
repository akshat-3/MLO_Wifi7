function [packets_to_tx, interface] = get_packets_to_tx(interface, search_space,i)

    %check which STA to transmit to
   
    sta_to_tx = interface.q(1);
    %fprintf("UNACKED to transmit: %d\n", interface.unACKed(i));
    packets_to_tx = min(search_space, interface.sta_packet_map(sta_to_tx)); %either 256 aggregated(seach_space) or less
    %search_space = min(search_space, interface.len_q);
    %packets_to_tx_ = size(interface.q(interface.q(1:search_space,1) == sta_to_tx));
    %packets_to_tx = packets_to_tx_(1);
 
end