#include <stdlib.h>
#include <stdio.h>

int main (int argc,char *argv[])
{
int input =0 ;
float output=0;
if (argc !=2)
return 1;
input = atoi(argv[1]);
output=input+54.4;
printf("%1f\n",output);
return 0;
}
