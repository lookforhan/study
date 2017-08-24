#include<math.h>
#include<stdio.h>
int main()
{
double a,b,c,disc,x1,x2,p,q;
scanf("%f%f%f",&a,&b,&c);
disc=b*b-4*a*c;
if (disc<0)
printf("this equation has not real root!\n");
else 
{
p=-b/(2.0*a);
q=sqrt(disc)/(2.0*a);
x1=p+q,x2=p-q;
printf("x1=%7.2f\nx2=%7.2f\n",x1,x2);
}
return 0;
}
