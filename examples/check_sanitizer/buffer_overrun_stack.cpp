#include <stdlib.h>
#include <string.h>

int check_buffer_overrun_stack()
{
    volatile char buf[15];
    volatile auto n = sizeof(buf);
    memset((char *)buf, 0, sizeof(buf));
    buf[n] = 'a'; // This line is intentionally incorrect to demonstrate a potential buffer overflow.
    int sum = 0;
    for (auto i = 0u; i < sizeof(buf); ++i)
    {
        sum += buf[i];
    }
    return sum;
}

int main()
{
    volatile int v = check_buffer_overrun_stack();
    (void)v;
}
