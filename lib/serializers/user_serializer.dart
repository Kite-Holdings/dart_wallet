import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/wallet_serializer.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UserSerializer extends Serializable{
  String identifier;
  String identifierType;
  String username;
  String phoneNo;
  String email;
  String password;



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
    final DbCollection users = db.collection('users');

    try{
      await users.insert({
        'identifier': identifier,
        'identifierType': identifierType,
        'username': username,
        'address': {
          'phoneNo': phoneNo,
          'email': email,
        },
        'wallets': [],
      });
      final Map<String, dynamic> user = await users.findOne(where.eq('identifier', identifier));
      final _id = user['_id'];
      final String userRef = '$databaseName + /users/ + ${_id.toString()}';
      final WalletSerializer walletSerializer = WalletSerializer();
      final Map<String, dynamic> newWallet = await walletSerializer.save(userRef);
      final String walletRef = newWallet['ref'].toString();

      await users.update(where.eq('_id', user['_id']), modify.push('wallets', walletRef));
      
      await db.close();


      return {
        'identifier': identifier,
        'username': username,
        'address': {
          'phoneNo': phoneNo,
          'email': email,
        },
        'wallet': {
          'balance': newWallet['balance'],
          'wallet_account_no': newWallet['wallet_account_no']
        },
      };


    }catch (e){
      await db.close();
      if(e['code'] == 11000){
        return {'error': "user already exist"};
      }
      return {'error': "an error occured"};
    }
  }

  Future<List<Map<String, dynamic>>> getAll()async{
    await db.open();
    final List<Map<String, dynamic>> _usersList = [];
    final DbCollection users = db.collection('users');
    final Stream<Map<String, dynamic>> _usersStream = users.find();

    
    await _usersStream.forEach(_usersList.add);
    
    await db.close();
    return _usersList;
  }

  Future<Map<String, dynamic>> findByIdentifier(String userId)async{
    await db.open();
    final DbCollection users = db.collection('users');
    final Map<String, dynamic> user = await users.findOne(where.eq('identifier', userId));

    await db.close();
    return user;
  }
}