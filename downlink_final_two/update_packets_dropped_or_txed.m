function [interface, sta_to_tx_interface] = update_packets_dropped_or_txed(interface, sta_to_tx_number, sta_to_tx_interface, sample_no, is_packet_drop)

    global n_MAX_TX_ATTEMPTS;
    %remove packets from lmac queue
    %only those packets will be removed which have been rxed/n_tx_attempts==4
    
    packets_to_remove_from_queue = 0;
    n_agg = interface.n_agg;
    for i = 1:n_agg

        if (is_packet_drop && interface.packet_level_details(i).n_tx_attempts >= n_MAX_TX_ATTEMPTS) || ~is_packet_drop
            %packet will be removed from LMAC if it has to be dropped or if
            %it has been rxed
            if interface.packet_level_details(i).n_tx_attempts > n_MAX_TX_ATTEMPTS
                fprintf("here\n");
            end
            packets_to_remove_from_queue = packets_to_remove_from_queue + 1;
            if is_packet_drop
                interface.packet_level_details(i).time_rx = -1; %since packet dropped
            else
                interface.packet_level_details(i).time_rx = sample_no;
            end
        end

    end

    %save packet level details at ap interface, sta_app_wise
    %optimise this
    %file name will be different for different interface
  
    sta_no =  interface.packet_level_details(1).sta_no;

    filename = string(sta_no) + '.txt';
   % fid = fopen(filename, 'a');
    for i = 1:packets_to_remove_from_queue
%       
%         fprintf(fid, '%d,%d,%d,%d,%d,%d,%d,%d,%d\n', interface.packet_level_details(i).time_UMAC, ...
%             interface.packet_level_details(i).time_LMAC, interface.packet_level_details(i).time_tx1,...
%             interface.packet_level_details(i).time_tx2, interface.packet_level_details(i).time_rx, interface.packet_level_details(i).n_tx_attempts,...
%             sta_no, interface.packet_level_details(i).app_no, interface.packet_level_details(i).interface_no);

        packet_level_details = [interface.packet_level_details(i).time_UMAC, ...
            interface.packet_level_details(i).time_LMAC, interface.packet_level_details(i).time_tx1,...
            interface.packet_level_details(i).time_tx2, interface.packet_level_details(i).time_rx, interface.packet_level_details(i).n_tx_attempts,...
            sta_no, interface.packet_level_details(i).app_no, interface.packet_level_details(i).interface_no];
        
        writematrix(packet_level_details,filename,'WriteMode','append');

        %note write table maybe slower
       %remove from packet details
       
    end

    
    %fclose(fid);
    interface.packet_level_details(1:packets_to_remove_from_queue) = [];
    interface.packet_level_details_iterator = interface.packet_level_details_iterator - packets_to_remove_from_queue;
    interface.sta_packet_map(sta_to_tx_number) = interface.sta_packet_map(sta_to_tx_number) - packets_to_remove_from_queue;

    if is_packet_drop
        interface.n_packet_drop = interface.n_packet_drop + packets_to_remove_from_queue;
        sta_to_tx_interface.n_packet_drop = sta_to_tx_interface.n_packet_drop +  interface.n_agg;
    end

    %if no more packets for current sta remove from lmac q  
    if  interface.sta_packet_map(sta_to_tx_number) == 0
        interface.q(1) = [];
        interface.len_q = interface.len_q - 1;     
        %interface.q(len_q) = sta_to_tx_number;      
    end
    %shift the q so the next station to be transmitted to is in the
    %front of the q
    interface.q = circshift(interface.q, -1);
   

end