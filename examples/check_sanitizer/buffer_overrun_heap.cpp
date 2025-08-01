#include <stdlib.h>
#include <string.h>

int check_buffer_overrun_heap()
{
    volatile int n = 15;
    char *buf = (char *)malloc(n);
    memset(buf, 0, n);
    buf[n] = 'a'; // This line is intentionally incorrect to demonstrate a potential buffer overflow.
    int sum = 0;
    for (auto i = 0; i < n; ++i)
    {
        sum += buf[i];
    }
    return sum;
}

int main()
{
    volatile int v = check_buffer_overrun_heap();
    (void)v;
}
