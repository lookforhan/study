% ���ؿ⺯��
clc;
clear all;
close all;
linknum=0;    %�����ӣ������ܶΡ�ˮ�úͷ��ţ���
nodenum=0;    %�ܽڵ㣨������ˮ�ڵ㡢ˮ���ˮ�أ���
nonnodenum=0; %����ˮ�ڵ���
Pdes=25; Pmin=0; %�ڵ���������ˮͷ����С��ˮˮͷ
tindex=10;%ģ���ĸ�ˮ��ʱ��

if ~libisloaded('epanet2')
    warning off MATLAB:loadlibrary:TypeNotFound
    warning off MATLAB:loadlibrary:TypeNotFoundForStructure
    loadlibrary('epanet2.dll','epanet2.h');
end

%��ȡlink������ˮ�ڵ���
calllib('epanet2','ENopen','Net1.inp','test.rpt','');
[err,linknum]=calllib('epanet2','ENgetcount',2,linknum);
[err,nodenum]=calllib('epanet2','ENgetcount',0,nodenum);
[err,nonnodenum]=calllib('epanet2','ENgetcount',1,nonnodenum);
junctionnum=nodenum-nonnodenum;
calllib('epanet2','ENclose');

Qreq=zeros(junctionnum,1);  %��ʼ���ڵ���ˮ������
Qold=zeros(junctionnum,1);
Qnew=zeros(junctionnum,1);
Qavl=zeros(junctionnum,1);  %��ʼ���ڵ�ʵ����ˮ������
Pavl=zeros(junctionnum,1);  %��ʼ���ڵ�ѹ��ˮͷ����
HL=zeros(junctionnum,1);    %��ʼ���ڵ��߾���
multi=zeros(junctionnum,1); %�ڵ�ĳһʱ����ˮ�����Ӿ���
relativeerr=ones(junctionnum,1);%�ڵ�ʵ����ˮ������һ�ε��������������
calllib('epanet2','ENopen','test.inp','test.rpt','');
calllib('epanet2','ENopenH');
calllib('epanet2','ENinitH',0);
time=0;tstep=3600;
while(tstep)
    [err,time]=calllib('epanet2','ENrunH',time);
    if(time/3600==tindex)
        for i=1:junctionnum
            [err,Qreq(i)]=calllib('epanet2','ENgetnodevalue',i,9,Qreq(i));%�����⣬ֻ�ǻ�����ˮ��
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
calllib('epanet2','ENsetlinkvalue',1,4,0);  %���ù��Ϲܶ�״̬
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





