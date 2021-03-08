

#include"cryptpp_aes.h"
#include<queue>
#include<limits.h>

using std::queue;

const int TAG_SIZE = 16;



// Encrypted, with Tag
   //! Зашифровано, с тегом



   // Recovered
   //! Восстановлено
 //  string radata, rpdata;

 //  string cipher, encoded;


string deziro(const string& str)
{
	const char ZERO('\0');
	string result(str);
	queue<int> index;


	for (int i = 0; i < static_cast<int>(result.size()); ++i)
	{
		if (ZERO == result[i])
		{
			result[i] = 'A';
			if (i == SCHAR_MAX)
				index.push(i);
			else
				index.push(i - SCHAR_MAX);
		}
	}

	while (!index.empty())
	{
		result.push_back(index.front());
		index.pop();
	}
	return result;
}

string reziro(const string& str)
{
	string result(str);
	queue<int> index;
	while (result.size() > 144)
	{
		index.push(result.back());
		if (index.back() != SCHAR_MAX)
		{
			index.back() = index.back() + SCHAR_MAX;
		}

		result.pop_back();
	}

	while (!index.empty())
	{
		if ('A' == result[index.front()])
		{
			result[index.front()] = '\0';
		}
		index.pop();
	}
	return result;
}

/*********************************\
\*********************************/

string Encrypt_aes(const byte* key, size_t size_key, const byte* iv, size_t size_iv, string adat, string pdat)
{

	string cipher, encoded;

	string adata(128, (char)0x00);

	string pdata(128, (char)0x00);

	for (size_t i = 0; adat.size() > i&& adata.size() > i; ++i)
	{
		adata[i] = adat[i];
	}

	for (size_t i = 0; pdat.size() > i&& pdata.size() > i; ++i)
	{
		pdata[i] = pdat[i];
	}

	try
	{
		GCM< AES >::Decryption d;
		d.SetKeyWithIV(key, size_key, iv, size_iv);

		GCM< AES >::Encryption e;
		e.SetKeyWithIV(key, size_key, iv, size_iv);

		AuthenticatedEncryptionFilter ef(e,
			new StringSink(cipher), false, TAG_SIZE
		); // AuthenticatedEncryptionFilter

		// AuthenticatedEncryptionFilter::ChannelPut
		//  defines two channels: "" (empty) and "AAD"
		//   channel "" is encrypted and authenticated
		//   channel "AAD" is authenticated

		ef.ChannelPut("AAD", (const byte*)adata.data(), adata.size());
		ef.ChannelMessageEnd("AAD");

		// Authenticated data *must* be pushed before
		//  Confidential/Authenticated data. Otherwise
		//  we must catch the BadState exception
		ef.ChannelPut("", (const byte*)pdata.data(), pdata.size());
		ef.ChannelMessageEnd("");

		// Pretty print
		//! Вполне печатно
		StringSource(cipher, true, new HexEncoder(new StringSink(encoded), true, TAG_SIZE, " "));

		return cipher;
	}
	catch (CryptoPP::BufferedTransformation::NoChannelSupport & e)
	{
		// The tag must go in to the default channel:
		//  "unknown: this object doesn't support multiple channels"
		//! Тег должен войти в канал по умолчанию:

		cerr << "Caught NoChannelSupport..." << endl;
		cerr << e.what() << endl;
		cerr << endl;
	}
	catch (CryptoPP::AuthenticatedSymmetricCipher::BadState & e)
	{
		// Pushing PDATA before ADATA results in:
		//  "GMC/AES: Update was called before State_IVSet"
		//! Нажатие DATA до того, как DATA приводит к:
		//! "GMC / AES: обновление было вызвано до State_IVSet"
		cerr << "Caught BadState..." << endl;
		cerr << e.what() << endl;
		cerr << endl;
	}
	catch (CryptoPP::InvalidArgument & e)
	{
		cerr << "Caught InvalidArgument..." << endl;
		cerr << e.what() << endl;
		cerr << endl;
	}
	return {};
}


string Encrypt_aes(CryptoPP::AuthenticatedSymmetricCipher& e, string adat, string pdat)
{

	string cipher, encoded;

	string adata(128, (char)0x00);

	string pdata(128, (char)0x00);

	for (size_t i = 0; adat.size() > i&& adata.size() > i; ++i)
	{
		adata[i] = adat[i];
	}

	for (size_t i = 0; pdat.size() > i&& pdata.size() > i; ++i)
	{
		pdata[i] = pdat[i];
	}

	try
	{

		AuthenticatedEncryptionFilter ef(e,
			new StringSink(cipher), false, TAG_SIZE
		); // AuthenticatedEncryptionFilter

		// AuthenticatedEncryptionFilter::ChannelPut
		//  defines two channels: "" (empty) and "AAD"
		//   channel "" is encrypted and authenticated
		//   channel "AAD" is authenticated

		ef.ChannelPut("AAD", (const byte*)adata.data(), adata.size());
		ef.ChannelMessageEnd("AAD");

		// Authenticated data *must* be pushed before
		//  Confidential/Authenticated data. Otherwise
		//  we must catch the BadState exception
		ef.ChannelPut("", (const byte*)pdata.data(), pdata.size());
		ef.ChannelMessageEnd("");

		// Pretty print
		//! Вполне печатно
		StringSource(cipher, true, new HexEncoder(new StringSink(encoded), true, TAG_SIZE, " "));

		return cipher;
	}
	catch (CryptoPP::BufferedTransformation::NoChannelSupport & e)
	{
		// The tag must go in to the default channel:
		//  "unknown: this object doesn't support multiple channels"
		//! Тег должен войти в канал по умолчанию:

		cerr << "Caught NoChannelSupport..." << endl;
		cerr << e.what() << endl;
		cerr << endl;
	}
	catch (CryptoPP::AuthenticatedSymmetricCipher::BadState & e)
	{
		// Pushing PDATA before ADATA results in:
		//  "GMC/AES: Update was called before State_IVSet"
		//! Нажатие DATA до того, как DATA приводит к:
		//! "GMC / AES: обновление было вызвано до State_IVSet"
		cerr << "Caught BadState..." << endl;
		cerr << e.what() << endl;
		cerr << endl;
	}
	catch (CryptoPP::InvalidArgument & e)
	{
		cerr << "Caught InvalidArgument..." << endl;
		cerr << e.what() << endl;
		cerr << endl;
	}
	return {};
}


/*********************************\
\*********************************/

// Attack the first and last byte
//! Атакуем первый и последний байт
//if( cipher.size() > 1 )
//{
//  cipher[ 0 ] |= 0x0F;
//  cipher[ cipher.size()-1 ] |= 0x0F;
//}

/*********************************\
\*********************************/


string Decrypt_aes(const byte* key, size_t size_key, const byte* iv, size_t size_iv, string adat, string cipher)
{

	string radata, rpdata;

	string adata(128, (char)0x00);
	//  string adat = "Hello World!";
	for (size_t i = 0; adat.size() > i&& adata.size() > i; ++i)
	{
		adata[i] = adat[i];
	}



	try
	{
		GCM< AES >::Decryption d;
		d.SetKeyWithIV(key, size_key, iv, size_iv);

		// Break the cipher text out into it's
		//  components: Encrypted Data and MAC Value
		//! разбить зашифрованный текст на

		string enc = cipher.substr(0, cipher.length() - TAG_SIZE);
		string mac = cipher.substr(cipher.length() - TAG_SIZE);

		// Sanity checks
		//! Проверка работоспособности
		assert(cipher.size() == enc.size() + mac.size());
		//        assert( enc.size() == pdata.size() );
		assert(TAG_SIZE == mac.size());

		// Not recovered - sent via clear channel
		//! Не восстановлено - отправлено по чистому каналу
		radata = adata;

		// Object will not throw an exception
		//  during decryption\verification _if_
		//  verification fails.
		//AuthenticatedDecryptionFilter df( d, NULL,
		// AuthenticatedDecryptionFilter::MAC_AT_BEGIN );


		AuthenticatedDecryptionFilter df(d, NULL,
			AuthenticatedDecryptionFilter::MAC_AT_BEGIN |
			AuthenticatedDecryptionFilter::THROW_EXCEPTION, TAG_SIZE);
		//  cout << "VVV =" << adata << endl;
		  // The order of the following calls are important
		  //! Порядок следующих вызовов важен
		df.ChannelPut("", (const byte*)mac.data(), mac.size());
		df.ChannelPut("AAD", (const byte*)adata.data(), adata.size());
		df.ChannelPut("", (const byte*)enc.data(), enc.size());

		// If the object throws, it will most likely occur
		//  during ChannelMessageEnd()
		//! Если объект выбрасывает, скорее всего, это произойдет
		df.ChannelMessageEnd("AAD");
		df.ChannelMessageEnd("");

		// If the object does not throw, here's the only
		//  opportunity to check the data's integrity
		//! Если объект не выбрасывает, вот единственный
		bool b = false;
		b = df.GetLastResult();
		assert(true == b);

		// Remove data from channel
		//! Удалить данные из канала
		string retrieved;
		size_t n = (size_t)-1;

		// Plain text recovered from enc.data()
		//! Простой текст восстановлен из enc.data ()
		df.SetRetrievalChannel("");
		n = (size_t)df.MaxRetrievable();
		retrieved.resize(n);

		if (n > 0) { df.Get((byte*)retrieved.data(), n); }
		rpdata = retrieved;
		//        assert( rpdata == pdata );

				// Hmmm... No way to get the calculated MAC
				//! Хммм ... Нет способа получить рассчитанный MAC
				//  mac out of the Decryptor/Verifier. At
				//  least it is purported to be good.
				//! mac вне Decryptor / Verifier. В
				//df.SetRetrievalChannel( "AAD" );
				//n = (size_t)df.MaxRetrievable();
				//retrieved.resize( n );

				//if( n > 0 ) { df.Get( (byte*)retrieved.data(), n ); }
				//assert( retrieved == mac );

				// All is well - work with data
				//! Все хорошо - работа с данными

		return rpdata.c_str();
	}
	catch (CryptoPP::InvalidArgument & e)
	{
		cerr << "Caught InvalidArgument..." << endl;
		cerr << e.what() << endl;
		cerr << endl;
	}
	catch (CryptoPP::AuthenticatedSymmetricCipher::BadState & e)
	{
		// Pushing PDATA before ADATA results in:
		//  "GMC/AES: Update was called before State_IVSet"
		//! Нажатие DATA до того, как DATA приводит к:
		//! "GMC / AES: обновление было вызвано до State_IVSet"
		cerr << "Caught BadState..." << endl;
		cerr << e.what() << endl;
		cerr << endl;
	}
	catch (CryptoPP::HashVerificationFilter::HashVerificationFailed & e)
	{
		cerr << "Caught HashVerificationFailed..." << endl;
		cerr << e.what() << endl;
		cerr << endl;
	}

	/*********************************\
	\*********************************/
	return {};
}

string Decrypt_aes(CryptoPP::AuthenticatedSymmetricCipher& d, string adat, string cipher)
{

	string radata, rpdata;

	string adata(128, (char)0x00);
	//  string adat = "Hello World!";
	for (size_t i = 0; adat.size() > i&& adata.size() > i; ++i)
	{
		adata[i] = adat[i];
	}



	try
	{
		//GCM< AES >::Decryption d;
		//d.SetKeyWithIV(key, size_key, iv, size_iv);

		// Break the cipher text out into it's
		//  components: Encrypted Data and MAC Value
		//! разбить зашифрованный текст на

		string enc = cipher.substr(0, cipher.length() - TAG_SIZE);
		string mac = cipher.substr(cipher.length() - TAG_SIZE);

		// Sanity checks
		//! Проверка работоспособности
		assert(cipher.size() == enc.size() + mac.size());
		//        assert( enc.size() == pdata.size() );
		assert(TAG_SIZE == mac.size());

		// Not recovered - sent via clear channel
		//! Не восстановлено - отправлено по чистому каналу
		radata = adata;

		// Object will not throw an exception
		//  during decryption\verification _if_
		//  verification fails.
		//AuthenticatedDecryptionFilter df( d, NULL,
		// AuthenticatedDecryptionFilter::MAC_AT_BEGIN );


		AuthenticatedDecryptionFilter df(d, NULL,
			AuthenticatedDecryptionFilter::MAC_AT_BEGIN |
			AuthenticatedDecryptionFilter::THROW_EXCEPTION, TAG_SIZE);
		//  cout << "VVV =" << adata << endl;
		  // The order of the following calls are important
		  //! Порядок следующих вызовов важен
		df.ChannelPut("", (const byte*)mac.data(), mac.size());
		df.ChannelPut("AAD", (const byte*)adata.data(), adata.size());
		df.ChannelPut("", (const byte*)enc.data(), enc.size());

		// If the object throws, it will most likely occur
		//  during ChannelMessageEnd()
		//! Если объект выбрасывает, скорее всего, это произойдет
		df.ChannelMessageEnd("AAD");
		df.ChannelMessageEnd("");

		// If the object does not throw, here's the only
		//  opportunity to check the data's integrity
		//! Если объект не выбрасывает, вот единственный
		bool b = false;
		b = df.GetLastResult();
		assert(true == b);

		// Remove data from channel
		//! Удалить данные из канала
		string retrieved;
		size_t n = (size_t)-1;

		// Plain text recovered from enc.data()
		//! Простой текст восстановлен из enc.data ()
		df.SetRetrievalChannel("");
		n = (size_t)df.MaxRetrievable();
		retrieved.resize(n);

		if (n > 0) { df.Get((byte*)retrieved.data(), n); }
		rpdata = retrieved;
		//        assert( rpdata == pdata );

				// Hmmm... No way to get the calculated MAC
				//! Хммм ... Нет способа получить рассчитанный MAC
				//  mac out of the Decryptor/Verifier. At
				//  least it is purported to be good.
				//! mac вне Decryptor / Verifier. В
				//df.SetRetrievalChannel( "AAD" );
				//n = (size_t)df.MaxRetrievable();
				//retrieved.resize( n );

				//if( n > 0 ) { df.Get( (byte*)retrieved.data(), n ); }
				//assert( retrieved == mac );

				// All is well - work with data
				//! Все хорошо - работа с данными

		return rpdata.c_str();
	}
	catch (CryptoPP::InvalidArgument & e)
	{
		cerr << "Caught InvalidArgument..." << endl;
		cerr << e.what() << endl;
		cerr << endl;
	}
	catch (CryptoPP::AuthenticatedSymmetricCipher::BadState & e)
	{
		// Pushing PDATA before ADATA results in:
		//  "GMC/AES: Update was called before State_IVSet"
		//! Нажатие DATA до того, как DATA приводит к:
		//! "GMC / AES: обновление было вызвано до State_IVSet"
		cerr << "Caught BadState..." << endl;
		cerr << e.what() << endl;
		cerr << endl;
	}
	catch (CryptoPP::HashVerificationFilter::HashVerificationFailed & e)
	{
		cerr << "Caught HashVerificationFailed..." << endl;
		cerr << e.what() << endl;
		cerr << endl;
	}

	/*********************************\
	\*********************************/
	return {};
}
