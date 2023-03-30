function  [count_below_snr] = count_below_snr(primary_channel, bw, power_interference, MCS, distance_in_meter, count_below_snr)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    carrier_frequency = get_carrier_frequency(primary_channel,bw);
    power_tx = 19; %dbm
    power_rx = power_tx - (36.7*log10(distance_in_meter) + 22.7 + 20*log10(carrier_frequency)); %dbM
    snr_threshold = get_snr_threshold(MCS, bw, power_rx);
    snr_dbm = power_rx - power_interference;
    
    %fprintf("power_interference =%d, snr=%d interface two\n", power_interference, snr_dbm);

    if snr_dbm < snr_threshold % && rssi_matrix(s, ap.interface_two.primary_channel) > 0
        %fprintf("sir in dbm is %d and caused collision\n", sir);
        count_below_snr = count_below_snr + 1;
    end
end