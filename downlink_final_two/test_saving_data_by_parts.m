arr = zeros(1,1);
j = 1;
n = 1;
for i = 1:50000
    arr(j) = i;
    j = j+1;
    if rem(i, 10000) == 0 
        save(['solution_number',num2str(n),'.mat'],'arr');
        n = n+1;
        j = 1;
    end
end