#include <iostream>


#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>


using namespace std;

int becomeDaemon()
{

    switch (fork())
    {
        case -1: return -1;
        case 0: break;
        default: _exit(EXIT_SUCCESS);
    }

    if(setsid() == -1)
    {
        return -1;
    }

    switch (fork())
    {
        case -1: return -1;
        case 0: break;
        default: _exit(EXIT_SUCCESS);
    }

    return 0;
}
