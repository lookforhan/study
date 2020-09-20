%����ѹ��Ӱ��ϵ������
clc;
clear all;
close all;
 pressure_new=[];
 P_impactmatrix=[];
 basedemand_new=[];
errcode=loadlibrary('epanet2.dll','epanet2.h');%����EPANET�ļ�
errcode=calllib('epanet2','ENopen','���� - ����.inp','���� - ����.rpt','');%��inp�ļ�
nodenum=0;%nodenum���ܽڵ���Ŀ�����Ը�������ֵ�����Ը�������ֵ
[errcode,nodenum]=calllib('epanet2','ENgetcount',0,nodenum);%��ȡ�ܽڵ���Ŀ��ע���ȡ��ֵ�ķ�ʽ������Ҫ����ͬ�Ĳ���nodenum��Ҳ���Բ�ͬ
%0�����ȡ�ܽڵ���Ŀ�Ĵ��룬��ߵ�nodenumΪ����ֵ�Ĵ洢�������ұ�nodenumΪ��ʼֵ��
tanknum=0;%tanknum��ˮԴ�ڵ���Ŀ�����Ը�������ֵ����Ҫ��ȡˮԴ�ڵ���Ŀ�����ʼ��
[errcode,tanknum]=calllib('epanet2','ENgetcount',1,tanknum);%��ȡˮԴ����Ŀ����ʽ���������ͬ��1�����ȡˮԴ�ڵ���Ŀ�Ĵ���
junctionnum=nodenum - tanknum;%junctionnum�����ӽڵ���Ŀ��ע�����ӽڵ���Ŀ�����ܽڵ�����ȥˮԴ�ڵ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
errcode=calllib('epanet2','ENopenH');%��ˮ������ϵͳ
errcode=calllib('epanet2','ENinitH',0);%��ʼ����ˮ��ˮλ���ܵ�״̬�������Լ�ģ��ʱ�䣬0��ʾ���洢������ˮ�����
time=0;%��ʼ������ʱ�䣬����������ֵ
number=0;%numberΪˮ���������е��Ľ׶���
pressure=0;
tstep=1;%��ʼ��ˮ�������Ĳ������������������ֵ
while (tstep && ~errcode)
[errcode,time]=calllib('epanet2','ENrunH',time);%ִ����timeʱ�̵�ˮ������
number=time/3600;
if (number==11)%��ȡ��11��ˮ��������ˮ������
for i=1:junctionnum
    [errcode,pressure]=calllib('epanet2','ENgetnodevalue',i,11,pressure);
    pressurevalue(i,1)=pressure;
end
end
[errcode,tstep]=calllib('epanet2','ENnextH',tstep);
end
errcode=calllib('epanet2','ENcloseH');%�ر�ˮ������ϵͳ���ͷ��ڴ�
pressurevalue;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basedemand=0;%basedemand�ǽڵ�����ֵ�����Ը�������ֵ����Ҫ��ȡ�ڵ�����ֵ�����ʼ��
pressurenew=0;
tstep=1;
time=0;
number=0;
for i=1:junctionnum
    errcode=calllib('epanet2','ENopenH');
    errcode=calllib('epanet2','ENinitH',0);
    [errcode,basedemand]=calllib('epanet2','ENgetnodevalue',i,1,basedemand);%��ȡ�ڵ�����ֵ��i����ڵ�������1������Ҫ��ȡ�Ľڵ�����ֵ�Ĵ���
    %1��ʾ��Ҫ��ȡ�Ľڵ�����ֵΪ�ڵ������ˮ����nodevalue�ǳ�ʼ�ڵ�����ֵ
    basedemand_new(i,1)=basedemand*(1+0.3);%�ı�ڵ�i�Ļ�����ˮ�����Ӷ��ı乤��
    errcode=calllib('epanet2','ENsetnodevalue',i,1,basedemand_new(i,1));%���µĽڵ������ˮ������ڵ�i
    while (tstep && ~errcode)
    [errcode,time]=calllib('epanet2','ENrunH',time);%ִ����timeʱ�̵�ˮ������
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
    errcode=calllib('epanet2','ENsetnodevalue',i,1,basedemand);%ע��ÿһ��ѭ����Ҫ�Ѹı��Ľڵ������ˮ���Ļ�ԭ���Ľڵ������ˮ��
    errcode=calllib('epanet2','ENcloseH');
end

 %   P_impactmatrix;%���ѹ��Ӱ��ϵ������
    errcode=calllib('epanet2','ENclose');%�ر�tookitϵͳ
    unloadlibrary('epanet2');
