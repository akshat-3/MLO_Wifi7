function [interface, sta] = update_slo_umac_and_lmac(interface, sta, sample_no, is_interface_one)
    
    if is_interface_one
        interface_no = 1;
    else
        interface_no = 2;
    end
    
    it = 1; %using another iterator since the struct's size may decrease in the loop
    for i = 1: interface.slo_umac.active_index_end
       
        %iterate over all active lmac flows

        if interface.slo_lmac.flow_details(it).flow == 0
            %when flow was divided at UMAC this interface got 0mbps. so go
            %to next flow.
            it = it+1;
               continue;
        end

        %check if we are supposed to add packets or not. Previously this
        %was done using a counter
        flow_allocated_to_LMAC_at_sample = interface.slo_lmac.flow_details(it).flow_allocated_to_LMAC_at_sample;
        samples_to_wait_before_allocating_q = interface.slo_lmac.flow_details(it).samples_to_wait_before_allocating_q;
        if rem( (sample_no - flow_allocated_to_LMAC_at_sample), samples_to_wait_before_allocating_q) == 0
            
            %we have to add packets to LMAC
            sta_no = interface.slo_umac.flow_details(it).sta_no;
            %check if there are packets left to add to LMAC
            if interface.slo_umac.flow_details(it).packets_used == interface.slo_umac.flow_details(it).total_packets_possible
                %remove from UMAC, LMAC BOTH if no more packets left to TX
                fprintf("flow over\n");
                
                interface.slo_umac.flow_details(it) = [];
                interface.slo_lmac.flow_details(it) = [];
                interface.slo_lmac.active_index_end = interface.slo_lmac.active_index_end - 1;
                interface.slo_umac.active_index_end = interface.slo_umac.active_index_end-1; 
                interface.slo_umac.length = interface.slo_umac.length - 1;
                %since no more packets left to TX move to next flow
                continue;
            end
            
            if is_interface_one
                sta_interface = sta(sta_no).interface_one;
            else
                sta_interface = sta(sta_no).interface_two;
            end

            %packets are left to add to lmac
            [interface.slo_umac, interface, interface.slo_lmac, sta_interface] = ...
            add_packets_to_lmac_queue(interface.slo_umac, interface, interface.slo_lmac, i, sample_no, sta_interface, true, interface_no);
            %fprintf("here %d\n ", interface.slo_umac.flow_details(it).packets_used);
            
            if is_interface_one
                sta(sta_no).interface_one = sta_interface;
            else
                sta(sta_no).interface_two = sta_interface;
            end

        end

        it = it+1;

    end

end