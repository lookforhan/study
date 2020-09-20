%计算压力影响系数矩阵
clc;
clear all;
close all;
 pressure_new=[];
 P_impactmatrix=[];
 basedemand_new=[];
errcode=loadlibrary('epanet2.dll','epanet2.h');%加载EPANET文件
errcode=calllib('epanet2','ENopen','管网 - 副本.inp','管网 - 副本.rpt','');%打开inp文件
nodenum=0;%nodenum是总节点数目，可以赋予任意值，可以赋予任意值
[errcode,nodenum]=calllib('epanet2','ENgetcount',0,nodenum);%获取总节点数目，注意获取数值的方式，两边要有相同的参数nodenum，也可以不同
%0代表获取总节点数目的代码，左边的nodenum为返回值的存储变量，右边nodenum为初始值。
tanknum=0;%tanknum是水源节点数目，可以赋予任意值，但要获取水源节点数目必须初始化
[errcode,tanknum]=calllib('epanet2','ENgetcount',1,tanknum);%获取水源点数目，方式与上面的相同，1代表获取水源节点数目的代码
junctionnum=nodenum - tanknum;%junctionnum是连接节点数目，注意连接节点数目等于总节点数减去水源节点数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
errcode=calllib('epanet2','ENopenH');%打开水力分析系统
errcode=calllib('epanet2','ENinitH',0);%初始化贮水池水位，管道状态和设置以及模拟时间，0表示不存储二进制水力结果
time=0;%初始化工况时间，可以是任意值
number=0;%number为水力步长进行到的阶段数
pressure=0;
tstep=1;%初始化水力分析的步数，可以是任意非零值
while (tstep && ~errcode)
[errcode,time]=calllib('epanet2','ENrunH',time);%执行在time时刻的水力分析
number=time/3600;
if (number==11)%获取第11步水力分析的水力数据
for i=1:junctionnum
    [errcode,pressure]=calllib('epanet2','ENgetnodevalue',i,11,pressure);
    pressurevalue(i,1)=pressure;
end
end
[errcode,tstep]=calllib('epanet2','ENnextH',tstep);
end
errcode=calllib('epanet2','ENcloseH');%关闭水力分析系统，释放内存
pressurevalue;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basedemand=0;%basedemand是节点属性值，可以赋予任意值，但要获取节点属性值必须初始化
pressurenew=0;
tstep=1;
time=0;
number=0;
for i=1:junctionnum
    errcode=calllib('epanet2','ENopenH');
    errcode=calllib('epanet2','ENinitH',0);
    [errcode,basedemand]=calllib('epanet2','ENgetnodevalue',i,1,basedemand);%获取节点属性值，i代表节点索引，1代表所要获取的节点属性值的代码
    %1表示所要获取的节点属性值为节点基本需水量，nodevalue是初始节点属性值
    basedemand_new(i,1)=basedemand*(1+0.3);%改变节点i的基本需水量，从而改变工况
    errcode=calllib('epanet2','ENsetnodevalue',i,1,basedemand_new(i,1));%把新的节点基本需水量赋予节点i
    while (tstep && ~errcode)
    [errcode,time]=calllib('epanet2','ENrunH',time);%执行在time时刻的水力分析
    number=time/3600;
    if (number==11)
    for j=1:junctionnum
        [errcode,pressurenew]=calllib('epanet2','ENgetnodevalue',j,11,pressurenew);
        pressure_new(j,i)=pressurenew;
         if (pressure_new(i,i) - pressurevalue(i,1))==0
           P_impactmatrix(j,i)=0;
         else
       P_impactmatrix(j,i)=abs(pressure_new(j,i) - pressurevalue(j,1))/abs(pressure_new(i,i) - pressurevalue(i,1));
         end
    end
    end
    [errcode,tstep]=calllib('epanet2','ENnextH',tstep);
    end
    tstep=1;
    errcode=calllib('epanet2','ENsetnodevalue',i,1,basedemand);%注意每一次循环后要把改变后的节点基本需水量改回原来的节点基本需水量
    errcode=calllib('epanet2','ENcloseH');
end

 %   P_impactmatrix;%输出压力影响系数矩阵
    errcode=calllib('epanet2','ENclose');%关闭tookit系统
    unloadlibrary('epanet2');
