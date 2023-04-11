function [soft_threshold, hard_threshold, nint, final_load_assign] = calculate_data_rate_for_two_links(channel_occupancy, soft_threshold, hard_threshold, nint, rate, mlo_umac)
   
    channel_occupancy_in_function = channel_occupancy(1:2);
    percentage_available_channel = percentage_available_channel(1:2);
    rate = rate(1:2);

    total_active_flows = mlo_umac.active_index_end;
    final_load_assign = zeros(total_active_flows, 2);
    soft_threshold =soft_threshold(1:2);
    hard_threshold = hard_threshold(1:2);

    %rate = [100, 140]; %acc to mcs 
    soft_threshold_original = [0.4,0.5]; % experiment parameters. should be in this function WHY ONLY THESE?
    hard_threshold_original = [0.7,0.85]; % experiment parametes. should be in this function
    n_interfaces = 2;

    
    for i=1:total_active_flows
    
    
        %flow = (50-10).*rand(1,1) + 10; % generating random flow to be assigned in each round
        app_flow = mlo_umac.flow_details(i).flow; %check
       
        fr = [0, 0];%temporary parameter
        fra=[0, 0];%temporary parameter
        tentative_load_assign=[0, 0];
        increase_ch_occ_on_tentative_load_assign=[0, 0];
        new_ch_occ_on_tentative_load_assign=[0, 0];
        sorted_newocc =[0, 0];
        final_occ =[0, 0];
        fr_new =[0, 0];
        fra_new =[0, 0];
        assigned =[0, 0];
        inc_new=[0, 0];
        ff_e=[0, 0];
        less_room_for_assign=[0, 0];
        is_ch_occ_on_tentative_load_assign_greater_than_soft_th=[0, 0];
        
        count_occupancy_less_than_soft_th = 0;
        percentage_available_channel(1:2) = 1-channel_occupancy_in_function(1:2);
        
        if (channel_occupancy_in_function(1) > hard_threshold(1)) && (channel_occupancy_in_function(2)>hard_threshold(2))
            final_load_assign(i,2) = 0;
            final_load_assign(i,1) = 0;
            continue;
        end
    
        ff_exceed=0;
        ff_less=0;
    
        for j=1:n_interfaces       % for reinitializing the soft threshold if occupancy is less than threshold for any 1 interfaces
            if(channel_occupancy(j) < soft_threshold_original(j))
                count_occupancy_less_than_soft_th = count_occupancy_less_than_soft_th + 1;
                soft_threshold(j) = soft_threshold_original(j); % DIFFERENT FROM JAGRATI'S ALGO
                %SHOULD WE DECREASE OMLY ONE OR BOTH? TRY BOTH OPTIONS AND
                %CHECK RESULTS
                nint = 2;
            end
        end
    
      
        for j=1:n_interfaces
            if (channel_occupancy_in_function(j) < soft_threshold(j))
                percentage_available_channel(j) = 1-channel_occupancy_in_function(j);
            else
                percentage_available_channel(j) = 0;
            end
        end
    
    
    
        for j=1:n_interfaces
            if( channel_occupancy_in_function(j) >= soft_threshold(j))
                percentage_available_channel(j) = 0;
            end
            fr(j)= percentage_available_channel(j) * rate(j); % percentage of free space*rate
           %fr: parameter gto calculate what rate will allocated to each
           %interface
        end  
        
        flag = 0;
        for j=1:n_interfaces
            fra(j) = fr(j) / sum(fr(:)); % normalizing
            tentative_load_assign(j) = fra(j) * app_flow; % load that could be assigned tentatively
            increase_ch_occ_on_tentative_load_assign(j) = tentative_load_assign(j) / rate(j); % increase in channel occupancy on assigning the tentative load
            new_ch_occ_on_tentative_load_assign(j) = channel_occupancy_in_function(j) + increase_ch_occ_on_tentative_load_assign(j); % new occupancy
            if( new_ch_occ_on_tentative_load_assign(j) > soft_threshold(j) )  % checking if occupancy exceeds threshold
                flag=1;
                is_ch_occ_on_tentative_load_assign_greater_than_soft_th(j)=1;
            end
        end 
        
        A=new_ch_occ_on_tentative_load_assign(:);
        D=soft_threshold - A; % difference of soft threshold and new occupancy after assigning tentative load
        
        if( flag==1 ) % if occupancy exceeds threshold
            [B,index_after_sorting]=sort(D); % sorting interfaces
            for j=1:n_interfaces
                sorted_newocc(j) = A(index_after_sorting(j));
                I(j)=index_after_sorting(j);
            end
            %sorted_newocc(i,:) = B;
            II=I;
                  
            %adjust tau i
            for j=1:n_interfaces       % adjyusting the increase in occupancy
        
                if( sorted_newocc(j) > soft_threshold(I(j)) && channel_occupancy_in_function(I(j)) <= soft_threshold(I(j)) )
                    if ((sorted_newocc(n_interfaces-j+1) + (sorted_newocc(j) - soft_threshold(I(j)))) < soft_threshold(I(n_interfaces-j+1)))
                        sorted_newocc( n_interfaces-j+1) = sorted_newocc(n_interfaces-j+1) + ((sorted_newocc(j) - soft_threshold(I(j))));
                        sorted_newocc(j) = sorted_newocc(j) - ((sorted_newocc(j) - soft_threshold(I(j))));
                    else
                        if(sorted_newocc(n_interfaces-j+1) > soft_threshold(I(n_interfaces-j+1)))
            %                 extra=sorted_newocc(j)-ts(j);
                            s = soft_threshold(I(n_interfaces-j+1)) - sorted_newocc(n_interfaces-j+1);
                            sorted_newocc(n_interfaces-j+1) = sorted_newocc(n_interfaces-j+1) + s;
                            sorted_newocc(j) = sorted_newocc(j) - s;
                        end
                    end
    
                else
                    break;
                end
            
            end
        
            for j=1:n_interfaces
        
                if(sorted_newocc(j) > channel_occupancy_in_function(I(j)))
                    final_occ(j) = sorted_newocc(j) - channel_occupancy_in_function(I(j));  % final fraction of load assignment
                else
                    final_occ(j) = 0;
                end
                fr_new(j) = final_occ(j) * rate(I(j));
        
            end
        
            for j=1:n_interfaces
                fra_new(j) = fr_new(j) / sum(fr_new(:)); % final load assignment
                assigned(j) = fra_new(j) * app_flow;
                final_load_assign(i,I(j)) = assigned(j);
            end
                    
        else
        
            for j=1:n_interfaces
                assigned(j) = tentative_load_assign(j); % final load assignment
                final_load_assign(i,j) = assigned(j);
            end
        
        end
    
        %LOAD ASSIGNMENT IS DONE
    
        %MADE A CHANGE HERE
        for j=1:n_interfaces
           
    
            if isnan(final_load_assign(i,j))
               final_load_assign(i,j) = 0;
            end
          inc_new(j) = final_load_assign(i,j) / rate(j); % increase in channel occupancy
          channel_occupancy_in_function(j) = channel_occupancy_in_function(j) + inc_new(j);
           
        end %DOUBT: do we need to do this? as we have channel occupancy info already.
    
        %fprintf("channel occ is after");
        %disp(channel_occupancy);
       
            
         %  if(aps==1)   
        for j=1:n_interfaces
        
            if channel_occupancy_in_function(j) >= soft_threshold(j)  % checking if after assigning load, occupancy exceeds soft threshold
                diff_ts(j) = channel_occupancy_in_function(j) - soft_threshold(j);
                ff_exceed = ff_exceed+1;
                ff_e(j) = ff_exceed;
                %fprintf("exceeded interface is %d \n ", j);
            elseif (soft_threshold(j) - channel_occupancy_in_function(j))<=0.001 % checking if very less room for assignment
                ff_less = ff_less+1;
                less_room_for_assign(j) = ff_less;
                %fprintf("less interface is %d \n ", j);
            end
        
        end  
            
        if((ff_exceed==2||ff_less==2||ff_exceed+ff_less==2) && nint>0) % if the occupancy on all interfaces have reached soft threshold
            global_increase = 1;
            soft_threshold(nint) = hard_threshold(nint);  % increasing the soft threshold to hard threshold. IS THIS CORRECT?
            nint = nint - 1;
            
        end
    
    end
end