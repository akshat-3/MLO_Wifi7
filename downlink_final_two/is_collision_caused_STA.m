function is_collision = is_collision_caused(samples_below_snr, total_samples, max_percent_failed_samples_allowed)
    %check if threshold reached
   fprintf('samples below snr: %d', samples_below_snr)
   fprintf('total samples: %d', total_samples)
   percent_fail = (samples_below_snr/total_samples)*100;
   fprintf('percent fail: %d', percent_fail)
   fprintf('max percent allowed: %d', max_percent_failed_samples_allowed)
   if percent_fail < max_percent_failed_samples_allowed 
       is_collision = false;
   else
       is_collision = true;
   end
end