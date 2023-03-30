function [ap, sta, time] = update_slo_mlo_flows(ap, sample_no, sta, time, historical_occupancy_matrix)

%1. Updates UMAC and LMAC queue with any new packets if they arrive  
%2. Checks if there are newly active slo or mlo flows 
%3. Calls allocation algorithm accordingly
    
   time_period_allocation = 1; %5 seconds
   s_time_period_allocation = time_period_allocation/(10*1e-6);
   round_no = 0;
   n_int = 2;

   

   mlo_flow_arrives = false;
   slo_flow_arrives_interface_one = false;
   slo_flow_arrives_interface_two = false;
   
   n_apps = ap.n_apps_per_sta;
   n_mlo_sta = ap.n_mlo_sta;
   n_slo_sta_interface_one = ap.n_slo_sta_interface_one;
   n_slo_sta_interface_two = ap.n_slo_sta_interface_two;

   
   [ap, sta] = update_umac_and_lmac(ap, sample_no, sta); %putting this here so that if flows stops its not allocated when mlo allocation algo is called
   

   interface_one = ap.interface_one;
   interface_two = ap.interface_two;
   mlo_umac = ap.mlo_umac;

   %Check if any new flows arrived at UMAC

   while interface_one.slo_umac.active_index_end + 1 <= (interface_one.slo_umac.length) && interface_one.slo_umac.flow_details(interface_one.slo_umac.active_index_end+1).start == sample_no
       %new SLO flow at UMAC has arrived (SLO sta is associated on interface one)
       interface_one.slo_umac.active_index_end = interface_one.slo_umac.active_index_end + 1; 
       slo_flow_arrives_interface_one = true;

   end

    if (slo_flow_arrives_interface_one)  %calculate flow and allocate it to links

        fprintf("slo flow arrived interface one\n");
        n_active_umac_slo_interface_one_flows = interface_one.slo_umac.active_index_end;
        n_active_lmac_slo_interface_one_flows = interface_one.slo_lmac.active_index_end;
        
        for i = n_active_lmac_slo_interface_one_flows + 1 : n_active_umac_slo_interface_one_flows
            
            interface_one.slo_lmac.flow_details(i).flow = interface_one.slo_umac.flow_details(i).flow;
            [interface_one.slo_lmac.flow_details] = calculate_packets_per_sample(interface_one.slo_lmac.flow_details, interface_one.slo_lmac.flow_details(i).flow, i); %can be 2 packets/sample of 2 packets per 3 samples 
            interface_one.slo_lmac.flow_details(i).x = interface_one.slo_lmac.flow_details(i).x_; %for countdown
            
            interface_one.slo_lmac.active_index_end = interface_one.slo_lmac.active_index_end + 1;
           
        end
        
    end

    while interface_two.slo_umac.active_index_end + 1 <= (interface_two.slo_umac.length) && interface_two.slo_umac.flow_details(interface_two.slo_umac.active_index_end+1).start == sample_no
        
       interface_two.slo_umac.active_index_end = interface_two.slo_umac.active_index_end + 1; 
       slo_flow_arrives_interface_two = true;

    end

    if (slo_flow_arrives_interface_two)  %calculate flow and allocate it to links
        fprintf("slo flow arrived interface two\n");
        n_active_umac_slo_interface_two_flows = interface_two.slo_umac.active_index_end;
        n_active_lmac_slo_interface_two_flows = interface_two.slo_lmac.active_index_end;
        
        for i = n_active_lmac_slo_interface_two_flows + 1 : n_active_umac_slo_interface_two_flows
            
            interface_two.slo_lmac.flow_details(i).flow = interface_two.slo_umac.flow_details(i).flow;
            [interface_two.slo_lmac.flow_details] = calculate_packets_per_sample(interface_two.slo_lmac.flow_details, interface_two.slo_lmac.flow_details(i).flow, i); %can be 2 packets/sample of 2 packets per 3 samples 
            interface_two.slo_lmac.flow_details(i).x = interface_two.slo_lmac.flow_details(i).x_; %for countdown
            interface_two.slo_lmac.active_index_end = interface_two.slo_lmac.active_index_end + 1;
           
        end
        
    end

    %slo and mlo flow stopping is handled in update_umac_and_lmac and
    %update_lmac_queue
    while mlo_umac.active_index_end + 1 <= (mlo_umac.length) && mlo_umac.flow_details(mlo_umac.active_index_end+1).start == sample_no
        mlo_umac.active_index_end = mlo_umac.active_index_end + 1; 
        mlo_flow_arrives = true;
    end

    if mlo_flow_arrives  %calculate flow and allocate it to links

       
        %how many new mlo flow arrived?
        n_active_umac_mlo_flows = mlo_umac.active_index_end;
     
        n_active_lmac_mlo_flows =  interface_two.mlo_lmac.active_index_end;
        fprintf("mlo flow arrived\n");

        for i = n_active_lmac_mlo_flows + 1 : n_active_umac_mlo_flows
           %new mlo flows
           
           interface_one.mlo_lmac.flow_details(i).flow = mlo_umac.flow_details(i).flow; %not sure if this loop req or not
           interface_two.mlo_lmac.active_index_end = interface_two.mlo_lmac.active_index_end +1;
           interface_one.mlo_lmac.active_index_end = interface_one.mlo_lmac.active_index_end +1;

        end

        %calculate channel occupancy
        channel_occupancy = calculate_channel_occupancy(interface_one.primary_channel, interface_two.primary_channel, -1, 2, historical_occupancy_matrix);  
        ap.channel_occupancy = channel_occupancy;
        ap.percentage_available_channel = 1 - ap.channel_occupancy; %experiment parameters. should be in this function
        ap.percentage_available_channel(3) = 0;
       
        %run allocation algo. change name of algo accordingly
        tic;
  
        [ap.soft_threshold, ap.hard_threshold, mlo_load_assign, ap.percentage_available_channel, n_int, app_flow] = calculate_data_rate_for_two_links_SLCI(ap.channel_occupancy, ap.soft_threshold, ap.hard_threshold, round_no, ap.percentage_available_channel, n_int, ap.rate_mcs_latest, mlo_umac);
        time = time + toc;
        
        
        fprintf("load assigned is after algo is \n");
        disp( mlo_load_assign);


        
        for i = 1: mlo_umac.active_index_end 
            
            interface_one.mlo_lmac.flow_details(i).flow = mlo_load_assign(i,1);
            interface_two.mlo_lmac.flow_details(i).flow = mlo_load_assign(i,2);
            %mlo link one flows
            [interface_one.mlo_lmac.flow_details] = calculate_packets_per_sample(interface_one.mlo_lmac.flow_details, interface_one.mlo_lmac.flow_details(i).flow, i); %can be 2 packets/sample of 2 packets per 3 samples 
            %mlo link two flows
            [interface_two.mlo_lmac.flow_details] = calculate_packets_per_sample(interface_two.mlo_lmac.flow_details, interface_two.mlo_lmac.flow_details(i).flow, i); %can be 2 packets/sample of 2 packets per 3 samples 
            
        end

        %if new mlo flows set their x(counter)
        for i = n_active_lmac_mlo_flows + 1 : n_active_umac_mlo_flows
           %new mlo flows
          
           interface_one.mlo_lmac.flow_details(i).x = interface_one.mlo_lmac.flow_details(i).x_;
           interface_two.mlo_lmac.flow_details(i).x = interface_two.mlo_lmac.flow_details(i).x_;

        end

    end


    ap.interface_one = interface_one;
    ap.interface_two = interface_two;
    ap.mlo_umac = mlo_umac;
    
end