// Simple_server.cpp : This file contains the 'main' function. Program execution begins and ends there.
// mysqlclient    -static-libgcc


#include <iostream>
#include <string>
#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/enable_shared_from_this.hpp>
#include <boost/array.hpp>
#include <boost/asio.hpp>
#include <boost/thread/thread.hpp>
#include <thread>         // std::this_thread::sleep_for
#include <chrono>         // std::chrono::seconds
#include <ctime>
#include <numeric>
#include <vector>
#include <clocale>
#include <random>
#include <limits>
#include <map>
#include <queue>
#include <future>
#include <mutex>
#include <memory>

#include"cryptpp_aes.h"
#include"file_parser.h"
#include"MySQLinit.h"
#include"timerCpp11.h"
#include"becomeDaemon.h"

using namespace CryptoPP;
using namespace boost::asio;
using boost::asio::ip::tcp;

typedef boost::shared_ptr<ip::tcp::socket> socket_ptr;

constexpr auto host = "localhost";
constexpr auto user = "root"; // "User name";
constexpr auto pass = "12345678#Good"; // "User password";

constexpr auto db = "Alex_K_DB";

TargetPoint targetPoint;
std::string mess_control;
// int Session_Number(0);
byte key[32]{ 0 };
byte iv[12]{ 0 };
string secret = "Any pre-agreed phrase!!!";

const std::string EXIT("exit");
std::mutex m;

// DATA EXCHANGE
std::string DataExchange(const std::string & mess, socket_ptr sock)
{
        char data[512];
        boost::system::error_code error{};
        //! шифруем сообщение
		std::string mess_s = Encrypt_aes(key, sizeof(key), iv, sizeof(iv), secret, mess);
		//! убираем нули
		mess_s = deziro(mess_s);
		//! отправляем сообщение
		sock->write_some(buffer(mess_s.c_str(), mess_s.size()), error);

		if (error == error::eof)
		{
			std::cout << "Wrute_some with ERROR" << error << "\n";

			return "ERROR"; // Connection closed
		}

		//! получаем ответ
		size_t length = sock->read_some(buffer(data, 1024), error);
		if (error == error::eof)
		{
			std::cout << "Connection closed with ERROR: " << error << "\n";
			return "ERROR"; // Connection closed
		}
		if (0 == length)
		{
			std::cout << "No connection With Server \n";
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

		//расшифровываем
		mess_s = Decrypt_aes(key, sizeof(key), iv, sizeof(iv), secret, mess_s);
        cout << mess_s << endl;
        return mess_s;

}


void MessageParsing(const std::string & mess_s, std::string & firstPart, std::string & secondPart)
{
    auto delim(mess_s.find('&'));
	firstPart = std::string(mess_s.begin(), (mess_s.begin() + delim)); // license_status
	secondPart = std::string (mess_s.begin() + delim + 1, mess_s.end());// temp_id_str
}



struct Client
{
int user_id = 0;
int user_license_id = 0;
std::string user_license_key;
std::chrono::time_point<std::chrono::steady_clock> create_time;
bool for_deleting = false;
};

std::map<int, Client> currentClients;

bool isNotUse(true);

//функция проверяет период ожидания активного клиента
//если время просрочено ключ освобождается
//void release_unused_keys(std::map<int, Client>& currentClients)

bool firstCall(false);

void release_unused_keys()
{
    isNotUse = false;
    std::chrono::system_clock::time_point now_time;
    std::queue <int> q1;
    std::cout << "<____1____>" <<  std::endl;

    while(!isNotUse)
    {
        std::this_thread::sleep_for(std::chrono::milliseconds(1000));
        std::lock_guard<std::mutex> lk(m); //!!!<=
        std::cout << "<____2____>" <<  std::endl;
        for(const auto & item: currentClients)
        {
            int key_(0);
  //          auto[key, client_] = item;
  //          if(passed(Period::Second, 1.1, firstCall, client_.create_time))
            std::cout << "<____3____>" <<  std::endl;
            try
            {
                key_ = item.first;
                std::cout << "<____4____>" <<  std::endl;
                if(passed(Period::Second, 1.7, firstCall, currentClients.at(key_).create_time))
                {
                    std::cout << "<____5____>" <<  std::endl;
                //добавить данные в стек для очистки контейнера
                    try
                    {
    ///                    std::lock_guard<std::mutex> lk(m); //!!!<=
                        currentClients.at(key_).for_deleting = true;
                        q1.push(key_);
                    }
                    catch(...)
                    {
                        std::cout << "Excepton Concurrent Access by equal_range Writing" << std::endl;
                    }
                    std::cout << "<____6____>" <<  std::endl;
                }
                }
                catch(...)
                {
                    std::cout << "Excepton Concurrent Access by equal_range Reading" << std::endl;
                }

        }
        MySQLconnection connection;
        bool is_connected(false);
        if(!q1.empty())
        {
            is_connected = connection.MakeConnection(host, user, pass, db, 3306, NULL, 0);
        }
        if(is_connected)
        while(!q1.empty())
        {
            std::cout << "<____7____>" <<  std::endl;
            try
            {
                if(currentClients.at(q1.front()).for_deleting)
                {
                    std::cout << "<____8____>" <<  std::endl;
                    try
                    {
    //                    std::lock_guard<std::mutex> lk(m); //!!!<=
                        std::string key_user(currentClients.at(q1.front()).user_license_key);
                        int user_id = currentClients.at(q1.front()).user_id;
                        /*auto license_id = */
                        connection.Select(RELEASE, user_id, key_user.c_str());
                        currentClients.erase(q1.front());

                    }
                    catch(...)
                    {
                        std::cout << "Excepton Concurrent Access by key_ Reading" << std::endl;
                    }
                    std::cout << "<____9____>" <<  std::endl;
                }

            }
            catch(...)
            {
                std::cout << "Excepton Concurrent Access by key_ Reading" << std::endl;
            }
            std::cout << "<____10____>" <<  std::endl;
            q1.pop();
        }
        if(currentClients.empty())
        {
            isNotUse = true;
        }

    }
}


void client_session(socket_ptr sock)
{

	std::mt19937 gen(time(0));
    std::uniform_int_distribution<> uid(100000, INT_MAX);
    std::chrono::steady_clock clock;




//	string start_aes{"Encryption for start!!!"};

//	start_aes = Encrypt_aes(key, sizeof(key), iv, sizeof(iv), secret, start_aes);

//	cout << Decrypt_aes(key, sizeof(key), iv, sizeof(iv), secret, start_aes) << endl;

 try
 {
    // БУФЕР ДЛЯ ПРИЕМА ДАННЫХ
	char data[512];
	//! 1- ПОЛУЧАЕМ НОМЕР КЛЮЧА КЛИЕНТА
	size_t len = sock->read_some(buffer(data, 512)); //  , ip::socket_type::socket::message_out_of_band
	//	size_t len = sock->receive(buffer(data, 512));
	if (len > 0) //ВЫПОЛНЯЕМ ПРОВЕРКУ НА КОРРЕКТНЫЕ ДАННЫЕ
	{
		// переносим данные в string и далее работаем с этим типом
		std::string new_mess(data, len);
		// восстанавливаем удаленные нули если такие были
		new_mess = reziro(new_mess);

		// расшифровываем полученное сообщение
		new_mess = Decrypt_aes(key, sizeof(key), iv, sizeof(iv), secret, new_mess);
        // передаем всем на случай входящих комманд управления сервером
		mess_control = new_mess;
        // проверяем на выключение
		if (mess_control == "server_off")
		{



					write(*sock, buffer(EXIT.c_str(), EXIT.size()));


					/////////////////////////////////////
					io_service service;
					ip::tcp::endpoint ep(ip::address::from_string("127.0.0.1")/*ip::address_v6::any()*/, targetPoint.port_);
				//	ip::tcp::endpoint ep(ip::address::from_string("192.168.10.36")/*ip::address_v6::any()*/, targetPoint.port_);
					ip::tcp::socket sock_1(service);
					boost::system::error_code error;
					// снимаем поток ожидающий новых подключений
					sock_1.connect(ep, error);
					sock_1.close();
					return;
					/////////////////////////////////////
				}

		// предпологаем что получили ключ
		std::string user_key = new_mess;

		/// //////////////////////////////////////
		std::cout << new_mess << "  " << new_mess.size() << std::endl;

        // создаем соединение в базе данных
  //      MySQLconnection connection("localhost", "root", "7320842@Ok", "Alex_K_DB", 3306, NULL, 0);
        MySQLconnection connection(host, user, pass, db, 3306, NULL, 0);
		// ищем пользователя в базе данных по ключу
		int user_id = connection.FindUserByKey(new_mess.c_str());
		std::cout << "User ID = " << user_id << std::endl;
		// Контроль висящих неиспользуемых ключей
        if(isNotUse)
        {
            std:: cout << "<____A____>" << std::endl;
            try
            {
                std:: cout << "<____B____>" << std::endl;
 //* НЕРАБОЧИЙ ВАРИАНТ  */  auto futur = std::async(std::launch::async, release_unused_keys);

          /* РАБОЧИЙ ВАРИАНТ  */   std::thread t1(release_unused_keys);
         //       boost::thread(release_unused_keys);
                std:: cout << "<____C____>" << std::endl;
          /* РАБОЧИЙ ВАРИАНТ */      t1.detach();
            }
            catch (std::exception & ex)
            {
                std::cout << "Exception: " << ex.what() << "\n";
            }
            catch (...)
            {
                std::cout << " - We have en exception\n";
            }
        std:: cout << "<____D____>" << std::endl;
 //       isNotUse = false;
        }

        //Генерируем временный ID пользователя(клиента)
		int temp_uid = uid(gen);

		//Если клиента нет прерываем связь
		if(user_id == 0)
		{
            new_mess = std::string("KEY_ANSWER_UNKNOWN_KEY_REQUEST") + "&" + std::to_string(temp_uid);
            new_mess = Encrypt_aes(key, sizeof(key), iv, sizeof(iv), secret, new_mess);
            //! убираем нули
            new_mess = deziro(new_mess);
            //! отправляем сообщение
            write(*sock, buffer(new_mess.c_str(), new_mess.size()));
            sock->close();
            return; // отказ нужно доработать
		}
        //Создаем пользователя для хранения данных
		Client client;
		//Сохраняем ключ
		client.user_license_key = user_key;

        //блокируем доступ к контейнеру
        std::lock_guard<std::mutex> lk(m); //!!!<=
        //выполняем проверку на уникальность
		while(currentClients.count(temp_uid) > 0)
		{
            temp_uid = uid(gen);
		}
		// Переменная для сохранения ID лицензии
        int license_id(0);
        //Монтируем новое сообщение клиенту
        new_mess = std::string("KEY_ANSWER_GOOD") + "&" + std::to_string(temp_uid);

        std::cout << new_mess << "  " << new_mess.size() << std::endl;
       //Выполняем обмен данными
        new_mess = DataExchange(new_mess, sock);
       // Переменная типа запроса
        std::string query_type;
       // Пееременная для получения ID пользователя
        std::string user_id_str;;
        // Разбераем сообщение пользователя
        MessageParsing(new_mess, query_type,  user_id_str);

        cout << query_type << " " << query_type.size() << endl;
        cout << user_id_str << endl;
        //конвертируем полученные данные из string в int
        int client_uid = std::stoi(user_id_str.c_str());
        cout << client_uid << endl;

        bool ALL_RIGHT(false);
        //проверяем соответствие запроса и ID пользователя
        if(query_type == "REQUEST" && client_uid == user_id)
        {
            license_id = connection.Select(REQUEST, user_id, user_key.c_str());
            if(license_id != 0)
            {
                // Заполняем поля клиента
                client.user_id = client_uid;
                client.user_license_id = license_id;
                //монтируем новое положительное сообщение
                new_mess = std::string("LICENSE_ANSWER_GOOD") + "&" + std::to_string(temp_uid);
                //открываем путь для добавление пользователя в базу данных
                ALL_RIGHT = true;
                query_type = "CHECK";
            }
            else
            {
                //монтируем новое отрицательное сообщение
                new_mess = std::string("LICENSE_ANSWER_BUSY") + "&" + std::to_string(temp_uid);
            }
        }
        else if(query_type == "CHECK" && 1 == currentClients.count(client_uid))
        {
            try
            {
                if(currentClients.at(client_uid).user_license_key == client.user_license_key)
                {
                    license_id = connection.Select(CHECK, currentClients.at(client_uid).user_id,
                                currentClients.at(client_uid).user_license_key.c_str());
                    std::cout << "!!!!!!!!!!!!!!!!!! - " << client_uid << std::endl;

                    if(license_id == currentClients.at(client_uid).user_license_id
                    && false == currentClients.at(client_uid).for_deleting)
                    {

                        //монтируем новое положительное сообщение
                        new_mess = std::string("LICENSE_ANSWER_GOOD_WORK") + "&" + std::to_string(temp_uid);
                        ALL_RIGHT = true;
       ///                 std::lock_guard<std::mutex> lk(m);
                        client = currentClients.at(client_uid);
                        currentClients.erase(client_uid);
                    }
                    else
                    {
                        //монтируем новое отрицательное сообщение
                        new_mess = std::string("LICENSE_ANSWER_NOT_WORK") + "&" + std::to_string(temp_uid);
                    }
                }
                else
                {
                    //монтируем новое отрицательное сообщение
                        new_mess = std::string("LICENSE_ANSWER_KEY_NOT_WORK") + "&" + std::to_string(temp_uid);
                }
            }
            catch(...)
            {
                std::cout << "Exception in CHECK block" << std::endl;
            }
        }
        else if(query_type == "RELEASE" && 1 == currentClients.count(client_uid))
        {
            try
            {
            client = currentClients.at(client_uid);
            license_id = connection.Select(RELEASE, client.user_id, user_key.c_str());
            if(license_id == client.user_license_id)
            {
                //монтируем новое положительное сообщени
                new_mess = std::string("LICENSE_ANSWER_GOOD_RELEASE") + "&" + std::to_string(temp_uid);
                currentClients.erase(client_uid);
                ALL_RIGHT = false;
            }
            else
            {
                //монтируем новое отрицательное сообщение
                new_mess = std::string("LICENSE_ANSWER_NOT_RELEASE") + "&" + std::to_string(temp_uid);
            }
            }
            catch(...)
            {
                std::cout << "Exception in RELEASE block" << std::endl;
            }
        }
        else
        {
            //монтируем новое отрицательное сообщение
            new_mess = std::string("LICENSE_ANSWER_UNKNOWN_KLIENT_REQUEST") + "&" + std::to_string(temp_uid);
        }
        new_mess = Encrypt_aes(key, sizeof(key), iv, sizeof(iv), secret, new_mess);
        //! убираем нули
        new_mess = deziro(new_mess);
        //! отправляем сообщение
        write(*sock, buffer(new_mess.c_str(), new_mess.size()));

        // добавляем клиента в базу
        if(ALL_RIGHT)
        {
            try
            {
   ///         std::lock_guard<std::mutex> lk(m);
            currentClients.insert({temp_uid, client});
            currentClients.at(temp_uid).create_time = clock.now();
            }
            catch(...)
            {
                std::cout << "Exception at insertion a client" << std::endl;
            }
        }
    }

    sock->close();

    return;
 }
 catch (std::exception & ex)
 {
//    --Session_Number;
    std::cout << "Client was disconnected: " << ex.what() << "\n";
 }
}


void showIp()
{
	boost::system::error_code ec;
	std::string name = "3d-kstudio.com";//   boost::asio::ip::host_name(ec);
	if (ec)
	{
		std::cerr << "host_name() failed: \n" << ec.message();
		return;
	}
	else
		std::cout << "host name is " << name << std::endl;
	boost::asio::io_service io;

	boost::asio::ip::tcp::resolver r(io);

	boost::asio::ip::tcp::resolver::iterator it = r.resolve(boost::asio::ip::tcp::resolver::query(name, ""), ec),
		itEnd;
	if (ec)
	{
		std::cerr << "resolve() failed: \n" << ec.message();
		return;
	}
	for (; it != itEnd; ++it)
	{
		std::cout << it->endpoint().address().to_string() << std::endl;
	}

	return;
}


void show_content(std::string hello)
{
	for (auto ch : hello)
	{
		std::cout << " " << (int)ch << "=" << ch;
	}
}

int run_server(int port);

int main()
{
	int port(5050);

//	cout << "Inpun number of port: ";

//	cin >> port;

	if(becomeDaemon() == 0)
	{
        cout << "Start as demon" << endl;
	}
	else
	{
	    cout << "Start as console app" << endl;
	}

	run_server(port);

//	std::thread t_1(run_server, port);

//	t_1.detach();

    return 0;
}

//! https://habr.com/ru/company/xakep/blog/257895/
int run_server(int port)
{

	//Here is a simple synchronous server:using boost::asio;
 //   std::cout << (int)boost::asio::error::eof << std::endl;
	if (0 < boost::asio::error::eof)
	{
		std::cout << (int)boost::asio::error::eof << std::endl;
	}
	else
	{
		std::cout << "-" << (int)boost::asio::error::eof << std::endl;
	}



	targetPoint.SetPort(port);

	fileSaver(targetPoint, "target_point.txt");

	targetPoint = fileParser(targetPoint, "target_point.txt");

	std::cout << ip::host_name() << std::endl;
	io_service service;

	//ip::address_v4::any()
	//ip::tcp::endpoint ep(ip::tcp::v4(), 5050); // listen on 5050

	ip::tcp::endpoint ep;

	std::unique_ptr<ip::tcp::acceptor> acc;
//	ip::tcp::acceptor * acc(nullptr);

	bool new_port(true);
	do
	{
	try
	{
        ep = ip::tcp::endpoint(ip::address_v6::any(), targetPoint.port_); // listen on 5050
        acc = std::make_unique<ip::tcp::acceptor>(service, ep);
  //      acc = new ip::tcp::acceptor(service, ep);
        new_port = false;
	}
    catch (std::exception & ex)
    {
    /*
        if(acc)
        {
            delete acc;
            acc = nullptr;
        }
        */
        std::cout << "Exception++: " << ex.what() << " : ++" <<  "\n";
        if("bind: Address already in use" == std::string(ex.what()))
        {
            std::cout << "CHANGE PORT" << targetPoint.port_  << " to " << 1 + targetPoint.port_ << std::endl;
            ++targetPoint.port_;
        }
        else
        {
            std::cout << "NE PORT" << std::endl;
        }

    }
    }
    while(new_port);


	MySQLconnection connection(host, user, pass, db, 3306, NULL, 0);
	connection.NullStart();
	connection.~MySQLconnection();

	while ("server_off" != mess_control)
	{
		socket_ptr sock(new ip::tcp::socket(service));
		acc->accept(*sock);

		try
		{
			boost::thread(boost::bind(client_session, sock));

			if("server_off" != mess_control)
			{

                std::cout << "New Session Accept" << std::endl;

			}

		}
		catch (std::exception & ex)
		{
			std::cout << "Exception: " << ex.what() << "\n";
		}
		catch (...)
		{
			std::cout << " - Client Disconnect ++ \n";
		}

	}
	std::cout << mess_control << std::endl;

	return 0;
}



