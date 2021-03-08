

#include"timerCpp11.h"
/*/	https://en.cppreference.com/w/cpp/chrono/steady_clock	*/

using namespace std::chrono;


bool minutespassed(bool& first_call, time_point<steady_clock>& start, double minutes)
{
	steady_clock clock;

	if (clock.is_steady)
	{
		if (first_call)
		{
			start = clock.now();
			first_call = false;
		}
		auto next = clock.now();

		duration<double> elapsed_seconds = next - start;

		auto elapsed_minutes(elapsed_seconds.count() / 60.0);

		if (elapsed_minutes >= minutes)
		{
			return true;
		}
	}
	return false;
}


bool passed(Period period, double time, bool& first_call, std::chrono::time_point<std::chrono::steady_clock>& start)
{
	steady_clock clock;

	if (clock.is_steady)
	{
		if (first_call)
		{
			start = clock.now();
			first_call = false;
		}
		auto next = clock.now();

		duration<double> elapsed_seconds = next - start;

		auto elapsed_time(elapsed_seconds.count() / static_cast<double>(period));

		if (elapsed_time >= time)
		{
			return true;
		}
	}
	return false;
}

