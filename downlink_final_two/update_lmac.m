function  [ap, slo_flow_arrives_interface_one, slo_flow_arrives_interface_two, slo_flow_stops_interface_one, slo_flow_stops_interface_two, mlo_flow_arrives, mlo_flow_stops] = update_umac_and_lmac(ap, sample_no)



    mlo_flow_arrives = false;
    mlo_flow_stops = false;
    n_apps = ap.n_apps_per_sta;
    slo_flow_arrives_interface_one = false;
    slo_flow_arrives_interface_two = false;
    slo_flow_stops_interface_one = false;
    slo_flow_stops_interface_two = false;
    n_mlo_sta = ap.n_mlo_sta;
    n_slo_sta_interface_one = ap.n_slo_sta_interface_one;
    n_slo_sta_interface_two = ap.n_slo_sta_interface_two;

    mlo_flow_umac = ap.mlo_flow_umac;
    interface_one = ap.interface_one;
    interface_two = ap.interface_two;

    %check if new MLO flow starts
    if mlo_flow_umac.active_index_end == (n_apps * n_mlo_sta)
    elseif mlo_flow_umac.mlo_flow(active_index_end+1).start == sample_no
        mlo_flow_arrives = true;
    end

    %check if new SLO flow starts on interface one 
    if interface_one.slo_flow_umac.active_index_end == (n_apps * n_slo_sta_interface_one)
    elseif interface_one.slo_flow_umac.slo_flow(active_index_end+1).start == sample_no
        slo_flow_arrives_interface_one = true;
    end

    %check if new SLO flow starts on interface two 
    if interface_two.slo_flow_umac.active_index_end == (n_apps * n_slo_sta_interface_two)
    elseif interface_two.slo_flow_umac.slo_flow(active_index_end+1).start == sample_no
        slo_flow_arrives_interface_two = true;
    end

    %check if MLO flow stops
    for i = 1: mlo_flow_umac.active_index_end
        if mlo_flow_umac.mlo_flow(i).stop == sample_no
            mlo_flow_stops = true;
            break;%no need to check others since we just have to update boolean value
        end
    end

    %check if SLO flow stops interface_one
    for i = 1: interface_one.slo_flow_umac.active_index_end
        if interface_one.slo_flow_umac.slo_flow(i).stop == sample_no
            slo_flow_stops_interface_one = true;
            break;%no need to check others since we just have to update boolean value
        end
    end

    %check if SLO flow stops interface_two
    for i = 1: interface_two.slo_flow_umac.active_index_end
        if interface_two.slo_flow_umac.slo_flow(i).stop == sample_no
            slo_flow_stops_interface_two = true;
            break;%no need to check others since we just have to update boolean value
        end
    end


    %add packets to lmac interface one
    %%interface one SLO flows
    for i = 1: interface_one.slo_flow_umac.active_index_end
        if interface_one.lmac_slo_flow(i).x == 0
           interface_one.lmac_slo_flow(i).x = interface_one.lmac_slo_flow(i).x_; 

           [interface_one.slo_flow_umac(i), interface_one, interface_one.lmac_slo_flow(i)] = ...
                update_lmac_queue(interface_one.slo_flow_umac(i), interface_one, interface_one.lmac_slo_flow(i));
        else
           interface_one.lmac_slo_flow(i).x = interface_one.lmac_slo_flow(i).x - 1;
        end
    end


    %%interface one MLO flows
    for i = 1: mlo_flow_umac.active_index_end
        if interface_one.lmac_mlo_flow(i).x == 0
           interface_one.lmac_mlo_flow(i).x = interface_one.lmac_mlo_flow(i).x_; 
           
           [mlo_flow_umac(i), interface_one, interface_one.lmac_mlo_flow(i)] = ...
                update_lmac_queue(mlo_flow_umac(i), interface_one, interface_one.lmac_mlo_flow(i));
           
        else
           interface_one.lmac_mlo_flow(i).x = interface_one.lmac_mlo_flow(i).x - 1;
        end
    end

    %add packets to lmac interface two
    %%interface two SLO flows
    for i = 1: interface_two.slo_flow_umac.active_index_end
        if interface_two.lmac_slo_flow(i).x == 0
           interface_two.lmac_slo_flow(i).x = interface_two.lmac_slo_flow(i).x_; 
           
           [interface_two.slo_flow_umac(i), interface_two, interface_two.lmac_slo_flow(i)] = ...
                update_lmac_queue(interface_two.slo_flow_umac(i), interface_two, interface_two.lmac_slo_flow(i));

        else
           interface_two.lmac_slo_flow(i).x = interface_two.lmac_slo_flow(i).x - 1;
        end
    end


    %%interface two MLO flows
    for i = 1: mlo_flow_umac.active_index_end
        if interface_two.lmac_mlo_flow(i).x == 0
           interface_two.lmac_mlo_flow(i).x = interface_two.lmac_mlo_flow(i).x_; 
           
           [mlo_flow_umac(i), interface_two, interface_two.lmac_mlo_flow(i)] = ...
                update_lmac_queue(mlo_flow_umac(i), interface_two, interface_two.lmac_mlo_flow(i));
           
        else
           interface_two.lmac_mlo_flow(i).x = interface_two.lmac_mlo_flow(i).x - 1;
        end
    end
    
    ap.mlo_flow_umac = mlo_flow_umac;
    ap.interface_one = interface_one;
    ap.interface_two =interface_two;
    

end
               