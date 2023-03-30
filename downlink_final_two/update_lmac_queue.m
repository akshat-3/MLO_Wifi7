function [umac, interface, interface_lmac, sta_interface] = update_lmac_queue(umac, interface, interface_lmac, flow_num, sample_no, sta_interface, is_slo_sta)
  
%assumption flow > 0 
    global T_SAMPLE;
    sta_no = umac.flow_details(flow_num).sta_no;
    
    start_time = umac.flow_details(flow_num).start;
    end_time = umac.flow_details(flow_num).stop; 


    %UMAC CALCULATIONS
    samples_to_wait = umac.flow_details(flow_num).samples_to_wait_before_allocating_q; %app specific
    packets_to_add = umac.flow_details(flow_num).packets_to_add_in_q; %app specific

    packets_which_should_be_avail_at_curr_sample = (fix((sample_no-start_time)/samples_to_wait))*packets_to_add;%6/5 = 1.2 fix(6/5)=1 fix strips decimal digits
    packets_used =  umac.flow_details(flow_num).packets_used;
    packets_available_at_curr_sample = packets_which_should_be_avail_at_curr_sample - packets_used;
   

    
     
    if packets_available_at_curr_sample <= 0
        return;
    end

    %LMAC CALCULATION
    packets_to_add_in_lmac =  min(packets_available_at_curr_sample, interface_lmac.flow_details(flow_num).packets_to_add_in_q);
    
    %add in l_mac
    if  interface.sta_packet_map(sta_no) == 0
    
        %fprintf("sta %d not present\n",sta_no);
        interface.q(interface.len_q + 1) = sta_no;
        interface.len_q = interface.len_q + 1;
    
    end

    %calculate latencies


%     sample_at_which_app_generated_packets_added_in_lmac = start_time + (packets_used*samples_to_wait)/packets_to_add; %time at which last of packets added in lmac were generated.
%     
%     temp = min(packets_to_add_in_lmac, rem(packets_used, packets_to_add));
%     temp2 = packets_to_add_in_lmac;
%     
%     if rem(packets_used, packets_to_add) > 0
%         %for rem(packets_used, packets_to_add) number of packets time at
%         %which added to umac is according to below formula
%         
%         for i = 1: temp
%       
%             sta_interface.latency_stats(end+1, 1:2) = ...
%                 [start_time + (packets_used*samples_to_wait)/packets_to_add, sample_no]; %1. time at which packet was added to umac, 2. time at which packet added to lmac
%             temp2 = temp2 - 1; %this packet's time has been calculated
%          
%         end
% 
%     end
% 
%     if temp2 > 0
%         %more packet's time have to calculated
%         for i = 1:temp2
%             sta_interface.latency_stats(end+1, 1:2) = ...
%                [(start_time + (packets_used*samples_to_wait)/packets_to_add) + fix((i/packets_to_add)*samples_to_wait), sample_no]; %time at which packet was added to umac %time at which packet added to lmac
%             disp(sta_interface.latency_stats(end,:))
%         end
%     end
%   
    interface.sta_packet_map(sta_no) = interface.sta_packet_map(sta_no) + packets_to_add_in_lmac;
    
    %remove from umac
    %fprintf("here %d packets to add are %d\n", umac.flow_details(flow_num).packets_used, packets_to_add_in_lmac);
    umac.flow_details(flow_num).packets_used = umac.flow_details(flow_num).packets_used + packets_to_add_in_lmac;
    
    if is_slo_sta
        interface.slo_umac = umac;
        interface.slo_lmac = interface_lmac;
    else
        interface.mlo_lmac = interface_lmac;
    end

   

end
    