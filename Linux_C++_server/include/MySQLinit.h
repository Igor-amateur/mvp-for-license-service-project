#ifndef MYSQLINIT_H
#define MYSQLINIT_H
#include <mysql.h>



extern const char* REQUEST;

extern const char* CHECK;

extern  const char* RELEASE;



class MySQLinit
{
    public:

    static MySQLinit & instance();

    void Clear();

    // Конструктор копирования
    MySQLinit ( MySQLinit const &) = delete;
    // Конструктор перемещения
    MySQLinit ( MySQLinit &&) = delete;

    // Оператор присваивания копированием,
    MySQLinit & operator =( MySQLinit const &) = delete;
    // Оператор присваивания перемещением
    MySQLinit & operator =( MySQLinit &&) = delete;

    int counter();

    private:

    MySQLinit();
    ~MySQLinit();

    private:

    static int m_counter;
};

class MySQLconnection
{
    public:
    MySQLconnection();
    MySQLconnection(const char*, const char*, const char*, const char*, unsigned int, const char*, unsigned long);
    ~MySQLconnection();
    bool MakeConnection(const char*, const char*, const char*, const char*, unsigned int, const char*, unsigned long);
    void BreakConnection();
    int FindUserByKey(const char*);
    int CountUserIDentry(int);
    int Select(const char*, int, const char*);
    bool NullStart();
    bool KeyExist(const char* key);

    void StartTransaction();
    void CommitTransaction();
    void RollbackTransaction();

    private:
    private:
    MySQLinit& m_init;
    MYSQL* m_connection = nullptr;
    MYSQL* m_mysql = nullptr;
    bool isConnected = false;
};

#endif // MYSQLINIT_H
