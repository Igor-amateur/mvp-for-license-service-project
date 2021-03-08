#ifndef TIMERCPP11_H_INCLUDED
#define TIMERCPP11_H_INCLUDED

#include<chrono>

enum class Period{Second = 1, Minute = 60, Hour = 3600,
Day = 86400, Week = 604800};

bool minutespassed(bool& first_call, std::chrono::time_point<std::chrono::steady_clock>& start, double minutes);
bool passed(Period period, double time, bool& first_call, std::chrono::time_point<std::chrono::steady_clock>& start);

#endif // TIMERCPP11_H_INCLUDED
