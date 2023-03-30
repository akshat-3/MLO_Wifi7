function  snr_threshold = get_snr_threshold(mcs, bw, power_tx)

    %for mcs 8
    if mcs == 8
        if bw == 20
            snr_threshold = 27; %its 29 according to wireless lan 
        elseif bw == 40
            snr_threshold = 32;
        elseif bw == 80
            snr_threshold = 35;
        else
            snr_threshold = 38;
        end
    end
end