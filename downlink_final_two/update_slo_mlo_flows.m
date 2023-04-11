function [ap, sta, time] = update_slo_mlo_flows(ap, sample_no, sta, time, historical_occupancy_matrix)

   %1. Updates UMAC and LMAC queue with any new packets if they arrive  
   %2. Checks if there are newly active slo or mlo flows 
   %3. Calls allocation algorithm accordingly
       
   %slo and mlo flow stopping is handled in update_umac_and_lmac and
   %update_lmac_queue
   [ap, sta] = update_umac_and_lmac(ap, sample_no, sta); %putting this here so that if flows stops its not allocated when mlo allocation algo is called
   

   interface_one = ap.interface_one;
   interface_two = ap.interface_two;
   mlo_umac = ap.mlo_umac;

   %Check if any new SLO flows arrived at UMAC

   %Interface One
   [interface_one, slo_flow_arrives_interface_one] = is_new_slo_flow_arrived(interface_one, sample_no);
   if (slo_flow_arrives_interface_one)  %calculate flow and allocate it to links

        fprintf("slo flow arrived interface one\n");
        is_interface_one = true;
        [interface_one] = allocate_slo_flow(interface_one, sample_no, is_interface_one, interface_one.primary_channel, interface_two.primary_channel, historical_occupancy_matrix, ap.rate_mcs_latest(1)); %allocate slo flow to LMAC
        
   end

   %Interface Two
   [interface_two, slo_flow_arrives_interface_two] = is_new_slo_flow_arrived(interface_two, sample_no); 
   if (slo_flow_arrives_interface_two)  %calculate flow and allocate it to links
        
       fprintf("slo flow arrived interface two\n");
       is_interface_one = false;
       [interface_two] = allocate_slo_flow(interface_two, sample_no, is_interface_one, interface_one.primary_channel, interface_two.primary_channel, historical_occupancy_matrix, ap.rate_mcs_latest(2));

  end

  %Check if any new MLO flow arrived at UMAC
  [mlo_umac, mlo_flow_arrives] = is_new_mlo_flow_arrived(mlo_umac, sample_no); 

  if mlo_flow_arrives  %calculate flow and allocate it to links

    %change name of function which runs allocation algorithm in this code
    %to make this dynamic change to allocate_mlo_flow_dynamic
    [interface_one, interface_two, mlo_umac, time, ap.soft_threshold, ap.hard_threshold, ap.nint] = allocate_mlo_flow_static(interface_one, interface_two, mlo_umac, historical_occupancy_matrix, ap.soft_threshold, ap.hard_threshold, ap.nint, ap.rate_mcs_latest, time, sample_no);
    

  end

  ap.interface_one = interface_one;
  ap.interface_two = interface_two;
  ap.mlo_umac = mlo_umac;
    
end