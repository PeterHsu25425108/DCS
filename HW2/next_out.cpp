#include <iostream>
using namespace std;

int main()
{
    for (int i = 5; i <= 32; i++)
    {
        cout << i << ": next_out = {" << 32 - i << "'d0, input_buffer[" << i - 1 << ":0]};" << endl;
    }
    return 0;
}

//{(32-i)'d0, input_buffer[i-1:0]}