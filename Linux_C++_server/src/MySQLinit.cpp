#include "MySQLinit.h"

#include <iostream>
#include <sstream>
#include <my_global.h>
#include <stdlib.h>

using namespace std;


const char* REQUEST("RequestKey_UserId_Key (");

const char* CHECK("ActiveKeyCheck_UserId_kEY (");

const char* RELEASE("ReleaseKey_UserId_Key (");

MySQLinit::MySQLinit()
{
    cout << "MySQLinit Konstructor counter = " << m_counter << endl;

    if(mysql_library_init(0, NULL, NULL))
    {
        cout << "ERROR OF mysql_library_init FUNCTION" << endl;
        Clear();
    }//ctor
}

MySQLinit::~MySQLinit()
{
    cout << "MySQLinit Destructor counter = " << m_counter << endl;

    mysql_library_end();
}

MySQLinit & MySQLinit::instance()
{
    ++m_counter;
    static MySQLinit m_MySQL;
    cout << " MySQLinit Instance counter = " << m_counter << endl;
    return  m_MySQL;
}

void MySQLinit::Clear()
{
    --m_counter;
    cout << "MySQLinit Clear counter = " << m_counter << endl;
    if(m_counter <= 0)
    {
        this->~MySQLinit();
    }
}

int MySQLinit::counter()
{
    return m_counter;
}


int MySQLinit::m_counter = 0;

/////////////////////////////////////////////////////////////////////////
//! class connection
/////////////////////////////////////////////////////////////////////////

    MySQLconnection::MySQLconnection():
    m_init(MySQLinit::instance())
    {

    }

    MySQLconnection::MySQLconnection(const char* host, const char* user, const char* passwd,
    const char* db, unsigned int port = 3306, const char* unix_socket = NULL, unsigned long clientflag = 0):
    m_init(MySQLinit::instance())
    {
        m_connection = mysql_init(m_mysql);
        m_connection = mysql_real_connect(m_connection, host, user, passwd, db, port, unix_socket, clientflag);
        if(!m_connection)
        {
            cout << " is NOT connected" << endl;
            cout << mysql_error(m_mysql) << endl; //  http://www.quizful.net/post/C++&MySQL
    //        this->~MySQLconnection();
            return;
        }

        cout << " is connected" << endl;
        isConnected = true;
    }

    MySQLconnection::~MySQLconnection()
    {
        BreakConnection();
        m_init.Clear();
    }

    bool MySQLconnection::MakeConnection(const char* host, const char* user, const char* passwd,
    const char* db, unsigned int port = 3306, const char* unix_socket = NULL, unsigned long clientflag = 0)
    {
        if(isConnected == false)
        {
            m_connection = mysql_init(nullptr);
            m_connection = mysql_real_connect(m_connection, host, user, passwd, db, port, unix_socket, clientflag);
            isConnected = m_connection != nullptr;
            if(isConnected)
            cout << " is connected" << endl;
            else
            cout << " is NOT connected" << endl;
        }
        else
        {
            cout << "connection exist" << endl;
        }

        return isConnected;
    }

    void MySQLconnection::BreakConnection()
    {
        if(isConnected || m_connection)
        {
            if(m_connection)
            {
                mysql_close(m_connection);
                cout << " connection closed " << endl;
            }
            else
            {
                cout << " connection NOT exist " << endl;
            }
            isConnected = false;
            m_connection = nullptr;
        }
    }


    bool MySQLconnection::KeyExist(const char* key)
    {
        const char * query_start("select count(*) from key_s where key_license_key = '");
        const char * query_end("';");

        MYSQL_RES *result(nullptr);
        MYSQL_ROW row;
        int query_state;

        stringstream ss;

        ss << query_start << key << query_end;
        string query = ss.str();
        ss.clear();
        query_state = mysql_query(m_connection, query.c_str());

          if (query_state)
          {
            std::cout << mysql_error(m_connection) << std::endl;
            mysql_free_result(result);
            return false;
          }
          else
          {
            result = mysql_store_result(m_connection);
            if(( row = mysql_fetch_row(result)) != nullptr)
            {

                bool key_exist(0 < atoi(row[0]));

                std::cout << "Number ID of user : " << key_exist << std::endl;
                mysql_free_result(result);
                return key_exist;
            }
          }


        mysql_free_result(result);
        return false;
    }


    int MySQLconnection::FindUserByKey(const char* key)
    {
        if(KeyExist(key) == false)
        return 0;

        const char * query_start("select user_id from user inner join key_s on key_s.key_user_id = user.user_id where key_s.key_license_key = '");
        const char * query_end("';");


        MYSQL_RES *result(nullptr);
        MYSQL_ROW row;
        int query_state;

        stringstream ss;

        ss << query_start << key << query_end;
        string query = ss.str();
        ss.clear();
        query_state = mysql_query(m_connection, query.c_str());

          if (query_state)
          {
            std::cout << mysql_error(m_connection) << std::endl;
            return 0;
          }
          else
          {
            result = mysql_store_result(m_connection);
            if(( row = mysql_fetch_row(result)) != nullptr)
            {

                int user_id(atoi(row[0]));

                std::cout << "Number ID of user : " << user_id << std::endl;
                return user_id;
            }
          }


        mysql_free_result(result);
        return 0;
    }

    //! select count(*) from key_s where key_user_id = 2;

        int MySQLconnection::CountUserIDentry(int user_id)
    {
        const char * query_start("select count(*) from key_s where key_user_id = '");
        const char * query_end("';");

        MYSQL_RES *result;
        MYSQL_ROW row;
        int query_state;

        stringstream ss;

        ss << query_start << user_id << query_end;
        string query = ss.str();
        ss.clear();
        query_state = mysql_query(m_connection, query.c_str());

          if (query_state)
          {
            std::cout << mysql_error(m_connection) << std::endl;
            return 0;
          }
          else
          {
            result = mysql_store_result(m_connection);
            if(( row = mysql_fetch_row(result)) != nullptr)
            {

                int user_id(atoi(row[0]));

                std::cout << "Numbers ID entry : " << user_id << std::endl;
                return user_id;
            }
          }


        mysql_free_result(result);
        return 0;
    }

    void MySQLconnection::StartTransaction()
    {
        auto query_state = mysql_query(m_connection, "START TRANSACTION;");
        if(query_state)
        {
            std::cout << "StartTransaction ERROR = " << mysql_error(m_connection) << std::endl;
        }
    }

    void MySQLconnection::CommitTransaction()
    {
        auto query_state = mysql_query(m_connection, "COMMIT;");
        if(query_state)
        {
            std::cout << "CommitTransaction ERROR = " << mysql_error(m_connection) << std::endl;
        }
    }

    void MySQLconnection::RollbackTransaction()
    {
        auto query_state = mysql_query(m_connection, "ROLLBACK;");
        if(query_state)
        {
            std::cout << "RollbackTransaction ERROR = " << mysql_error(m_connection) << std::endl;
        }
    }


//!  select RequestKey_UserId_Key(514365948, 'bc5eaa148c12cad1815b5ede6d3f9');
//! int RequestKey_UserId_Key (p_UserId int(11), p_kEY varchar(128))
//! int ActiveKeyCheck_UserId_kEY (p_UserId int(11), p_kEY varchar(128))
//! select ActiveKeyCheck_UserId_kEY(514365948, 'bc5eaa148c12cad1815e83094008295c47f0756907eec09e66412f93853c3593368994db24646c97e4123507d4dfa4787a7e91338f0791d8b3587eb5ede6d3f9');
//! int ReleaseKey_UserId_Key (p_UserId int(11), p_kEY varchar(128))
//! mysql> select ReleaseKey_UserId_Key (514365948, 'bc5eaa148c12cad18ede6d3f9');

   int MySQLconnection::Select( const char * query_definition, int UserId, const char * Key)
 {
    const char * query_start("select ");
        const char * query_middle(", '");
        const char * query_end("');");

        MYSQL_RES *result(nullptr);
        MYSQL_ROW row;
        int query_state;

        stringstream ss;
        int license_id(0);

        ss << query_start << query_definition << UserId << query_middle << Key << query_end;
        string query = ss.str();
        ss.clear();
        cout << query << endl;
        query_state = mysql_query(m_connection, query.c_str());

          if (query_state)
          {
            std::cout << mysql_error(m_connection) << std::endl;
          }
          else
          {
            result = mysql_store_result(m_connection);
            if(( row = mysql_fetch_row(result)) != nullptr)
            {

                license_id = atoi(row[0]);

                std::cout << query_definition << "License ID : " << license_id << std::endl;

            }
          }


        mysql_free_result(result);

    return license_id;
 }


 bool MySQLconnection::NullStart()
 {
    string query{"UPDATE key_s SET key_requested = 0 WHERE key_requested = 1;"};
    int query_state = mysql_query(m_connection, query.c_str());

    if (query_state)
    {
        std::cout << mysql_error(m_connection) << std::endl;
        return false;
    }
    else
    {
        return true;
    }
    return false;
 }
