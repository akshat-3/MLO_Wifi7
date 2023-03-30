function is_collision = is_collision_caused(samples_below_snr, total_samples, max_percent_failed_samples_allowed)
     %check if threshold reached
    percent_fail = (samples_below_snr/total_samples)*100;
    if percent_fail < max_percent_failed_samples_allowed 
        is_collision = false;
    else
        is_collision = true;
    end
end