// dllmain.cpp : Defines the exported functions for the DLL
#include "pch.h"


#include <iostream>

#include <thread>         // std::this_thread::sleep_for
#include <chrono>         // std::chrono::seconds
#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/enable_shared_from_this.hpp>
#include <boost/asio.hpp>
#include <boost/asio/wait_traits.hpp>
// #include <boost/asio/waitable_timer_service.hpp>
#include <vector>

#include"LicenseControl.h"
#include"cryptpp_aes.h"
#include"timerCpp11.h"
#include"file_parser.h"

using namespace CryptoPP;
using namespace boost::asio;
using namespace std::chrono_literals;

using boost::asio::ip::tcp;

enum class Query_Type { REQUEST, CHECK, RELEASE };

void Errorfoo()
{
	boost::asio::error::already_open;					//1
	boost::asio::error::eof;							//2
	boost::asio::error::not_found;						//3
	boost::asio::error::fd_set_failure;					//4
	boost::asio::error::no_permission;					//5
	boost::asio::error::no_memory;						//14
	boost::asio::error::no_such_device;					//20
	boost::asio::error::broken_pipe;					//109
	boost::asio::error::operation_aborted;				//995
	boost::asio::error::try_again;						//1237
	boost::asio::error::interrupted;					//10004
	boost::asio::error::bad_descriptor;					//10009
	boost::asio::error::access_denied;					//10013
	boost::asio::error::fault;							//10014
	boost::asio::error::invalid_argument;				//10022
	boost::asio::error::no_descriptors;					//10024
	boost::asio::error::would_block;					//10035
	boost::asio::error::in_progress;					//10036
	boost::asio::error::already_started;				//10037
	boost::asio::error::not_socket;						//10038
	boost::asio::error::message_size;					//10040
	boost::asio::error::no_protocol_option;				//10042
	boost::asio::error::socket_type_not_supported;		//10044
	boost::asio::error::operation_not_supported;		//10045
	boost::asio::error::address_family_not_supported;	//10047
	boost::asio::error::address_in_use;					//10048
	boost::asio::error::network_down;					//10050
	boost::asio::error::network_unreachable;			//10051
	boost::asio::error::network_reset;					//10052
	boost::asio::error::connection_aborted;				//10053
	boost::asio::error::connection_reset;				//10054
	boost::asio::error::no_buffer_space;				//10055
	boost::asio::error::already_connected;				//10056
	boost::asio::error::not_connected;					//10057
	boost::asio::error::shut_down;						//10058
	boost::asio::error::timed_out;						//10060
	boost::asio::error::connection_refused;				//10061
	boost::asio::error::name_too_long;					//10063
	boost::asio::error::host_unreachable;				//10065
	boost::asio::error::service_not_found;				//10109
	boost::asio::error::host_not_found;					//11001
	boost::asio::error::host_not_found_try_again;		//11002
	boost::asio::error::no_recovery;					//11003
	boost::asio::error::no_data;						//11004
}

byte key[32]{ 0 };
byte iv[12]{ 0 };
string secret = "Any pre-agreed phrase";

void show_content(std::string hello)
{
	for (auto ch : hello)
	{
		std::cout << " " << (int)ch << "=" << ch;
	}
}
int BOOST_ERROR_CODE{ 0 };
std::string DataExchange(const std::string& mess, ip::tcp::socket& sock);
void MessageParsing(const std::string& mess_s, std::string& firstPart, std::string& secondPart);

extern "C" __declspec(dllexport)
int test_func()
{
	return 100;
}

extern "C" __declspec(dllexport)
int test_run_license_ctrl(int& handling, int& status)
{
	const int user_id = 800432318;
	const char* user_key =
	"c55d4774639357e7465d10fd1183036285d66f264aa7b3557d320de4825476c729627261663272bfa94e9c6320472145bd9696dd8d11c4785eb7b0b58ad3519c";
	return run_license_ctrl( user_key, user_id, handling, status);
}

extern "C" __declspec(dllexport)
int run_license_ctrl(const char* user_key, const int& user_id, int& handling, int& status)
{ 
	// first save working version 

	status = 10000;

	//load IP adress of server  
	TargetPoint targetPoint;
	targetPoint = fileParser(targetPoint, "target_point.txt");

	io_service service;
	deadline_timer t(service, boost::posix_time::seconds(2));

	// save in temp_uid ID geted from server
	int temp_uid(0);
	// resave it
	int old_temp_uid(0);
	// if it is first connection to server (for this work sesion)
	bool first_call(true);

	const char* REQUEST("REQUEST");
	const char* CHECK("CHECK");
	const char* RELEASE("RELEASE");
	Query_Type query_type = Query_Type::REQUEST;


	// std::chrono::time_point<std::chrono::steady_clock> start;
	// double minutes(targetPoint.time_dur_);
	//! Начинаем цикл обработки сообщений
	do
	{
		auto start = std::chrono::high_resolution_clock::now();

		//	ip::tcp::endpoint ep(ip::address::from_string("192.168.10.36"), 5050);
		ip::tcp::endpoint ep(ip::address::from_string(targetPoint.ip_addres_), targetPoint.port_);
		ip::tcp::socket sock(service);

		boost::system::error_code error{};
		//! Подключаемся к серверу
		sock.connect(ep, error);


		if (error)
		{
			// 37707 - error status
			// 10000 - undefined status
			// 16009 - confirmed status
			// 46832 - no such key
			// 16584 - key is already in use by someone
			if (10000 == status)
			{
				status = 37707;
			}
			sock.close();
			std::cout << "No connection With Server ERROR " << error.value() << "\n";
			return error.value(); // Connection not created
		}

		// готовим к отправке ключ
		std::string mess_s(user_key);


		if (mess_s.empty())
		{
			mess_s = "Empty Message \n";
			sock.close();
			status = 46832;
			return 1;
		}
		//отправляем ключ
		mess_s = DataExchange(mess_s, sock);

		if ("ERROR" == mess_s)
		{
			// 37707 - error status
			// 10000 - undefined status
			// 16009 - confirmed status
			// 46832 - no such key
			// 16584 - key is already in use by someone
			if (10000 == status)
			{
				status = 37707;
			}
			return BOOST_ERROR_CODE;
		}

		std::string key_answer;
		std::string temp_id_str;
		MessageParsing(mess_s, key_answer, temp_id_str);
		cout << key_answer << " " << key_answer.size() << endl;
		cout << temp_id_str << endl;

		if (key_answer == "KEY_ANSWER_GOOD")
		{
			cout << "Key answer is Good" << endl;
			temp_uid = std::stoi(temp_id_str.c_str());
		}
		//ЗДЕСЬ НУЖНО РАСПИСАТЬ ПРИЧИНЫ ОТКАЗА при запросе ключа
		else if (key_answer == "KEY_ANSWER_UNKNOWN_KEY_REQUEST")
		{
			status = 46832;
			sock.close();
			break;
		}
		else
		{
			status = 37707;
			cout << "the answer is false key" << endl;
			sock.close();
			break;
		}


		// CHECK RELEASE

		switch (query_type)
		{
		case Query_Type::REQUEST:
			mess_s = std::string(REQUEST) + "&" + std::to_string(user_id);
			break;
		case Query_Type::CHECK:
			mess_s = std::string(CHECK) + "&" + std::to_string(old_temp_uid);
			break;
		case Query_Type::RELEASE:
			mess_s = std::string(RELEASE) + "&" + std::to_string(old_temp_uid);
			break;
		}
		old_temp_uid = temp_uid;

		mess_s = DataExchange(mess_s, sock);

		if ("ERROR" == mess_s)
		{
			// 37707 - error status
			// 10000 - undefined status
			// 16009 - confirmed status
			// 46832 - no such key
			// 16584 - key is already in use by someone
			if (10000 == status)
			{
				status = 37707;
			}
			return BOOST_ERROR_CODE;
		}

		std::string license_answer;

		MessageParsing(mess_s, license_answer, temp_id_str);

		if (license_answer == "LICENSE_ANSWER_GOOD")
		{
			// 37707 - error status
			// 10000 - undefined status
			// 16009 - confirmed status
			// 46832 - no such key
			// 46830 - no such client
			// 16584 - key is already in use by someone
			// 73134 - key is released
			status = 16009;
			cout << "License status is GooD" << endl;
			temp_uid = std::stoi(temp_id_str.c_str());
		}
		else if (license_answer == "LICENSE_ANSWER_GOOD_WORK")
		{
			// 37707 - error status
			// 10000 - undefined status
			// 16009 - confirmed status
			// 26009 - continued status;
			// 46832 - no such key
			// 46830 - no such client
			// 16584 - key is already in use by someone
			// 73134 - key is released
			status = 26009;
			cout << "License status is Work" << endl;
			temp_uid = std::stoi(temp_id_str.c_str());
		}
		else if (license_answer == "LICENSE_ANSWER_GOOD_RELEASE")
		{
			status = 73134;
			cout << "License answer good release" << endl;
			sock.close();
			break;
		}
		//ЗДЕСЬ НУЖНО РАСПИСАТЬ ПРИЧИНЫ ОТКАЗА
		else if (license_answer == "LICENSE_ANSWER_BUSY")
		{
			status = 16584;
			sock.close();
			break;
		}
		else if (license_answer == "KEY_ANSWER_UNKNOWN_KEY_REQUEST")
		{
			status = 46832;
			cout << "the answer is unknown key" << endl;
			sock.close();
			break;
		}
		else if (license_answer == "LICENSE_ANSWER_UNKNOWN_KLIENT_REQUEST")
		{
			status = 46830;
			cout << "the answer is unknown client" << endl;
			sock.close();
			break;
		}
		else if (license_answer == "LICENSE_ANSWER_NOT_WORK")
		{
			status = 40711;
			cout << "the answer is license not work" << endl;
			sock.close();
			break;
		}
		else if (license_answer == "LICENSE_ANSWER_KEY_NOT_WORK")
		{
			status = 40743;
			cout << "the answer is key not work" << endl;
			sock.close();
			break;
		}
		else
		{
			cout << "the answer is false key status" << endl;
			status = 37707;
			sock.close();
			break;
		}

		auto end = std::chrono::high_resolution_clock::now();
		std::chrono::duration<double, std::milli> elapsed = end - start;

		////////////////////////////////////////
		std::cout << "ALLRight Time Sesion = " << elapsed.count() << " ms" << std::endl;


		mess_s.clear();

		// if (passed(Period::Minute, minutes, first_call, start))
			//     if (minutespassed(first_call, start, minutes))
		if(handling == 1)
		{
			query_type = Query_Type::RELEASE;
		}
		else
		{
			query_type = Query_Type::CHECK;
		}
		sock.close();
		std::this_thread::sleep_for(std::chrono::milliseconds(1000));

	} while (true);

	return 0;
	// 0800506800
}

// DATA EXCHANGE
std::string DataExchange(const std::string& mess, ip::tcp::socket& sock)
{
	char data[512];
	boost::system::error_code error{};
	//! шифруем сообщение
	std::string mess_s = Encrypt_aes(key, sizeof(key), iv, sizeof(iv), secret, mess);
	//! убираем нули
	mess_s = deziro(mess_s);
	//! отправляем сообщение
	sock.write_some(buffer(mess_s.c_str(), mess_s.size()), error);

	if (error)
	{
		std::cout << "Wrute_some with ERROR" << error << "\n";
		BOOST_ERROR_CODE = error.value();
		return "ERROR"; // Connection closed
	}

	//! получаем ответ
	size_t length = sock.read_some(buffer(data, 1024), error);
	if (error)
	{
		std::cout << "Connection closed with ERROR: " << error << "\n";
		BOOST_ERROR_CODE = error.value();
		return "ERROR"; // Connection closed
	}
	if (0 == length)
	{
		std::cout << "No connection With Server \n";
		BOOST_ERROR_CODE = error.value();
		return "ERROR";
	}
	else
	{
		data[length] = '\0';
		//std::cout << data << '\n';

		mess_s = std::string(data, length);
	}

			//возвращаем нули на свои позиции
	mess_s = reziro(mess_s);

	//Расшифровка
	mess_s = Decrypt_aes(key, sizeof(key), iv, sizeof(iv), secret, mess_s);
	cout << mess_s << endl;
	return mess_s;

}

void MessageParsing(const std::string& mess_s, std::string& firstPart, std::string& secondPart)
{
	auto delim(mess_s.find('&'));
	firstPart = std::string(mess_s.begin(), (mess_s.begin() + delim)); // license_status
	secondPart = std::string(mess_s.begin() + delim + 1, mess_s.end());// temp_id_str
}
