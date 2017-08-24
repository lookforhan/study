#include<stdio.h>
int main(int argc,char *argv[])
{
int i=1;
int sum=0;
for (i=1;i<argc;i++)
	sum=sum+argv[i];
printf("\n%d\n",sum);
return 0;
}
