function [interface, sta_curr_interface] = update_dropped_packet_stats(interface, sta_curr_interface)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%drop packets since max attempts reached
    interface.n_packet_drop = interface.n_packet_drop + interface.n_agg;
    sta_curr_interface.n_packet_drop = sta_curr_interface.n_packet_drop +  interface.n_agg;
end