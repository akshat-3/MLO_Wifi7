function [soft_threshold, hard_threshold, final_load_assign, percentage_available_channel, nint, app_flow] = calculate_data_rate_for_two_links_approach_two(channel_occupancy, soft_threshold, hard_threshold, round_no, percentage_available_channel, nint, rate, app_flow)

   
channel_occupancy = channel_occupancy(1:2);
percentage_available_channel = percentage_available_channel(1:2);
soft_threshold =soft_threshold(1:2);
hard_threshold = hard_threshold(1:2);
rate = rate(1:2);
%rate = [100, 140]; %acc to mcs 
soft_threshold_original = [0.2,0.3]; % experiment parameters. should be in this function WHY ONLY THESE?
hard_threshold_original = [0.7,0.8]; % experiment parametes. should be in this function
n_interfaces = 2;

ff_exceed=0;
ff_less=0;
ff=0;
b=[0.2,0.3,0.5];
ts=[b(1)*(1/aps),b(2)*(1/aps),b(3)*(1/aps)];

bh=[0.6,0.75,0.8];
th=[bh(1)*(1/aps),bh(2)*(1/aps),bh(3)*(1/aps)];

L=10;



fr2=zeros(n,int,rounds);
fra2=zeros(n,int,rounds);
sorted_newocc2 =zeros(n,int,rounds);
assigned2 =zeros(n,int,rounds);
inc2=zeros(n,int,rounds);
newocc2=zeros(n,int,rounds);
ass_final2=zeros(n,int,rounds);
occupancy2=zeros(n,int,rounds);
ff_e2=zeros(n,int,rounds);
ff_l2=zeros(n,int,rounds);
ff_flag2=zeros(n,int,rounds);

global_increase2=0;
global_increase21=0;
no_scope2=0;


   


    L=ffloww(i,rr);
    ffloww2(i,rr)=L;
    flag=0;
    sn=sink;
    cc=0;
    for j=1:1:int
        if(sink(sn).o(j)<ts(j) && mod(rr,4)==0)
            cc=cc+1;
        end
    end
    if(cc>=2 && fffff==0)
        ts=[b(1)*(1/aps),b(2)*(1/aps),b(3)*(1/aps)];
        global_increase2=0;
        global_increase21=0;
        no_scope2=0;
        nint2=int;
        fffff=1;

    end

    A2=sink(sn).o;
    [B2,I2]=sort(A2);
    sorted_newocc2(i,:,rr) = B2;
   
    for j=1:1:int
        df(i,j,rr)=ts(I2(j))-sorted_newocc2(i,j,rr);
        if(no_scope2==1  && I2(j)==3)
            if(sink(sn).o(I2(3))<1)
                df(i,j,rr)=1-sorted_newocc2(i,j,rr);
            else 
                df(i,j,rr)=0;
            end
        end
        if(df(i,j,rr)>=0.01)
            fr2(i,j,rr)=df(i,j,rr)*rate(I2(j));
        else
          fr2(i,j,rr)=0;
        end
    end  
    for j=1:1:int
        fra2(i,j,rr)=fr2(i,j,rr)/sum(fr2(i,:,rr));
        assigned2(i,j,rr)=fra2(i,j,rr)*L; 
        ass_final2(i,I2(j),rr)=assigned2(i,j,rr);
    end   
    for j=1:1:int
        inc2(i,j,rr)=ass_final2(i,j,rr)/rate(j);
        newocc2(i,j,rr)=sink(sn).o(j)+inc2(i,j,rr);
        sink(sn).o(j)=sink(sn).o(j)+inc2(i,j,rr);
        occupancy2(i,j,rr)=sink(sn).o(j);
    end

    ff_exceed=0;
    ff_less=0;
    ff=0;
    for j=1:1:int
        if((sink(sn).o(j)>=ts(j)))
            diff_ts2(j)=sink(sn).o(j)-ts(j);
            ff_exceed=ff_exceed+1;
            ff_e2(i,j,rr)=ff_exceed;
        elseif((ts(j)-sink(sn).o(j))<=0.01)
            ff_less=ff_less+1;
            ff_l2(i,j,rr)=ff_less;
        end
    end  

    if(ff_exceed==3||ff_less==3||ff_exceed+ff_less==3)
        global_increase2=1;
        for j=1:1:int
            x=(th(j)-ts(j))*sink(sn).r(j)/sum(sink(sn).r);
            if(ts(j)+x<=th(j))
                ts(j)=ts(j)+x;
            else
                ts(j)=th(j);
            end
        end
%              global_increase2=0;
    end

    % the occupancy of all the interfaces have reached ts at least once and the
% occ on one or two has again reached ts
    if(global_increase2==1 && ff_less+ff_exceed>0 && ff_less+ff_exceed <=2 )
        for j=1:1:int
            x=(th(j)-ts(j))*sink(sn).r(j)/sum(sink(sn).r);
            if(ts(j)+x<=th(j))
                ts(j)=ts(j)+x;
            else
                ts(j)=th(j);
            end
        end
        global_increase2=0;
%         global_increase2=1;
    end

    for j=1:1:int
        ts_final2(i,j,rr)=ts(j);
        if(ts(j)>=th(j)&&sink(sn).o(j)>=ts(j))
            sink(sn).f(j)=0;
        end
        if((ts(j)-sink(sn).o(j))<=0.01)
            sink(sn).f(j)=0;
        else
            sink(sn).f(j)=1- sink(sn).o(j);
        end
        free2(i,j,rr)=sink(sn).f(j);
    end

    if(sum(free2(i,:,rr))==0)
         for j=1:1:int
                ts(j)=th(j);
             if((ts(j)-sink(sn).o(j))<=0.01)
                sink(sn).f(j)=0;
             else
                sink(sn).f(j)=1- sink(sn).o(j);
             end
             free2(i,j,rr)=sink(sn).f(j);
         end
    end

    if(sum(free2(i,:,rr))==0)
        no_scope2=1;
    end
    


as2=zeros(n,int);
as2(:,:)=ass_final2(:,:,1);
end