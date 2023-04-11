function [mlo_umac, is_mlo_flow_arrived] = is_new_mlo_flow_arrived(mlo_umac, sample_no)
  
   is_mlo_flow_arrived = false;

   while mlo_umac.active_index_end + 1 <= (mlo_umac.length) && mlo_umac.flow_details(mlo_umac.active_index_end+1).start == sample_no
        
       mlo_umac.active_index_end = mlo_umac.active_index_end + 1; 
       is_mlo_flow_arrived = true;

   end

end