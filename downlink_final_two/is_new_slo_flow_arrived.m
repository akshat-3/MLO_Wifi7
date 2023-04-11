function [interface, is_slo_flow_arrived] = is_new_slo_flow_arrived(interface, sample_no);
  
  is_slo_flow_arrived = false;
  while interface.slo_umac.active_index_end + 1 <= (interface.slo_umac.length) && interface.slo_umac.flow_details(interface.slo_umac.active_index_end+1).start == sample_no
       
       %new SLO flow at UMAC has arrived
       interface.slo_umac.active_index_end = interface.slo_umac.active_index_end + 1; 
       is_slo_flow_arrived = true;

   end
end