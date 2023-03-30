function [r,r_leg,T_OFDM,T_OFDM_leg,T_PHY_leg,T_PHY_HE_SU] = ieee11axPHYParams(BW,MCS,n_spatial_stream,rate_of_link)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    T_OFDM = 16*1e-6; %fixing it
    T_OFDM_leg = 4*1e-6; %fixing it
    T_PHY_leg = 20*1e-6; %fixing it
    T_PHY_HE_SU = 52*1e-6; %fixing it
    r = -1;
    r_leg = -1;

    %r_legacy=> 802.11ac

    mcs_index = MCS;
    
    gaurd_interval = 1.6*1e-6;
    %FOR NOW 
    if BW == 20
        r = 97.5;
    elseif BW == 40
        r = 195.5;
    elseif BW == 80
        r = 408.3;
    elseif BW == 160
        r = 816.7;
    end
    
    r_leg = 48;
    
end