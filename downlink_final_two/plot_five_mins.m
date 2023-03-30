figure(1);
Y = [62.04, 62.09, 61.98, 0, 0];
X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
bar(X, Y);
xlabel({'Algorithm', '(Mbps)'});
ylabel({'Total Throughput', '(Mbps)'});
yticks(0:10:100);
title('Multi-link NSTR Operation');
%legend( 'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA');

figure(2);
Y =[34.51, 35.87, 22.86, 0, 0];
X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
bar(X, Y);
xlabel({'Algorithm', '(Mbps)'});
ylabel({'Throughput Interface One', '(Mbps)'});
yticks(0:10:100);
title('Multi-link NSTR Operation');


%interface one carries more SLO devices. (more closer to real life?)
figure(3);
Y = [27.53, 26.22, 39.11, 0, 0;];
X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
bar(X, Y);
xlabel({'Algorithm', '(Mbps)'});
ylabel({'Throughput Interface Two', '(Mbps)'});
yticks(0:10:100);
title('Multi-link NSTR Operation');


figure(4);
Y = [48.04, 50.02, 33.05, 0, 0];
X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
bar(X, Y);
xlabel({'Algorithm', '(Mbps)'});
ylabel({'%Time AP occupies channel ((ap tx time/total time)%) Interface One', '(Mbps)'});
yticks(0:10:100);
title('Multi-link NSTR Operation');


figure(5);
Y = [41.03, 39.18, 52.76, 0, 0;];
X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
bar(X, Y);
xlabel({'Algorithm', '(Mbps)'});
ylabel({'%Time AP occupies channel ((ap tx time/total time)%) Interface Two', '(Mbps)'});
yticks(0:10:100);
title('Multi-link NSTR Operation');


figure(6);
Y = [3.36, 3.58, 3.37, 0, 0];
X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
bar(X, Y);
xlabel({'Algorithm', '(Mbps)'});
ylabel({'%Collisions Interface One', '(Mbps)'});
yticks(0:10:100);
title('Multi-link NSTR Operation');


