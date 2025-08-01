#include <memory>

int main(void)
{
    volatile char *p = new char[sizeof(char)];
    *p = 'a';
    // Don't call `delete` to intentionally cause a memory leak
    return 0;
}