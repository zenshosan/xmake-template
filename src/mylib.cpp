#include "mylib.h"
#include "config.h"

const char *get_version(void)
{
    return MYLIB_VERSION;
}

int myadd(int x, int y)
{
    if (x == 0)
    {
        return y;
    }
    if (y == 0)
    {
        return x;
    }
    return x + y;
}
