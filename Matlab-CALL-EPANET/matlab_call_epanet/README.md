# Matlab_CALL_EPANET
## 简单说明
这是一个matlab脚本文件。是在学习matlab调用epanet2.dll过程中找到的一个文件。

历史久远，难以考证其来源。猜测为侯本伟老师提供。

## 修改说明
在2020年9月20日，在电脑文件整理过程中，对脚本文件进行了一些修改：
1. 修改文件名；
2. 修改案例管网名称；
3. 修改部分设置。（number==1）
以实现脚本运行。

## 脚本运行需要
- epanet2.dll
- epanet2.h

## 脚本深度说明
脚本最终输出变量为
P_impactmatrix,为一个n*n的矩阵。n为节点数。
P_impactmatrix(j,i)的含义为第i个节点基本需水量增加30%，对第j个节点压力的影响。如下式

P_impactmatrix(j,i)=abs(pressure_new(j,i) - pressurevalue(j,1))/abs(pressure_new(i,i) - pressurevalue(i,1));

式中，abs(pressure_new(j,i) - pressurevalue(j,1))为第j个节点压力变化绝对值；
abs(pressure_new(i,i) - pressurevalue(i,1))第i个节点压力变化绝对值。

## 脚本评价
脚本自然流畅的应用了matlab调用epanet2.dll的基本函数。是初学者的很好的说明文档。


