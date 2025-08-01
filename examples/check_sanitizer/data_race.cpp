#include <thread>

int data;

void thread_func1()
{
    data++;
}

void thread_func2()
{
    data--;
}

int main()
{
    std::thread th1(thread_func1);
    std::thread th2(thread_func2);
    th1.join();
    th2.join();
}