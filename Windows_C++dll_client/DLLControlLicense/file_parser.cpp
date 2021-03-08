
#include "pch.h"
#include"file_parser.h"

#include<fstream>
#include<sstream>
#include<map>
#include<vector>
#include<exception>
#include<memory>
#include <cstdlib>
#include<string.h>
using namespace std;


TargetPoint::TargetPoint(int port, string ip_addres, double time_dur)
{
	port_ = port;
	ip_addres_ = ip_addres;
	time_dur_ = time_dur;
}
void TargetPoint::SetPort(int port)
{
	port_ = port;
}

void TargetPoint::SetIPaddres(string ip_addres)
{
	ip_addres_ = ip_addres;
}

void TargetPoint::SetTimeDuration(double time_dur)
{
	time_dur_ = time_dur;
}

std::ostream& operator << (std::ostream &out, const TargetPoint &targetPoint)
{
    // Поскольку operator<< является другом класса Point, то мы имеем прямой доступ к членам Point
    out << "PORT_FLAG" << std::endl;
    out << targetPoint.port_ << std::endl;

    out << "IP_ADDRESS_FLAG" << std::endl;
    out << targetPoint.ip_addres_ << std::endl;

    out << "TIME_DUR_FLAG" << std::endl;
    out << targetPoint.time_dur_ << std::endl;

    return out;
}

std::wostream& operator << (std::wostream &out, const TargetPoint &targetPoint)
{
    // Поскольку operator<< является другом класса Point, то мы имеем прямой доступ к членам Point
    out << L"PORT_FLAG" << std::endl;
    out << targetPoint.port_ << std::endl;

    std::mbstate_t state =  std::mbstate_t();
    char *str_surs(new char[targetPoint.ip_addres_.size() + 1]);
    strcpy(str_surs, targetPoint.ip_addres_.c_str());
    std::size_t len = 1 + std::mbsrtowcs(NULL , (const char**)&str_surs, 0 , &state);
    std::wstring wstr;
    wstr.resize(len,'\0');
    std::mbsrtowcs(&wstr[0], (const char**)&str_surs, wstr.size(), &state);

    out << L"IP_ADDRESS_FLAG" << std::endl;
    out << wstr << std::endl;

    out << L"TIME_DUR_FLAG" << std::endl;
    out << targetPoint.time_dur_ << std::endl;

    return out;
}

// std::wifstream


std::wistream& operator >> (std::wistream &winput, TargetPoint &targetPoint)
{
    // Поскольку operator >> является другом класса Point, то мы имеем прямой доступ к членам Point

    wstring wline;

    while(getline(winput, wline))
    {
        if(L"PORT_FLAG"  == wline)
        {
            getline(winput, wline);
			wstringstream ss(wline);
            targetPoint.is_parsed_ = true;

			int port(0);
			if(ss >> port)
			targetPoint.SetPort(port);
        }
        else if(L"TIME_DUR_FLAG"  == wline)
        {
            getline(winput, wline);
			wstringstream wss(wline);
			targetPoint.is_parsed_ = true;

			double time_dur(0.0);
			if(wss >> time_dur)
			targetPoint.SetTimeDuration(time_dur);

        }
        else if(L"IP_ADDRESS_FLAG"  == wline)
        {
            targetPoint.is_parsed_ = true;
            if(getline(winput, wline))
			targetPoint.SetIPaddres(string(wline.begin(), wline.end()));
        }
    }

    return winput;
}


std::istream& operator >> (std::istream &input, TargetPoint &targetPoint)
{
    // Поскольку operator<< является другом класса Point, то мы имеем прямой доступ к членам Point

    string line;

    while(getline(input, line))
    {
        if("PORT_FLAG"  == line)
        {
            getline(input, line);
			stringstream ss(line);
			targetPoint.is_parsed_ = true;

			int port(0);
			if(ss >> port)
			targetPoint.SetPort(port);
        }
        else if("TIME_DUR_FLAG"  == line)
        {
            getline(input, line);
			stringstream ss(line);
			double time_dur(0.0);
			targetPoint.is_parsed_ = true;
			if(ss >> time_dur)
			targetPoint.SetTimeDuration(time_dur);

        }
        else if("IP_ADDRESS_FLAG"  == line)
        {
            targetPoint.is_parsed_ = true;
            if(getline(input, line))
			targetPoint.SetIPaddres(line);
        }
    }

    return input;
}


bool fileExist(const string& fileName)
{
    ifstream file(fileName);
    auto result(file.is_open());
    file.close();
    return result;
}

const TargetPoint& fileSaver(const TargetPoint& targetPoint, const string& fileName)
{
    ofstream file(fileName, ios_base::out | ios_base::trunc);

    file << targetPoint;

    file.close();

    return targetPoint;
}

TargetPoint& fileParser(TargetPoint& targetPoint, const string& fileName)
{

    std::ifstream input(fileName);

    input >> targetPoint;
    input.close();
    if(targetPoint.is_parsed_)
    return targetPoint;

    std::wifstream winput(fileName);

    winput >> targetPoint;
    winput.close();

	return targetPoint;
}

