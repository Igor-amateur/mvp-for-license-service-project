#ifndef CRYPTPP_AES_H_INCLUDED
#define CRYPTPP_AES_H_INCLUDED

#include <iostream>
using std::cin;
using std::wcin;
using std::cout;
using std::wcout;
using std::cerr;
using std::wcerr;
using std::endl;


#include <string>
using std::string;
using std::wstring;

#include <utility>
using std::pair;
using std::make_pair;

#include <iomanip>
#include <modes.h>

#include <hex.h>
using CryptoPP::HexEncoder;
using CryptoPP::HexDecoder;

#include <cryptlib.h>
using CryptoPP::BufferedTransformation;
using CryptoPP::AuthenticatedSymmetricCipher;

#include <filters.h>
using CryptoPP::StringSink;
using CryptoPP::StringSource;
using CryptoPP::AuthenticatedEncryptionFilter;
using CryptoPP::AuthenticatedDecryptionFilter;

#include <aes.h>
using CryptoPP::AES;

#include <gcm.h>
using CryptoPP::GCM;
using CryptoPP::GCM_TablesOption;

#include <assert.h>

#ifdef UNICODE
#  define tcin wcin
#  define tcout wcout
#  define tcerr wcerr
#  define tstring wstring
#else
#  define tcin cin
#  define tcout cout
#  define tcerr cerr
#  define tstring string
#endif

typedef unsigned char byte;

string deziro(const string& str);
string reziro(const string& str);

string Encrypt_aes(const byte* key, size_t size_key, const byte* iv, size_t size_iv, string secret, string plaintext);
string Encrypt_aes(CryptoPP::AuthenticatedSymmetricCipher& e, string adat, string pdat);
string Decrypt_aes(const byte* key, size_t size_key, const byte* iv, size_t size_iv, string secret, string cipher);
string Decrypt_aes(CryptoPP::AuthenticatedSymmetricCipher& d, string adat, string cipher);



#endif // CRYPTPP_AES_H_INCLUDED
