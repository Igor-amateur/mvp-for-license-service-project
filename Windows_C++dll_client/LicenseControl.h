#pragma once
/*
#ifdef DLLCTRLIC_API_EXPORTS
#define DLLCTRLIC_API __declspec(dllexport)
#else
#define DLLCTRLIC_API __declspec(dllimport)
#endif
*/

extern "C" __declspec(dllexport)
int run_license_ctrl(const char* user_key, const int& user_id, int& handling, int& status);

extern "C" __declspec(dllexport)
int test_func();

extern "C" __declspec(dllexport)
int test_run_license_ctrl(int& handling, int& status);