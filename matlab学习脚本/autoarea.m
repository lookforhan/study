%计算矩形面积
%用户分别依次输入边长的数据
%提示用户输入数据
%得出矩形面积数值
function autoarea(a,b)
disp('计算矩形面积');
a=input('输入边长a数值');
b=input('输入边长b数值');
autoarea=a*b;
disp('面积是');
fprintf('%d\n',autoarea);
end
