clc
clear
n=10;
xm=100;
ym=100;

flow=10;
rounds=6;

aps=1;
int=3;
%occ=[0.06,0.1,0.1];
occ=[0.1,0.2,0.1];

b=[0.2,0.3,0.5];
%0.067, 0.1, 0.167
ts=[b(1)*(1/aps),b(2)*(1/aps),b(3)*(1/aps)];

bh=[0.6,0.75,0.8];
%0.2, 0.25, 0.267
th=[bh(1)*(1/aps),bh(2)*(1/aps),bh(3)*(1/aps)];

for i=1:1:aps
    if (aps==1)
        sink(i).x=0.5*xm;
        sink(i).y=0.5*ym;
    else
        sink(i).x=rand(1,1)*xm;
        sink(i).y=rand(1,1)*ym;
    end
    
    sink(i).c=[2.4,5,6];
    sink(i).r=[200,400,800];
    sink(i).o=occ;
    sink(i).f=[0,0,0];
    sink(i).f(1)=1-sink(i).o(1);
    sink(i).f(2)=1-sink(i).o(2);
    sink(i).f(3)=1-sink(i).o(3);
end
% sink.x=0;
% sink.y=0;



%Transmission Range
%R=30;
% R=35;
S=30;

for i=1:1:n
    node(i).xd=rand(1,1)*xm;
    node(i).yd=rand(1,1)*ym;

    for j=1:1:aps
        d(j)=sqrt((node(i).xd-sink(j).x)^2+(node(i).yd-sink(j).y)^2);
    end
    [r,pos]=find(d==min(min(d)));
    node(i).sink=pos;
    node(i).L=flow;

    XR(i)=node(i).xd-sink(pos).x;
    YR(i)=node(i).yd-sink(pos).y;
    node(i).d=sqrt(XR(i)^2+(YR(i)^2));    

    node(i).slice=ceil(node(i).d/S);
    sn=node(i).sink;
    for c=1:1:int 
        if(node(i).slice==1)
            node(i).rate(c)=sink(sn).r(c);
        elseif(node(i).slice==2)
            node(i).rate(c)=sink(sn).r(c)-80*c;
        elseif(node(i).slice==3)
            node(i).rate(c)=sink(sn).r(c)-120*c;
        else
            node(i).rate(c)=sink(sn).r(c)-160*c;
        end
    end
    
    node(i).rec=0;

    plot(node(i).xd,node(i).yd,'b.');
    hold on;
end

% node(n+1).xd=sink.x;
% node(n+1).yd=sink.y;
% plot(node(n+1).xd,node(n+1).yd,'kd');
for i=1:1:aps
    plot(sink(i).x,sink(i).y,'rd','MarkerSize',12);
    hold on;
end


% for x=1:1:xm
%     for y=1:1:ym
%          dis=sqrt((x-sink(1).x)^2+(y-sink(1).y)^2);
%         if (mod(dis,S)<1)
%            plot(x,y,'kx');
%            hold on;
%         end
%       
%     end
% end

 for i=1:1:n
     if node(i).slice==1
        plot(node(i).xd,node(i).yd,'b.','MarkerSize',12);
        hold on;
     elseif node(i).slice==2
         plot(node(i).xd,node(i).yd,'g.','MarkerSize',12);
         hold on;
     elseif node(i).slice==3
         plot(node(i).xd,node(i).yd,'r.','MarkerSize',12);
         hold on;
     else
         plot(node(i).xd,node(i).yd,'k.','MarkerSize',12);
         hold on;
     end
  end

% for i=1:1:n
%     for j=1:1:n
% %         lr(i,j)=rand(1,1);
%      lr(i,j)=1;
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      Approach 1       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fr=zeros(n,int,rounds);
fra=zeros(n,int,rounds);
ten=zeros(n,int,rounds);
inc=zeros(n,int,rounds);
newocc=zeros(n,int,rounds);
sorted_newocc =zeros(n,int,rounds);
final_occ =zeros(n,int,rounds);
fr_new =zeros(n,int,rounds);
fra_new =zeros(n,int,rounds);
assigned =zeros(n,int,rounds);
inc_new=zeros(n,int,rounds);
ass_final=zeros(n,int,rounds);
II=zeros(n,int,rounds);
occupancy=zeros(n,int,rounds);
ff_e=zeros(n,int,rounds);
ff_l=zeros(n,int,rounds);
ff_flag=zeros(n,int,rounds);

global_increase=0;
global_increase1=0;
no_scope=0;

for rr=1:1:rounds
    if(mod(rr,4)==0)
        %occ=[0.06,0.1,0.1];
        occ=[0.1,0.2,0.1];
        sink(:).o=occ;
        fffff=0;
    end

    for i=1:1:n
        node(i).L=(50-10).*rand(1,1) + 10;
        ffloww(i,rr)=node(i).L;
        flag=0;
        sn=node(i).sink;

        cc=0;
        for j=1:1:int
            if(sink(sn).o(j)<ts(j) && mod(rr,4)==0)
                cc=cc+1;
            end
        end
        if(cc>=2 && fffff==0)
            ts=[b(1)*(1/aps),b(2)*(1/aps),b(3)*(1/aps)];
            global_increase=0;
            global_increase1=0;
            no_scope=0;
            for j=1:1:int
                if(sink(sn).o(j)<ts(j))
                    sink(sn).f(j)=1- sink(sn).o(j);
                else
                    sink(sn).f(j)=0;
                end
            end
             fffff=1;
        end

        
        for j=1:1:int
            if(sink(sn).o(j)>=ts(j))
                sink(sn).f(j)=0;
            end
            fr(i,j,rr)=sink(sn).f(j)*node(i).rate(j);
           
        end  

        for j=3:1:3
            if(no_scope==1)
                if(sink(sn).o(j)<1)
                sink(sn).f(j)=1- sink(sn).o(j);
                else
                    sink(sn).f(j)=0;
                end
                fr(i,j,rr)=sink(sn).f(j)*node(i).rate(j);
            end
        end


         for j=1:1:int
            fra(i,j,rr)=fr(i,j,rr)/sum(fr(i,:,rr));
            ten(i,j,rr)=fra(i,j,rr)*node(i).L;
            inc(i,j,rr)=ten(i,j,rr)/node(i).rate(j);
            newocc(i,j,rr)=sink(sn).o(j)+inc(i,j,rr);
            if(newocc(i,j,rr)>ts(j))
                flag=1;
                ff_flag(i,j,rr)=1;
               
            end
        end   
        A=newocc(i,:,rr);
        D=ts-A;
        if(flag==1)
            [B,Id]=sort(D);
            for j=1:1:int
                sorted_newocc(i,j,rr) = A(Id(j));
                I(j)=Id(j);
            end
    %         sorted_newocc(i,:) = B;
            II(i,:,rr)=I;
          
            %adjust tau i
            for j=1:1:int
                if(sorted_newocc(i,j,rr)>ts(I(j))&&sink(sn).o(I(j))<=ts(I(j)))
                    if ((sorted_newocc(i,int-j+1,rr)+(sorted_newocc(i,j,rr)-ts(I(j)))) <ts(I(int-j+1)))
                        sorted_newocc(i,int-j+1,rr)=sorted_newocc(i,int-j+1,rr)+((sorted_newocc(i,j,rr)-ts(I(j))));
                        sorted_newocc(i,j,rr)=sorted_newocc(i,j,rr)-((sorted_newocc(i,j,rr)-ts(I(j))));
                    else
                        if(sorted_newocc(i,int-j+1,rr)>ts(I(int-j+1)))
            %                 extra=sorted_newocc(j)-ts(j);
                            s=ts(I(int-j+1))-sorted_newocc(i,int-j+1,rr);
                            sorted_newocc(i,int-j+1,rr)=sorted_newocc(i,int-j+1,rr)+s;
                            sorted_newocc(i,j,rr)=sorted_newocc(i,j,rr)-s;
                        end
                    end
                    if(sorted_newocc(i,j,rr)>ts(I(j))&&sink(sn).o(I(j))<=ts(I(j)))
                        if ((sorted_newocc(i,int-j,rr)+(sorted_newocc(i,j,rr)-ts(I(j)))) <ts(I(int-j)))
                            sorted_newocc(i,int-j,rr)=sorted_newocc(i,int-j,rr)+(sorted_newocc(i,j,rr)-ts(I(j)));
                            sorted_newocc(i,j,rr)=sorted_newocc(i,j,rr)-(sorted_newocc(i,j,rr)-ts(I(j)));
                        else
                            if(sorted_newocc(i,int-j,rr)>ts(I(int-j)))
            %                   extra=sorted_newocc(j)-ts(j);
                                s=ts(I(int-j))-sorted_newocc(i,int-j,rr);
                                sorted_newocc(i,int-j,rr)=sorted_newocc(i,int-j,rr)+s;
                                sorted_newocc(i,j,rr)=sorted_newocc(i,j,rr)-s;
                            end
                        end
                    end
                else
                    break;
                end
            
            end
            for j=1:1:int
                if(sorted_newocc(i,j,rr)>sink(sn).o(I(j)))
                    final_occ(i,j,rr)=sorted_newocc(i,j,rr)-sink(sn).o(I(j));
                else
                    final_occ(i,j,rr)=0;
                end
                fr_new(i,j,rr)=final_occ(i,j,rr)*node(i).rate(I(j));
            end
            for j=1:1:int
                fra_new(i,j,rr)=fr_new(i,j,rr)/sum(fr_new(i,:,rr));
                assigned(i,j,rr)=fra_new(i,j,rr)*node(i).L;
                ass_final(i,I(j),rr)=assigned(i,j,rr);
            end
            
        else
            for j=1:1:int
                assigned(i,j,rr)=ten(i,j,rr);
                ass_final(i,j,rr)=assigned(i,j,rr);
            end
        end
        for j=1:1:int
            inc_new(i,j,rr)=ass_final(i,j,rr)/node(i).rate(j);
            sink(sn).o(j)=sink(sn).o(j)+inc_new(i,j,rr);
            occupancy(i,j,rr)=sink(sn).o(j);
        end
    
    %  if(aps==1)   
        ff_exceed=0;
        ff_less=0;
        ff=0;
        for j=1:1:int
            if((sink(sn).o(j)>=ts(j)))
                diff_ts(j)=sink(sn).o(j)-ts(j);
                ff_exceed=ff_exceed+1;
                ff_e(i,j,rr)=ff_exceed;
            elseif((ts(j)-sink(sn).o(j))<=0.01)
                ff_less=ff_less+1;
                ff_l(i,j,rr)=ff_less;
            end
        end  
    
        if(ff_exceed==3||ff_less==3||ff_exceed+ff_less==3)
            global_increase=1;
            for j=1:1:int
                x=(th(j)-ts(j))*sink(sn).r(j)/sum(sink(sn).r);
                if(ts(j)+x<=th(j))
                    ts(j)=ts(j)+x;
                else
                    ts(j)=th(j);
                end
            end
%               global_increase=0;
        end
    
        % the occupancy of all the interfaces have reached ts at least once and the
    % occ on one or two has again reached ts
        if(global_increase==1 && ff_less+ff_exceed>0 && ff_less+ff_exceed <=2 )
            for j=1:1:int
                x=(th(j)-ts(j))*sink(sn).r(j)/sum(sink(sn).r);
                if(ts(j)+x<=th(j))
                    ts(j)=ts(j)+x;
                else
                    ts(j)=th(j);
                end
            end
            global_increase=0;
    %         global_increase2=1;
        end
    
        for j=1:1:int
            ts_final(i,j,rr)=ts(j);
            if(ts(j)>=th(j)&&sink(sn).o(j)>=ts(j))
                sink(sn).f(j)=0;
            end
            if((ts(j)-sink(sn).o(j))<=0.01)
                sink(sn).f(j)=0;
            else
                sink(sn).f(j)=1- sink(sn).o(j);
            end
            free(i,j,rr)=sink(sn).f(j);
        end
    
        if(sum(free(i,:,rr))==0)
             for j=1:1:int
                    ts(j)=th(j);
                 if((ts(j)-sink(sn).o(j))<=0.01)
                    sink(sn).f(j)=0;
                 else
                    sink(sn).f(j)=1- sink(sn).o(j);
                 end
                 free(i,j,rr)=sink(sn).f(j);
             end
        end

        if(sum(free(i,:,rr))==0)
            no_scope=1;
        end
    
    %  end
    
        %check if flow cannot be assigned 
        %check for flow times
    
    end
end
as=zeros(n,int);
as(:,:)=ass_final(:,:,1);


%packet loss
%throughput
%latency
%deciding interfaces
%deciding band

%multiple flows at each client


% exhaustive search

%for multiple APs
%     link capacity perspective
%         hard partition
%         soft partition
%         cap on what max an ap can get

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     Approach 2     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b=[0.2,0.3,0.5];
ts=[b(1)*(1/aps),b(2)*(1/aps),b(3)*(1/aps)];

bh=[0.6,0.75,0.8];
th=[bh(1)*(1/aps),bh(2)*(1/aps),bh(3)*(1/aps)];

L=10;

for i=1:1:aps   
    sink(i).c=[2.4,5,6];
    sink(i).r=[200,400,800];
    sink(i).o=occ;
    sink(i).f=[0,0,0];
    sink(i).f(1)=1-sink(i).o(1);
    sink(i).f(2)=1-sink(i).o(2);
    sink(i).f(3)=1-sink(i).o(3);
end

for i=1:1:n
    
    node(i).rec=0;

end

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

for rr=1:1:rounds
    if(mod(rr,4)==0)
        %occ=[0.06,0.1,0.1];
        occ=[0.1,0.2,0.1];
        sink(:).o=occ;
        fffff=0;
    end

    for i=1:1:n
        node(i).L=ffloww(i,rr);
        ffloww2(i,rr)=node(i).L;
        flag=0;
        sn=node(i).sink;
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

%             for j=1:1:int
%                 if(sink(sn).o(j)<ts(j))
%                     sink(sn).f(j)=1- sink(sn).o(j);
%                 else
%                     sink(sn).f(j)=0;
%                 end
%             end
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
                fr2(i,j,rr)=df(i,j,rr)*node(i).rate(I2(j));
            else
              fr2(i,j,rr)=0;
            end
        end  
        for j=1:1:int
            fra2(i,j,rr)=fr2(i,j,rr)/sum(fr2(i,:,rr));
            assigned2(i,j,rr)=fra2(i,j,rr)*node(i).L; 
            ass_final2(i,I2(j),rr)=assigned2(i,j,rr);
        end   
        for j=1:1:int
            inc2(i,j,rr)=ass_final2(i,j,rr)/node(i).rate(j);
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
        
    end
end
as2=zeros(n,int);
as2(:,:)=ass_final2(:,:,1);