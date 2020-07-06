#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

int bulk_alloc(size_t malloc_overhead_attempt, size_t size)
{
  int const number = 100;
  long int distance = 9999;
  char* ptr[number];
  ptr[0] = (char*)malloc(size - malloc_overhead_attempt);
  for (int i = 1; i < number; ++i)
  {
    ptr[i] = (char*)malloc(size - malloc_overhead_attempt);
    if (ptr[i] > ptr[i - 1] && (ptr[i] - ptr[i - 1]) < distance)
      distance = ptr[i] - ptr[i - 1];
  }
  for (int i = 0; i < number; ++i)
    free(ptr[i]);
  return (distance == (long int)size);
}

int main()
{
  int result = 8;       // Guess a default
  for (size_t s = 0; s <= 64; s += 2)
    if (bulk_alloc(s, 2048))
    {
      result = s;
      break;
    }
  // No new line!
  printf("%d", result);
}
