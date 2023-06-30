#include <iostream>
#include <vector>
#include <fstream>
using namespace std;

bool threshold(int x)
{
    if (x == 238)
        return 0;
    else if (x == 239)
        return 1;

    switch (x % 19)
    {
    case 0:
    {
        return 1;
        break;
    }
    case 2:
    {
        return 1;
        break;
    }
    case 5:
    {
        return 1;
        break;
    }
    case 8:
    {
        return 1;
        break;
    }
    case 10:
    {
        return 1;
        break;
    }
    case 13:
    {
        return 1;
        break;
    }
    case 16:
    {
        return 1;
        break;
    }

    default:
        return 0;
        break;
    }
}

int exact(int x)
{
    return 937 * x / 4093 - 1;
}

int my_func(int x)
{
    int cumu_val = 0;
    int tf_val = 0;
    for (int i = 0; i < x; i++)
    {
        cumu_val++;
        if (cumu_val >= threshold(tf_val))
        {
            tf_val++;
            cumu_val = 0;
        }
    }
    return tf_val;
}

string toBinary(int n)
{
    std::string r;
    while (n != 0)
    {
        r = (n % 2 == 0 ? "0" : "1") + r;
        n /= 2;
    }

    if (r.length() > 8)
    {
        r = r.substr(r.length() - 8, 8);
    }
    else
    {
        while (r.length() < 8)
        {
            r = '0' + r;
        }
    }

    return r;
}

int main()
{
    vector<int> arr;
    ofstream out_file("data.txt");
    ofstream out("theory.txt");
    ofstream case_out("case.txt");

    for (int i = 0; i <= 1024; i++)
    {
        int x = exact(i);
        int y = my_func(i);

        /*if (x == y)
        {
            out << "f[" << i << "] = " << x << " correct!" << endl;
        }
        else
        {
            arr.push_back(i);
        }*/
        out << i << " " << exact(i) << endl;
    }

    for (int i = 0; i < arr.size(); i++)
    {
        out << "------" << endl;
        out << i << " wrong!!" << endl;
        out << "correct = " << exact(arr[i]) << endl;
        out << "myfunc = " << my_func(arr[i]) << endl;
        out << "------" << endl;
    }

    case_out << "casez(tf_counter_val)" << endl;
    for (int i = 0; i <= 256; i++)
    {

        case_out << "    8'b" << toBinary(i) << ":"
                 << " exception = " << ((i == 238) || (i == 239)) << ";" << endl;
    }
    case_out << "   default: exception = 1'bx;" << endl;
    case_out << "endcase";

    out.close();
    out_file.close();
    case_out.close();
    return 0;
}