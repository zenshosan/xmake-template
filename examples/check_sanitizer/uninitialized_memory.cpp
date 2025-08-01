int main()
{
    volatile int i = 1;
    int *a = new int[10];
    a[0] = 0;
    return a[i]; // This line is intentionally incorrect to demonstrate a potential use of uninitialized memory.
}
