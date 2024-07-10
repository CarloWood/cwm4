#include "stdio.h"

int main()
{
  __builtin_cpu_init();
  printf("%c", __builtin_cpu_supports("bmi2") ? '1' : '0');
}
