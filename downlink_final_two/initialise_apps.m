function [apps] = initialise_apps(n)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    apps = struct();

    for i=1:n
        apps(i).samples_to_wait = -1; %if samples to wait is -1 this implies app is not active
        apps(i).packets_to_add = 0;
        apps(i).x_1 = -1;
    end
end