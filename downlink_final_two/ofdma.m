%Max time at which client received packetfigur

​
figure(1);
Y = [160.55-149.59, 169.50-149.56, 163.65-149.61, 161.776-149.51, 162.552-149.53, 164.29-149.61, 162.43-149.53];
X = categorical({'No-OFDMA', '2xRU-242', '4xRU-106','8xRU-52', '18xRU-26','4xRU-106+2xRU-26','8xRU-52+2xRU-26'}); 
X = reordercats(X,{'No-OFDMA', '2xRU-242', '4xRU-106','8xRU-52', '18xRU-26','4xRU-106+2xRU-26','8xRU-52+2xRU-26'});
bar(X, Y);
xlabel({'Configuration'});
ylabel({'Duration'});
yticks(0:0.5:15);
​