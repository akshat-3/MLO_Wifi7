function  [ap, sta] = update_umac_and_lmac(ap, sample_no, sta)

    mlo_umac = ap.mlo_umac; %do this for optimisation
    interface_one = ap.interface_one;
    interface_two = ap.interface_two;

    %what happens when more than one MLO flow arrives/ stops at one sample
    %TO-DO: Make changes for above.
   
    %add packets to lmac interface one
    %%interface one SLO flows
    it = 1; %using another iterator since the struct's size may decrease in the loop
    for i = 1: interface_one.slo_umac.active_index_end
       
        %iterate over all active lmac flows

        if interface_one.slo_lmac.flow_details(it).flow == 0
            %when flow was divided at UMAC this interface got 0mbps. so go
            %to next flow.
            it = it+1;
               continue;
        end

        if interface_one.slo_lmac.flow_details(it).x == 0
           %if counter (x) has expired, add packets in queue.

           %x -> counter, x_->start value of counter,
           %samples_to_wait will change when allocation algo allocated it a
           %different flow. 

           sta_no = interface_one.slo_umac.flow_details(it).sta_no;

           interface_one.slo_lmac.flow_details(it).x = interface_one.slo_lmac.flow_details(it).x_; 

           %check if there are packets left to add to LMAC
           if interface_one.slo_umac.flow_details(it).packets_used == interface_one.slo_umac.flow_details(it).total_packets_possible
                %remove from UMAC, LMAC BOTH if no more packets left to TX
                fprintf("flow over\n");
                
                interface_one.slo_umac.flow_details(it) = [];
                interface_one.slo_lmac.flow_details(it) = [];
                interface_one.slo_lmac.active_index_end = interface_one.slo_lmac.active_index_end - 1;
                interface_one.slo_umac.active_index_end = interface_one.slo_umac.active_index_end-1; 
                interface_one.slo_umac.length = interface_one.slo_umac.length + 1;
                %since no more packets left to TX move to next flow
                continue;
            end
           
           %packets are left to add to lmac
           [interface_one.slo_umac, interface_one, interface_one.slo_lmac, sta(sta_no).interface_one] = ...
                update_lmac_queue(interface_one.slo_umac, interface_one, interface_one.slo_lmac, i, sample_no, sta(sta_no).interface_one, true);
           %fprintf("here %d\n ", interface_one.slo_umac.flow_details(it).packets_used);
        else
           %update counter
           interface_one.slo_lmac.flow_details(it).x = interface_one.slo_lmac.flow_details(it).x - 1;
        end
        it = it+1;
    end


    %repeat the above function for interface one MLO flow, interface two
    %SLO flow, interface two MLO flow

    it = 1;
    %%interface one MLO flows
    for i = 1: mlo_umac.active_index_end

        if interface_one.mlo_lmac.flow_details(it).flow == 0
            it = it+1;
               continue;
        end
        
        if interface_one.mlo_lmac.flow_details(it).x == 0
           
           sta_no = mlo_umac.flow_details(it).sta_no;

           interface_one.mlo_lmac.flow_details(it).x = interface_one.mlo_lmac.flow_details(it).x_; 

           if mlo_umac.flow_details(it).packets_used == mlo_umac.flow_details(it).total_packets_possible
                %remove from UMAC, LMAC BOTH
                fprintf("flow over\n");
                
                mlo_umac.flow_details(it) = [];
                interface_one.mlo_lmac.flow_details(it) = [];
                interface_one.mlo_lmac.active_index_end = interface_one.mlo_lmac.active_index_end - 1;
                mlo_umac.active_index_end = mlo_umac.active_index_end-1; 
                mlo_umac.length = mlo_umac.length -1;
                continue;
            end
           
           [mlo_umac, interface_one, interface_one.mlo_lmac, sta(sta_no).interface_one] = ...
                update_lmac_queue(mlo_umac, interface_one, interface_one.mlo_lmac, i, sample_no, sta(sta_no).interface_one, false);
           
        else
           interface_one.mlo_lmac.flow_details(it).x = interface_one.mlo_lmac.flow_details(it).x - 1;
        end
        it = it+1;
    end

    %add packets to lmac interface two
    it = 1;
    %%interface two SLO flows
    for i = 1: interface_two.slo_umac.active_index_end

        if interface_two.slo_lmac.flow_details(it).flow == 0
               it = it+1;
               continue;
        end
        
        if interface_two.slo_lmac.flow_details(it).x == 0
           
           sta_no = interface_two.slo_umac.flow_details(it).sta_no;

           interface_two.slo_lmac.flow_details(it).x = interface_two.slo_lmac.flow_details(it).x_; 

           if interface_two.slo_umac.flow_details(it).packets_used == interface_two.slo_umac.flow_details(it).total_packets_possible
                %remove from UMAC, LMAC BOTH
                fprintf("flow over\n");
                
                interface_two.slo_umac.flow_details(it) = [];
                interface_two.slo_lmac.flow_details(it) = [];
                interface_two.slo_lmac.active_index_end = interface_two.slo_lmac.active_index_end - 1;
                interface_two.slo_umac.active_index_end = interface_two.slo_umac.active_index_end-1; 
                interface_two.slo_umac.length = interface_two.slo_umac.length + 1;
                continue;
            end
           
           [interface_two.slo_umac, interface_two, interface_two.slo_lmac, sta(sta_no).interface_two] = ...
                update_lmac_queue(interface_two.slo_umac, interface_two, interface_two.slo_lmac, i, sample_no, sta(sta_no).interface_two, true);
           
        else
           interface_two.slo_lmac.flow_details(it).x = interface_two.slo_lmac.flow_details(it).x - 1;
        end
        it = it+1;
    end

    it = 1;
    %%interface two MLO flows
    for i = 1:  mlo_umac.active_index_end

        if interface_two.mlo_lmac.flow_details(it).flow == 0
            it = it+1;
               continue;
        end
        
        if interface_two.mlo_lmac.flow_details(it).x == 0


           sta_no = mlo_umac.flow_details(it).sta_no;

           interface_two.mlo_lmac.flow_details(it).x = interface_two.mlo_lmac.flow_details(it).x_; 

           if mlo_umac.flow_details(it).packets_used == mlo_umac.flow_details(it).total_packets_possible
                %remove from UMAC, LMAC BOTH
                fprintf("flow over\n");
                
                mlo_umac.flow_details(it) = [];
                interface_two.mlo_lmac.flow_details(it) = [];
                interface_two.mlo_lmac.active_index_end = interface_two.mlo_lmac.active_index_end - 1;
                mlo_umac.active_index_end = mlo_umac.active_index_end-1; 
                mlo_umac.length = mlo_umac.length -1;
                continue;
            end
           
           [mlo_umac, interface_two, interface_two.mlo_lmac, sta(sta_no).interface_two] = ...
                update_lmac_queue(mlo_umac, interface_two, interface_two.mlo_lmac, i, sample_no,  sta(sta_no).interface_two, false);
          
           
        else
           interface_two.mlo_lmac.flow_details(it).x = interface_two.mlo_lmac.flow_details(it).x - 1;
        end
        it = it+1;
    end
%     
     ap.mlo_umac = mlo_umac;
     ap.interface_one = interface_one;
     ap.interface_two =interface_two;
     

end
               