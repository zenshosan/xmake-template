#include <climits>

int ub_shift()
{
    volatile int i = 23;
    i <<= 32;
    return i;
}

int ub_overflow()
{
    volatile int i = INT_MIN;
    int j = -i;
    return j;
}

int main()
{
    volatile int v0 = ub_shift();
    volatile int v1 = ub_overflow();
    (void)v0;
    (void)v1;
}
