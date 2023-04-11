function [interface, sta, mlo_umac] = update_mlo_umac_and_lmac(interface, sta, mlo_umac, sample_no, is_interface_one)

    if is_interface_one
        interface_no = 1;
    else
        interface_no = 2;
    end

    it = 1;
  
    for i = 1: mlo_umac.active_index_end

        if interface.mlo_lmac.flow_details(it).flow == 0
            it = it+1;
               continue;
        end

        flow_allocated_to_LMAC_at_sample = interface.mlo_lmac.flow_details(it).flow_allocated_to_LMAC_at_sample;
        samples_to_wait_before_allocating_q = interface.mlo_lmac.flow_details(it).samples_to_wait_before_allocating_q;
        
        %check if we have to add packets according the counter 
        if rem( (sample_no - flow_allocated_to_LMAC_at_sample), samples_to_wait_before_allocating_q) == 0

            %we have to add packets to LMAC
            sta_no = mlo_umac.flow_details(it).sta_no;
            %check if there are packets left to add to LMAC
            if mlo_umac.flow_details(it).packets_used == mlo_umac.flow_details(it).total_packets_possible
                %remove from UMAC, LMAC BOTH if no more packets left to TX
                fprintf("flow over\n");
                
                mlo_umac.flow_details(it) = [];
                interface.mlo_lmac.flow_details(it) = [];
                interface.mlo_lmac.active_index_end = interface.mlo_lmac.active_index_end - 1;
                mlo_umac.active_index_end = mlo_umac.active_index_end-1; 
                mlo_umac.length = mlo_umac.length - 1;
                %since no more packets left to TX move to next flow
                continue;
            end
            
            if is_interface_one
                sta_interface = sta(sta_no).interface_one;
            else
                sta_interface = sta(sta_no).interface_two;
            end

            %packets are left to add to lmac
            [mlo_umac, interface, interface.mlo_lmac, sta_interface] = ...
            add_packets_to_lmac_queue(mlo_umac, interface, interface.mlo_lmac, i, sample_no, sta_interface, true, interface_no);
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