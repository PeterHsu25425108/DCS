#include <iostream>
#include <fstream>
#include <sstream>
using namespace std;

int main()
{
    ofstream out_file("case.txt");
    for (int i = 0; i < 16; i++)
    {
        stringstream ss;
        for (int j = 0; j < i; j++)
        {
            ss << "0";
        }
        if (ss.str().length() < 16)
            ss << "1";

        while (ss.str().length() < 16)
        {
            ss << "?";
        }
        ss << ": begin";
        ss.str("16'b" + ss.str());

        out_file << ss.str() << endl;
        int x = ((i < 15) ? 1 - i : 0);
        out_file << "out_exp = "
                 << "exp_sum" << ((x > 0) ? "+" : "-") << x << ";" << endl;

        ss.clear();
        ss.str("");
        if (i <= 8)
        {
            ss << "[" << 14 - i << ":" << 8 - i << "]";
        }
        else if (i <= 14)
        {
            ss << "[" << i - 9 + 5 << ":0]";
        }

        if (i < 15)
        {
            out_file << "out_frac = frac_unnormalized" << ss.str() << ";" << endl;
        }
        else
        {
            out_file << "out_frac = 0;" << endl;
        }

        out_file << "end" << endl
                 << endl;
        ;
    }
    /*out_file << "16'b0000000000000000:begin" << endl;
    out_file << "out_exp = exp_sum;" << endl;
    out_file << "out_frac = 0;" << endl;*/

    out_file.close();
    return 0;
}