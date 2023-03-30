figure(1);
Y = [39.33, 0, 40.33, 0, 0];
X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
bar(X, Y);
xlabel({'Algorithm', '(Mbps)'});
ylabel({'Total Throughput', '(Mbps)'});
yticks(0:10:100);
title('Multi-link STR Operation');
%legend( 'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA');

figure(2);
Y = [13.45, 0, 14.41, 0, 0; 25.88, 0, 25.91, 0, 0];
X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
bar(X, Y);
xlabel({'Algorithm', '(Mbps)'});
ylabel({'Interface-wise Throughput', '(Mbps)'});
yticks(0:10:100);
legend( 'Interface One', 'Interface Two');
title('Multi-link STR Operation');

figure(3);
Y = [61571487, 0, 60696342, 0, 0; 43472104, 0, 42436811, 0, 0];
X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
bar(X, Y);
xlabel({'Algorithm', '(Mbps)'});
ylabel({'Interface-wise Contention Time', '(Mbps)'});
yticks(0:10000000:80000000);
legend( 'Interface One', 'Interface Two');
title('Multi-link STR Operation');


%interface one carries more SLO devices. (more closer to real life?)
% figure(3);
% Y = [86.17, 0, 0, 0, 0;];
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'Throughput Interface Two', '(Mbps)'});
% yticks(0:10:100);
% title('Multi-link NSTR Operation');


figure(4);
Y = [23.72, 0, 24.56, 0, 0; 44.35, 0, 42.38, 0, 0];
X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
bar(X, Y);
xlabel({'Algorithm', '(Mbps)'});
ylabel({'%Time AP occupies channel ((ap tx time/total time)%) Interface wise', '(Mbps)'});
yticks(0:10:100);
legend( 'Interface One', 'Interface Two');
title('Multi-link STR Operation');

figure(5);
Y = [13.91, 0, 14.85, 0, 0; 26.56, 0, 24.86, 0, 0];
X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
bar(X, Y);
xlabel({'Algorithm', '(Mbps)'});
ylabel({'%Time AP occupies channel ((ap SUCCESS tx time/total time)%) Interface wise', '(Mbps)'});
yticks(0:10:100);
legend( 'Interface One', 'Interface Two');
title('Multi-link STR Operation');


% figure(6);
% Y = [90.51, 0, 0, 0, 0;];
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'%Time AP occupies channel ((ap tx time/total time)%) Interface Two', '(Mbps)'});
% yticks(0:10:100);
% title('Multi-link NSTR Operation');
% 
% figure(7);
% Y = [90.50, 0, 0, 0, 0;];
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'%Time AP occupies channel ((ap tx SUCCESS time/total time)%) Interface Two', '(Mbps)'});
% yticks(0:10:100);
% title('Multi-link NSTR Operation');


% figure(6);
% Y = [14.44, 0, 28.28, 0, 0];
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'Average SLO STAs Throughput', '(Mbps)'});
% yticks(0:10:100);
% title('Multi-link STR Operation');
% 
% figure(7);
% Y = [6.87, 0, 7.07, 0, 0; 7.56, 0, 21.21, 0, 0];
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'Average SLO STAs Interface-wise Throughput', '(Mbps)'});
% yticks(0:10:100);
% title('Multi-link STR Operation');
% 
% figure(8);
% Y = [5.38, 0, 17.83, 0, 0];
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'Average MLO STAs Throughput', '(Mbps)'});
% yticks(0:10:100);
% title('Multi-link STR Operation');
% 
% figure(9);
% Y = [1.72, 0, 0.69, 0, 0; 3.66, 0, 17.13, 0, 0];
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'MLO STAs Interface-wise Throughput', '(Mbps)'});
% yticks(0:10:100);
% legend( 'Interface One', 'Interface Two');
% title('Multi-link STR Operation');




% figure(7);
% Y = [50, 50, 50, 50, 50];%check mrbca
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'(ap tx time to SLO stas/total time)*100', '(Mbps)'});
% yticks(0:10:100);
% title('Multi-link STR Operation');
% 
% figure(8);
% Y = [23.16, 35.15, 23.12, 40.68, 29.78]; %check mrbca
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'(ap tx time to SLO stas success/total time)*100', '(Mbps)'});
% yticks(0:10:100);
% title('Multi-link STR Operation');
% 
% figure(8);
% Y = [50.02, 0, 0, 0, 0];
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'(ap tx time to SLO stas/total time) interface wise', '(Mbps)'});
% yticks(0:10:100);
% legend( 'Interface One', 'Interface Two');
% title('Multi-link NSTR Operation');

% figure(9);
% Y = [49.99, 0, 0, 0, 0];
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'(ap tx time to SLO success stas/total time) interface wise', '(Mbps)'});
% yticks(0:10:100);
% legend( 'Interface One', 'Interface Two');
% title('Multi-link NSTR Operation');



% figure(9);
% Y = [50.02, 61.27, 50, 66.06, 56.22];
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'(ap tx time to MLO stas/total time)*100', '(Mbps)'});
% yticks(0:10:100);
% title('Multi-link STR Operation');
% 
% figure(10);
% Y = [49.99, 51.51, 49.99, 52.09, 50.50];
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'(ap tx time to MLO success stas/total time)*100', '(Mbps)'});
% yticks(0:10:100);
% title('Multi-link STR Operation');

% figure(13);
% Y = [50.02, 0, 0, 0, 0];
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'(ap tx time to MLO stas/total time) interface wise', '(Mbps)'});
% yticks(0:10:100);
% legend( 'Interface One', 'Interface Two');
% title('Multi-link NSTR Operation');
% 
% figure(14);
% Y = [49.99, 0, 0, 0, 0];
% X = categorical({'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'}); 
% X = reordercats(X,{'MRBCA','MLSA Dynamic', 'SLCI', 'MLSA', 'MCAA'});
% bar(X, Y);
% xlabel({'Algorithm', '(Mbps)'});
% ylabel({'(ap tx time to MLO success stas/total time) interface wise', '(Mbps)'});
% yticks(0:10:100);
% legend( 'Interface One', 'Interface Two');
% title('Multi-link NSTR Operation');