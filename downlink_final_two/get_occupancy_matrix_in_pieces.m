function [occupancy_matrix, rssi_matrix] = get_occupancy_matrix_in_pieces(peak_threshold, num_rssi_samples_per_iter, NUM_RFs, iteration_no, occupancy_matrix, rssi_matrix)
%num_iterations: total no of diff files to be loaded
%num_rssi_samples:each iteration contains 10000 samples

%num_col = num_iterations * num_rssi_samples_per_iter;
%rssi_matrix = zeros(num_col,NUM_RFs);
%occupancy_matrix = zeros(num_col,NUM_RFs);   % Whole occupancy samples of each RF (boolean)




offset = 199; %dataset will start from it num 200 
iteration_no = iteration_no + offset;

raw_file= load( append(strcat('../../FCB_11/it1 (', num2str(iteration_no), ')')) );
    
b = struct2cell(raw_file);

for i=1:NUM_RFs
    c = cell2mat(b(i));
    rssi_matrix(:,i)...
        = c (1:num_rssi_samples_per_iter); %use another function for this

    occupancy_matrix(:,i)...
        = logical(rssi_matrix(:,i)...
        >peak_threshold);
end





end