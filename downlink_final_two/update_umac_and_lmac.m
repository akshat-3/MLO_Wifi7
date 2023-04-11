function  [ap, sta] = update_umac_and_lmac(ap, sample_no, sta)

    mlo_umac = ap.mlo_umac; %do this for optimisation
    interface_one = ap.interface_one;
    interface_two = ap.interface_two;
   
    %add packets to lmac interface one
    is_interface_one = true;
    %%interface one SLO flows
    [interface_one, sta] = update_slo_umac_and_lmac(interface_one, sta, sample_no, is_interface_one);
    %interface one MLO flow
    [interface_one, sta, mlo_umac] = update_mlo_umac_and_lmac(interface_one, sta, mlo_umac, sample_no, is_interface_one);

    is_interface_one = false;
    %%interface two SLO flows
    [interface_two, sta] = update_slo_umac_and_lmac(interface_two, sta, sample_no, is_interface_one);
    %%interface two MLO flows
    [interface_two, sta, mlo_umac] = update_mlo_umac_and_lmac(interface_two, sta, mlo_umac, sample_no, is_interface_one);

    ap.mlo_umac = mlo_umac;
    ap.interface_one = interface_one;
    ap.interface_two =interface_two;
     

end
               