function [packets_to_tx, interface] = get_packets_to_tx_STA(interface)

    %check which STA to transmit to
   
    %sta_to_tx = interface.q(1);
    packets_to_tx = interface.packets_received/2; %either 256 aggregated(seach_space) or less
    %search_space = min(search_space, interface.len_q);
    %packets_to_tx_ = size(interface.q(interface.q(1:search_space,1) == sta_to_tx));
    %packets_to_tx = packets_to_tx_(1);
 
end