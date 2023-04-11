temp = struct();
temp(1).a = 1;
temp(1).b = 2;
temp(2).a = 5;
temp(2).b = 9;
writetable(struct2table(temp), 'Structure_Example.csv')

 temp(3).a = 11;
temp(3).b = 11;

filename = 'abc.csv';
fid = fopen(filename, 'a');
table = readtable(filename, 'ReadVariableNames', false);
numRows = height(table);
temp(numRows+1).a = 1;
temp(numRows+1).b = 1;
 
fprintf(fid, '%d,%d\n', 90, 99);
fclose(fid);
delete table;

% isempty(temp(2).b)