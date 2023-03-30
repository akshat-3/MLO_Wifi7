function [occupancy_matrix, rssi_matrix] = get_occupancy_matrix(peak_threshold, num_iterations, num_rssi_samples_per_iter, NUM_RFs)
%num_iterations: total no of diff files to be loaded
%num_rssi_samples:each iteration contains 10000 samples

num_col = num_iterations * num_rssi_samples_per_iter;
rssi_matrix = zeros(num_col,NUM_RFs);
occupancy_matrix = zeros(num_col,NUM_RFs);   % Whole occupancy samples of each RF (boolean)

for j = 1 : num_iterations

    raw_file= load( append(strcat('..\FCB_11\it1 (', num2str(j), ')')) );
        
    b = struct2cell(raw_file);
    
    for i=1:NUM_RFs
        c = cell2mat(b(i));
        rssi_matrix(j*num_rssi_samples_per_iter - num_rssi_samples_per_iter + 1:j*num_rssi_samples_per_iter,i)...
            = c (1:num_rssi_samples_per_iter); %use another function for this

        occupancy_matrix(j*num_rssi_samples_per_iter - num_rssi_samples_per_iter + 1:j*num_rssi_samples_per_iter,i)...
            = logical(rssi_matrix(j*num_rssi_samples_per_iter - num_rssi_samples_per_iter + 1:j*num_rssi_samples_per_iter,i)...
            >peak_threshold);
    end


end


end