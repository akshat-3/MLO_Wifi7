function [ap] = compute_final_ap_stats(ap, num_samples)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
 T_SAMPLE = 10*1E-6;
 
 ap.interface_one.percent_air_time = (ap.interface_one.num_samples_in_tx/num_samples)*100;
 ap.interface_one.percent_success_air_time = (ap.interface_one.num_samples_in_tx_success/num_samples)*100;
 ap.interface_two.percent_air_time = (ap.interface_two.num_samples_in_tx/num_samples)*100;
 ap.interface_two.percent_success_air_time = (ap.interface_two.num_samples_in_tx_success/num_samples)*100;
 ap.n_packet_drop = ap.interface_one.n_packet_drop + ap.interface_two.n_packet_drop;
 
end