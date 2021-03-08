#ifndef FILE_PARSER_H_INCLUDED
#define FILE_PARSER_H_INCLUDED


#include <iostream>
#include<string>

struct TargetPoint
{
    bool is_parsed_ = false;
	int port_;
	std::string ip_addres_;
	double time_dur_;
	TargetPoint() = default;
	explicit TargetPoint(int port, std::string ip_addres, double time_dur);

	void SetPort(int port);

	void SetIPaddres(std::string ip_addres);

	void SetTimeDuration(double time_dur);
};

TargetPoint& fileParser(TargetPoint& targetPoint, const std::string& fileName);


#endif // FILE_PARSER_H_INCLUDED
