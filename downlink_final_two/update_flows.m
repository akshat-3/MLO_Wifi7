function [ap, sta, slo_flow_arrives, slo_flow_stops, mlo_flow_arrives, mlo_flow_stops] = update_flows(ap, s, association_start, association_end, sta, slo_flow_arrives, slo_flow_stops, mlo_flow_arrives, mlo_flow_stops)
%UNTITLED Summary of this function goes here
%   This function tell if a new mlo/slo flow has arrived or not. this info
%  is required since when a new flow arrives mlo algo maybe called
    n_flows = ap.n_apps_per_sta;
    n_sta = ap.n_sta;
    
    for i = 1:n_sta

        %check if sta is associated or not
        if s >= association_start(i) && s <= association_end(i)
            %sta is associated. check for app flow
            if s == association_start(i)
                fprintf("sta %d is associated \n", i);
            end

           
            for j = 1:n_flows  
                %check if the flow arrives
             

                if ap.app_collection(i).flow_arrival(j) == s
                    
                    
                    %flow has arrived
                    
                    %app_collection(i).total_current_flow = app_collection(i).total_current_flow + app_collection(i).apps(j).flow;
                    ap.app_collection(i).apps(j) = update_flow_arrival_status(ap.app_collection(i).apps(j));
                    ap.total_flow = ap.total_flow + ap.app_collection(i).apps(j).flow;

                    if sta(i).is_mlo == true
                        if ap.total_mlo_flow == 0
                            ap.is_MLO_flow_changed_from_zero = true;
                        end
                        fprintf("Flow no %d of station no %d has arrived. Station is MLO capable\n", j, i);
                        mlo_flow_arrives = true;
                        ap.total_mlo_flow = ap.total_mlo_flow + ap.app_collection(i).apps(j).flow;
                    else
                        fprintf("Flow no %d of station no %d has arrived. Station is SLO capable\n", j, i);
                        slo_flow_arrives = true;
                        if sta(i).primary_ch == ap.interface_one.primary_channel
                            ap.total_slo_flow_interface_one = ap.total_slo_flow_interface_one +  ap.app_collection(i).apps(j).flow;
                        else
                            ap.total_slo_flow_interface_two = ap.total_slo_flow_interface_two +  ap.app_collection(i).apps(j).flow;
                        end
                    end
                end

                %check if the flow stops
                if ap.app_collection(i).flow_stop(j) == s
                    %flow has stopped
                  
                    
                    %app_collection(i).total_current_flow = app_collection(i).total_current_flow - app_collection(i).apps(j).flow;
                    ap.app_collection(i).apps(j) = update_flow_stop_status(ap.app_collection(i).apps(j));
                    ap.total_flow = ap.total_flow - ap.app_collection(i).apps(j).flow;

                    if sta(i).is_mlo == true
                        fprintf("Flow no %d of station no %d has stopped. Station is MLO capable\n", j, i);
                        mlo_flow_stops = true;
                        ap.total_mlo_flow = ap.total_mlo_flow - ap.app_collection(i).apps(j).flow;
                    else
                        fprintf("Flow no %d of slo station no %d has stopped. Station is SLO capable\n", j, i);
                        slo_flow_stops = true;
                        if sta(i).primary_ch == ap.interface_one.primary_channel
                            ap.total_slo_flow_interface_one = ap.total_slo_flow_interface_one -  ap.app_collection(i).apps(j).flow;
                        else
                            ap.total_slo_flow_interface_two = ap.total_slo_flow_interface_two -  ap.app_collection(i).apps(j).flow;
                        end
                    end
                    
                end
                         
                %update u_mac queue as required
                %[ap] = update_umac_queue(ap, i, j);
                %[ap, sta] = update_lmac(ap, sta, s);

            end
        end
    end

end