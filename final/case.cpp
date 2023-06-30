#include <iostream>
#include <fstream>
using namespace std;

int main()
{
    ofstream out_file("case.txt");
    int n;
    fin >> n;
    for (int i = 0; i < n; i++)
    {
        int a, b;
        fin >> a >> b;
        fout << a + b << endl;
    }
    return 0;
}
```