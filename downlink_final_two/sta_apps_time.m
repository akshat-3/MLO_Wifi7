function [sta_association_start, non_mlo_association_start, mlo_association_start, sta_association_end, ...
    non_mlo_association_end, mlo_association_end, app_start_time, app_end_time, mlo_app_start_time, non_mlo_app_start_time,...
    mlo_app_end_time, non_mlo_app_end_time] = sta_apps_time()

 %sta association start should be more than historical samples required
 %since MLO algos need historical samples.
 

sta_association_start =  [110, 86505, 12673000, 16757000, 21852000, 56508000, 18685000, 26821000, 41762000, 3181000];



 %10 STA- 6 MLO, 4 SLO
 %STA associated from 4-6 minutes
 %stas associated for all time- sta1(slo-2,4gh), sta2(mlo), sta7(slo-5gh), sta8(mlo)

    
sta_association_time = [80000000-110, 80000000-86505, 29906000, 34869000, 26113000, 34436000, 80000000-18685000, 80000000-26821000, 35422000, 27012000];

%association time in minutes : 20.0000   19.9856    6.1592    6.0150    6.4558    6.8902   13.2200   14.2483    6.9917    6.5170


%below doesn't matter if there are still packets to be sent. sta will only
%disassociate when all packets generated are sent.
%can change this behaviour. Confirm with Jagrati/Ma'am
sta_association_end = min(sta_association_start + sta_association_time, 80000000);


app_start_time = [949    10373000    29740000    30215000    54683000    72483000;
    95705    14330000    16773000    25864000    49543000    79667000;
    29569000    30104000    32854000    36985000    37158000    40549000;
    23213000    24047000    28354000    29908000    34748000    40255000;
    27120000    30332000    38186000    38741000    38773000    43666000;
    57581000    58464000    68929000    77841000    78048000    79577000;
    19809000    42479000    45398000    45736000    53562000    74510000;
    31086000    43545000    43826000    52130000    52606000    55655000;
    53477000    54542000    64795000    68256000    69326000    72479000;
    4132000    4735000    5835000    15896000    20321000    23311000];

app_end_time = [80000000    32204000    50225000    53240000    74309000    80000000;
    80000000    37738000    39100000    45016000    70379000    80000000;
    42579000    42579000    42579000    42579000    42579000    42579000;
    44105000    47827000    48597000    50530000    51626000    51626000;
    46962000    47965000    47965000    47965000    47965000    47965000;
    78533000    76534000    80000000    80000000    80000000    80000000;
    80000000    63779000    65029000    65461000    72042000    80000000;
    80000000    66711000    66832000    71903000    75503000    77695000;
    71811000    77070000    77184000    77184000    77184000    77184000;
    22548000    24936000    25868000    30193000    30193000    30193000];
  
   non_mlo_app_start_time = [app_start_time(1,:); app_start_time(3,:); app_start_time(5,:); app_start_time(7,:);];
   mlo_app_start_time = [app_start_time(2,:); app_start_time(4,:); app_start_time(6,:); app_start_time(8,:); app_start_time(9,:); app_start_time(10,:)];
   non_mlo_app_end_time = [app_end_time(1,:); app_end_time(3,:); app_end_time(5,:); app_end_time(7,:);];
   mlo_app_end_time = [app_end_time(2,:); app_end_time(4,:); app_end_time(6,:); app_end_time(8,:);  app_start_time(9,:); app_start_time(10,:)];

   non_mlo_association_start = [sta_association_start(1); sta_association_start(3); sta_association_start(5); sta_association_start(7);];
   mlo_association_start = [sta_association_start(2); sta_association_start(4); sta_association_start(6); sta_association_start(8); sta_association_start(9); sta_association_start(10)];
   non_mlo_association_end = [sta_association_end(1); sta_association_end(3); sta_association_end(5); sta_association_end(7);];
   mlo_association_end = [sta_association_end(2); sta_association_end(4); sta_association_end(6); sta_association_end(8);  sta_association_end(9); sta_association_end(10)];
   
end