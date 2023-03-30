function [arrival_queue, exit_queue] = get_poisson_flow_queue()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    
    %arrival_queue = [1, 420479, 776663, 2192350, 2217340, 5357601, 7440443, 9124919, 9425916, 9515273, 9721500, ...
     %   13876021, 14590024, 14599638, 14885295, 15057324, 15156442, 15188492, 16692319, 18272029];

    arrival_queue = [1, 22492477, 40659830, 46674754, 55522225, 99645586, 100340211, 101967891, 103153131, 118316707, 120167788, ...
      127176640, 130162428, 130503992, 159190997, 159674052, 167568138, 183459761, 184158022, 194838297];

    %sample no 420479 => 4.2seconds
    %sample no 776663 => 7.7seconds
    %sample no 2192350 => 21.92 seconds
    %22.17s, 53.57s
    %sample no 18272029 => 182.72seconds;

    %20 app flows in 2000s (simulation time). 200s = 30.34 minutes
    %let exit time for each app is between 80-150 seconds
    %80 seconds = 8*10^6 samples and 150 seconds = 15*10^6sample

    %app_duration = [31433105, 34795011, 39338619, 17151740, 31194233, 23777844, 36404633, 33229595, 27426873, 34051428, 29349687, ...
     %   30889537, 24208245, 13657691, 21231660, 35552260, 24518444, 26644544, 23071032, 21266737];

    app_duration = [8295774, 14333054, 8916819, 13836103, 13603279, 14425161, 8961126, 11533126, 10834709, 9215005, 12026285, ....
        12243526, 9501120, 11639526, 14924301, 11429406, 12864112, 10879953, 8243437, 9248434];
   
    
    exit_queue = app_duration+arrival_queue;

    exit_queue = sort(exit_queue);
    arrival_queue = transpose(arrival_queue);
    exit_queue = transpose(exit_queue);
end