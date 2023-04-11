function [umac, interface, interface_lmac, sta_interface] = add_packets_to_lmac_queue(umac, interface, interface_lmac, flow_num, sample_no, sta_interface, is_slo_sta, interface_no)
  
    %assumption flow > 0 
    %assumption application has CBR
    global T_SAMPLE;
    sta_no = umac.flow_details(flow_num).sta_no;
    app_no = umac.flow_details(flow_num).app_no;
    
    
    start_time = umac.flow_details(flow_num).start;
    end_time = umac.flow_details(flow_num).stop; 


    %UMAC CALCULATIONS
    %Note: packets_to_add no of packets generated at start_time as well
    samples_to_wait_before_allocating_q = umac.flow_details(flow_num).samples_to_wait_before_allocating_q; %app specific
    packets_to_add = umac.flow_details(flow_num).packets_to_add_in_q; %app specific
    packets_which_should_be_avail_at_curr_sample = (fix((sample_no-start_time)/samples_to_wait_before_allocating_q) + start_time)*packets_to_add; %6/5 = 1.2 fix(6/5)=1 fix strips decimal digits
    packets_used =  umac.flow_details(flow_num).packets_used;
    packets_available_at_curr_sample = packets_which_should_be_avail_at_curr_sample - packets_used;
   
    if packets_available_at_curr_sample <= 0
        return;
    end

    %LMAC CALCULATION
    packets_to_add_in_lmac =  min(packets_available_at_curr_sample, interface_lmac.flow_details(flow_num).packets_to_add_in_q);

    %calculate latencies


    s=0; %sample at which the new packet will be generated at UMAC. Eg: if we have to add
    %4 packets to LMAC, s denotes the sample number at which the first one
    %of the four packets to be added to LMAC was generated at UMAC 
    %calculations below are based on the fact that we use a CBR application
    
    if rem( packets_used, packets_to_add ) == 0
        s = start_time + (packets_used*samples_to_wait_before_allocating_q)/packets_to_add;
        %if packets used is 0 packets are generated when the app turns on
        %i.e start_time
    else
        packets_used_temp = packets_used - rem( packets_used, packets_to_add );
        s = start_time + (packets_used_temp*samples_to_wait_before_allocating_q)/packets_to_add;
    end

    k = packets_to_add_in_lmac;

    i = 0;
    while k > 0 %, run this loop to calculate time at which packets were generated at UMAC

        %packets_to_add number of packets are generated at each 
        % x interval. x = samples_to_wait_before_allocating_q
     
        %this loop iterates over packets_to_add number of packet since
        %packets_to_add number of packets are generated at the same fixed time 
        for m = 1:packets_to_add

            if k==0
                break;
            end

            if i == 0 && m <= rem( packets_used, packets_to_add )
                
                continue; 
                %suppose packets_used = 4, packets_to_add (UMAC rate) = 3
                %here out of packets_to_add rem( packets_used,
                %packets_to_add ) number of packets were already added
                %some time ago.
                
            else
                len = length(interface.packet_level_details) + 1;
                interface.packet_level_details_iterator = interface.packet_level_details_iterator + 1;
                interface.packet_level_details(len).time_UMAC = s;
                interface.packet_level_details(len).time_LMAC = sample_no;
                interface.packet_level_details(len).sta_no = sta_no;
                interface.packet_level_details(len).app_no = app_no;
                interface.packet_level_details(len).interface_no = interface_no;
                k = k-1;
            end

        end

        i = i+1;
        s = s + samples_to_wait_before_allocating_q*i;
    end


    %end latency calculation

    %add in l_mac
    if  interface.sta_packet_map(sta_no) == 0
    
        %fprintf("sta %d not present\n",sta_no);
        interface.q(interface.len_q + 1) = sta_no;
        interface.len_q = interface.len_q + 1;
    
    end
    
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
    