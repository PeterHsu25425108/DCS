#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <bitset>
#include <time.h>
using namespace std;

int main(int argc, char const *argv[])
{
    srand(time(NULL));
    ofstream out1, out2;
    out1.open("input.txt");
    out2.open("output.txt");
    if (out1.fail() || out2.fail())
    {
        cout << "input file opening failed...";
        exit(1);
    }
    for (int i = 0; i < 500; i++)
    {
        int n1 = rand() % (16) - 8;
        int n2 = rand() % (16) - 8;
        int n3 = rand() % (16) - 8;
        int n4 = rand() % (16) - 8;
        int mode = rand() % (4);
        out1 << bitset<2>(mode) << bitset<4>(n1) << bitset<4>(n2) << bitset<4>(n3) << bitset<4>(n4);

        vector<int> ns;
        ns.push_back(n1);
        ns.push_back(n2);
        ns.push_back(n3);
        ns.push_back(n4);
        sort(ns.begin(), ns.end());
        switch (mode)
        {
        case 0:
            out2 << bitset<6>(ns[0] + ns[1]);
            break;
        case 1:
            out2 << bitset<6>(ns[1] - ns[0]);

            break;
        case 2:
            out2 << bitset<6>(ns[3] - ns[2]);

            break;
        case 3:
            out2 << bitset<6>(ns[0] - ns[3]);
            break;
        default:
            break;
        }
        if (i < 499)
        {
            out2 << endl;
            out1 << endl;
        }
    }

    return 0;
}