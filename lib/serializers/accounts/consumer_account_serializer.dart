import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/wallet_serializer.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ConsumerAccountSerializer extends Serializable{
  String identifier;
  String identifierType;
  String username;
  String phoneNo;
  String email;
  String password;
  String accountType = "consumer";



  final Db db =  Db(databaseUrl);
  @override
  Map<String, dynamic> asMap() {
    return {
      "identifier": identifier,
      "identifierType": identifierType,
      "username": username,
      "phoneNo": phoneNo,
      "email": email,
      "password": password,
      "accountType": accountType,
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    identifier = object['identifier'].toString();
    identifierType = object['identifierType'].toString();
    username = object['username'].toString();
    phoneNo = object['phoneNo'].toString();
    email = object['email'].toString();
    password = object['password'].toString();
  }

  Future<Map<String, dynamic>> save()async{

    await db.open();
    final DbCollection accounts = db.collection('accounts');

    try{
      await accounts.insert({
        'identifier': identifier,
        'identifierType': identifierType,
        'accountType': accountType,
        'username': username,
        'address': {
          'phoneNo': phoneNo,
          'email': email,
        },
        'wallets': [],
      });
      final Map<String, dynamic> account = await accounts.findOne(where.eq('identifier', identifier));
      final _id = account['_id'];
      final String accountRef = '$databaseName + /accounts/ + ${_id.toString()}';
      final WalletSerializer walletSerializer = WalletSerializer();
      final Map<String, dynamic> newWallet = await walletSerializer.save(accountRefference: accountRef, accountType: '0', companyCode: '001');
      final String walletRef = newWallet['ref'].toString();

      await accounts.update(where.eq('_id', account['_id']), modify.push('wallets', walletRef));
      
      await db.close();


      return {
        'identifier': identifier,
        'username': username,
        'accountType': accountType,
        'address': {
          'phoneNo': phoneNo,
          'email': email,
        },
        'wallet': {
          'balance': newWallet['balance'],
          'walletAccountNo': newWallet['walletAccountNo']
        },
      };


    }catch (e){
      await db.close();
      if(e['code'] == 11000){
        return {'error': "account already exist"};
      }
      return {'error': "an error occured"};
    }
  }

  Future<List<Map<String, dynamic>>> getAll()async{
    await db.open();
    final List<Map<String, dynamic>> _accountsList = [];
    final DbCollection accounts = db.collection('accounts');
    final Stream<Map<String, dynamic>> _accountsStream = accounts.find();

    
    await _accountsStream.forEach(_accountsList.add);
    
    await db.close();
    return _accountsList;
  }

  Future<Map<String, dynamic>> findByIdentifier(String accountId)async{
    await db.open();
    final DbCollection accounts = db.collection('accounts');
    final Map<String, dynamic> account = await accounts.findOne(where.eq('identifier', accountId));

    await db.close();
    return account;
  }
}