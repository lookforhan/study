clc;
clear all;
close all;
% load epanet2
if ~libisloaded('epanet2')
warning off MATLAB:loadlibrary:TypeNotFound 
warning off MATLAB:loadlibrary:TypeNotFoundForStructure 
  loadlibrary('E:\MATLAB\epanet2','e:\MATLAB\epanet2.h');
end

pressure_new=[];
P_impactmatrix=[];
basedemand_new=[];

errcode=calllib('epanet2','ENopen','E:\MATLAB\Net1.inp','Net_rpt','');
 % total number of junction 
nodenum=0;
[errcode,nodenum]=calllib('epanet2','ENgetcount',0,nodenum);

% number of tank
tanknum=0;
[errcode,tanknum]=calllib('epanet2','ENgetcount',1,tanknum);

% number of juction
junctionnum=nodenum-tanknum;
 
% Open hydraulic analysis system
errocode=calllib('epanet2','ENopenH');
% initialisatie, and '0' not Storing binary
errocode=calllib('epanet2','ENinitH',0);
time=0;

% hydraulic step
number=0;
pressure=0;
tstep=1;
 while(tstep&&~errcode)
 % carry out time hydralic 
[errcode,time]=calllib('epanet2','ENrunH',time);
number=time/3600;
if(number==11)
for i=1:junctionnum
    
% get eleventh step pressure value
[errcode,pressure]=calllib('epanet2','ENgetnodevalue',i,11,pressure);
pressurevalue(i,1)=pressure;
end
end

[errcode,tstep]=calllib('epanet2','ENnextH',tstep);
 end
 
 % close hydralic analysis system
errcode=calllib('epanet2','ENcloseH');
pressurevalue;






basedemand=0;
pressurenew=0;
tstep=1;
time=0;
number=0;
for i=1:junctionnum
errcode=calllib('epanet2','ENopenH');
errcode=calllib('epanet2','EninitH',0);
[errcode,basedemand]=calllib('epanet2','ENgetnodevalue',i,1,basedemand);
basedemand_new(i,1)=basedemand*(1+0.3);
errcode=calllib('epanet2','ENsetnodevalue',i,i,basedemand_new(i,1));
which(tstep&&~errcode)
[errcode,time]=calllib('epanet2',ENrunH',time);
number=time/3600;
if(number==11)
for j=1:junctionnum
[errcode,pressurenew]=calllib('epanet2','ENgetnodevalue',j,11,pressurenew);
pressure_new(j,i)=pressurenew;
if(pressure_new(i,i)-pressurevalue(i,1))==0
p_impactmatrix(j,i)=0;
else
P_impactmatrix(j,i)=abs(pressure_new(j,i)-pressurevalue(j,1))/abs(pressure_new(i,i)-pressurevalue(i,1));
end
end
end
[errcode,tstep]=calllib('epanet2','ENnextH',tstep);
end 
tstep=1;
errcode=calllib('epanet2','ENsetnodevalue',i,1,basedemand);
errcode=calllib('epanet2','ENcloseH');
end
errcode=calllib('epanet2','ENcloseH');
unloadlibrary('E:\MATLAB\epanet2');
