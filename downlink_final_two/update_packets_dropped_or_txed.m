function [interface] = update_packets_dropped_or_txed(interface, current_tx_sta, sample_no)

  %this function updates the lmac queue
    
%     if interface.n_tx_attempts == n_MAX_TX_ATTEMPTS
%         interface.n_dropped_packets = interface.n_dropped_packets+packets_to_remove_from_queue; 
%     end

%     packets_to_remove_from_queue = 0;
% 
%     if interface.n_tx_attempts == n_MAX_TX_ATTEMPTS
%         %collision has occured
%         interface.n_tx_attempts = 0;
%         packets_dropped = interface.retransmit(1, 1);
%         packets_to_remove_from_queue = packets_dropped;
% 
%         %updating packets.retransmit
%         size_ = size(interface.retransmit);
%         size__ = size_(1,1);
%         iterator = 0;
%         diff_in_packets = 0;
%         while diff_in_packets == 0
% 
%             iterator = iterator + 1;
%             diff_in_packets = interface.retransmit(iterator, 1) - n_packets_dropped;
%             
%         end
%         
%         %update their latency and update total number of packets dropped
%         interface.n_packets_dropped = interface.n_packets_dropped + packets_dropped;
%         interface.latency_stats(interface.all_four_times_recorded_latency_idx+1:interface.all_four_times_recorded_latency_idx+n_packets_dropped, 3) = ...
%             interface.retransmit(iterator-1, 2); %tx time
%         interface.latency_stats(interface.all_four_times_recorded_latency_idx+1:interface.all_four_times_recorded_latency_idx+n_packets_dropped, 4) = ...
%             inf; %rx time inf since dropped packets
%         interface.all_four_times_recorded_latency_idx = interface.all_four_times_recorded_latency_idx + n_packets_dropped;
% 
%         if size__ == 1 
%              %don't remove from retransmit        
%         else
%            interface.retransmit(1:iterator-1, :) = [];
%         end
% 
%         for i = iterator:size__
% 
%             diff_in_packets = interface.retransmit(i, 1) - n_packets_dropped;
%             interface.retransmit(1, 1) = interface.retransmit(1, 1) - diff_in_packets;
%             interface.n_tx_attempts = interface.n_tx_attempts + 1;
%                   
%         end
%          
% 
%     else
%         %success!
%         interface.n_tx_attempts = 0;
%         
%         %all packets txed or different latency
%         %update their latency and update total number of packets dropped
%         size_ = size(interface.retransmit);
%         size__ = size_(1,1);
%         n_packets_txed = interface.retransmit(1, 1);
%         packets_to_remove_from_queue = n_packets_txed;
% 
%         %all will be removed
%         iterator = 1;
%         diff_in_packets = 0;
%         while diff_in_packets == 0
% 
%             diff_in_packets = interface.retransmit(iterator, 1) - n_packets_dropped;
%             iterator = iterator+1;
%         end
%         
%         %update their latency and update total number of packets txed
%         interface.latency_stats(interface.all_four_times_recorded_latency_idx+1:interface.all_four_times_recorded_latency_idx+n_packets_txed, 3) = ...
%             interface.retransmit(iterator - 1, 2); %tx time
%         interface.latency_stats(interface.all_four_times_recorded_latency_idx+1:interface.all_four_times_recorded_latency_idx+n_packets_txed, 4) = ...
%             inf; %CHANGE
%         interface.all_four_times_recorded_latency_idx = interface.all_four_times_recorded_latency_idx + n_packets_txed;
% 
%         if size__ == 1 
%              %don't remove from retransmit        
%         else
%            interface.retransmit(1:iterator-1, :) = [];
%         end
% 
%         prev_packets_txed = n_packets_txed;
%         for i = iterator:size__
%             
%             diff_in_packets = interface.retransmit(i, 1) - prev_packets_txed;
%             
%             if diff_in_packets > 0
%                 %but these can also differ?
%                 packets_to_remove_from_queue = packets_to_remove_from_queue + diff_in_packets;
%                 interface.latency_stats(interface.all_four_times_recorded_latency_idx+1:interface.all_four_times_recorded_latency_idx + diff_in_packets, 3) = ...
%                     interface.retransmit(i, 2); %tx time
%                 interface.latency_stats(interface.all_four_times_recorded_latency_idx+1:interface.all_four_times_recorded_latency_idx + diff_in_packets, 4) = ...
%                     inf; %CHANGE
%                 interface.all_four_times_recorded_latency_idx = interface.all_four_times_recorded_latency_idx + diff_in_packets;
%     
%                 if i == size__
%                 else
%                     interface.retransmit(i, :) = [];
%                 end
%             end
%        
%                       
%         end
%         
%     end

    %remove packets from lmac queue
    global n_MAX_TX_ATTEMPTS;
    packets_to_remove_from_queue  = interface.n_agg; 
    interface.sta_packet_map(current_tx_sta) = interface.sta_packet_map(current_tx_sta) - packets_to_remove_from_queue;
    
    %if no more packets for current sta remove from lmac q
    %shift the q so the next station to be transmitted to is in the
    %front of the q
  
    if  interface.sta_packet_map(current_tx_sta) == 0
        interface.q(1) = [];
        interface.len_q = interface.len_q - 1;     
        %interface.q(len_q) = current_tx_sta;      
    end
    interface.q = circshift(interface.q, -1);
   

end