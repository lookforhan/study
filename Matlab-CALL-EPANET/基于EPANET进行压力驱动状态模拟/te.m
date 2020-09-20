% 加载库函数
clc;
clear all;
close all;
linknum=0;    %总连接（包括管段、水泵和阀门）数
nodenum=0;    %总节点（包括用水节点、水库和水池）数
nonnodenum=0; %非用水节点数
Pdes=25; Pmin=0; %节点期望服务水头和最小出水水头
tindex=10;%模拟哪个水力时段

if ~libisloaded('epanet2')
    warning off MATLAB:loadlibrary:TypeNotFound
    warning off MATLAB:loadlibrary:TypeNotFoundForStructure
    loadlibrary('epanet2.dll','epanet2.h');
end

%读取link数和用水节点数
calllib('epanet2','ENopen','Net1.inp','test.rpt','');
[err,linknum]=calllib('epanet2','ENgetcount',2,linknum);
[err,nodenum]=calllib('epanet2','ENgetcount',0,nodenum);
[err,nonnodenum]=calllib('epanet2','ENgetcount',1,nonnodenum);
junctionnum=nodenum-nonnodenum;
calllib('epanet2','ENclose');

Qreq=zeros(junctionnum,1);  %初始化节点需水量矩阵
Qold=zeros(junctionnum,1);
Qnew=zeros(junctionnum,1);
Qavl=zeros(junctionnum,1);  %初始化节点实际用水量矩阵
Pavl=zeros(junctionnum,1);  %初始化节点压力水头矩阵
HL=zeros(junctionnum,1);    %初始化节点标高矩阵
multi=zeros(junctionnum,1); %节点某一时刻需水量乘子矩阵
relativeerr=ones(junctionnum,1);%节点实际需水量与上一次迭代的相对误差矩阵
calllib('epanet2','ENopen','test.inp','test.rpt','');
calllib('epanet2','ENopenH');
calllib('epanet2','ENinitH',0);
time=0;tstep=3600;
while(tstep)
    [err,time]=calllib('epanet2','ENrunH',time);
    if(time/3600==tindex)
        for i=1:junctionnum
            [err,Qreq(i)]=calllib('epanet2','ENgetnodevalue',i,9,Qreq(i));%有问题，只是基本需水量
            [err,Pavl(i)]=calllib('epanet2','ENgetnodevalue',i,11,Pavl(i));
            [err,HL(i)]=calllib('epanet2','ENgetnodevalue',i,0,HL(i));
        end
        Qold=Qreq;
        break;
    end
    [err,tstep]=calllib('epanet2','ENnextH',tstep);
end
calllib('epanet2','ENcloseH');

calllib('epanet2','ENopen','test.inp','test.rpt','');
calllib('epanet2','ENsetlinkvalue',1,4,0);  %设置故障管段状态
err=calllib('epanet2','ENopenH');
err=calllib('epanet2','ENinitH',0);
time=0;tstep=1;
while(tstep)
    [err,time]=calllib('epanet2','ENrunH',time);
    
    if(time/3600==tindex)
        for i=1:junctionnum
            
            [err,Pavl(i)]=calllib('epanet2','ENgetnodevalue',i,11,Pavl(i));
            
            if(Pavl(i)>=Pmin && Pavl(i)<Pdes)
                a(i)=(-4.595*(Pdes+HL(i))-6.907*(Pmin+HL(i)))/(Pdes-Pmin);
                b(i)=11.502/(Pdes-Pmin);
                R(i)=exp(a(i)+b(i)*(Pavl(i)+HL(i)))/(1+exp(a(i)+b(i)*(Pavl(i)+HL(i))));
                Qavl(i)=Qreq(i)*R(i);   %%
            elseif(Pavl(i)>=Pdes)
                Qavl(i)=Qreq(i);
            elseif(Pavl(i)<Pmin)
                Qavl(i)=0;
            end
            
            
        end
        Qnew=(Qavl+Qold)/2;
        
        for i=1:junctionnum
            relativeerr(i,1)=abs(Qnew(i)-Qold(i));
        end
        
        
        while(max(relativeerr)>=0.01)
            
            
            for i=1:junctionnum
                j=0;
                [err,j]=calllib('epanet2','ENgetnodevalue',i,2,j);
                [err,multi(i)]=calllib('epanet2','ENgetpatternvalue',j,tindex+1,multi(i));
                newbaseflow=Qnew(i)/multi(i);%%
                err =calllib('epanet2','ENsetnodevalue',i,1,newbaseflow);
            end
            Qold=Qnew;
            [err,time]=calllib('epanet2','ENrunH',time);
            
            for i=1:junctionnum
                
                [err,Pavl(i)]=calllib('epanet2','ENgetnodevalue',i,11,Pavl(i));
                
                if(Pavl(i)>=Pmin && Pavl(i)<Pdes)
                    a(i)=(-4.595*(Pdes+HL(i))-6.907*(Pmin+HL(i)))/(Pdes-Pmin);
                    b(i)=11.502/(Pdes-Pmin);
                    R(i)=exp(a(i)+b(i)*(Pavl(i)+HL(i)))/(1+exp(a(i)+b(i)*(Pavl(i)+HL(i))));
                    Qavl(i)=Qnew(i)*R(i);
                elseif(Pavl(i)>=Pdes)
                    Qavl(i)=Qnew(i);
                elseif(Pavl(i)<Pmin)
                    Qavl(i)=0;
                end
                
            end
            
            Qnew=(Qavl+Qold)/2;
            
            for i=1:junctionnum
                relativeerr(i,1)=abs(Qnew(i)-Qold(i));
            end
            
            
            
        end
    end
    [err,tstep]=calllib('epanet2','ENnextH',tstep);
end

calllib('epanet2','ENclose');
unloadlibrary('epanet2');





