import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/wallet_serializer.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UserSerializer extends Serializable{
  String identifier;
  String identifier_type;
  String username;
  String phone_no;
  String email;
  String password;



  final Db db =  Db(databaseUrl);
  @override
  Map<String, dynamic> asMap() {
    return {
      "identifier": identifier,
      "identifier_type": identifier_type,
      "username": username,
      "phone_no": phone_no,
      "email": email,
      "password": password,
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    identifier = object['identifier'].toString();
    identifier_type = object['identifier_type'].toString();
    username = object['username'].toString();
    phone_no = object['phone_no'].toString();
    email = object['email'].toString();
    password = object['password'].toString();
  }

  Future<Map<String, dynamic>> save()async{

    await db.open();
    final DbCollection users = db.collection('users');

    try{
      await users.insert({
        'identifier': identifier,
        'identifier_type': identifier_type,
        'username': username,
        'address': {
          'phone_no': phone_no,
          'email': email,
        },
        'wallets': [],
      });
      Map<String, dynamic> user = await users.findOne(where.eq('identifier', identifier));
      var _id = user['_id'];
      String user_ref = databaseName + '/users/' + _id.toString();
      WalletSerializer walletSerializer = WalletSerializer();
      Map<String, dynamic> new_wallet = await walletSerializer.save(user_ref);
      String wallet_ref = new_wallet['ref'].toString();

      await users.update(where.eq('_id', user['_id']), modify.push('wallets', wallet_ref));
      
      await db.close();


      return {
        'identifier': identifier,
        'username': username,
        'address': {
          'phone_no': phone_no,
          'email': email,
        },
        'wallet': {
          'balance': new_wallet['balance'],
          'wallet_account_no': new_wallet['wallet_account_no']
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
    List<Map<String, dynamic>> _usersList = [];
    final DbCollection users = db.collection('users');
    Stream<Map<String, dynamic>> _usersStream = users.find();

    
    await _usersStream.forEach((item){
      _usersList.add(item);
    });
    await db.close();
    return _usersList;
  }

  Future<Map<String, dynamic>> findByIdentifier(String userId)async{
    await db.open();
    final DbCollection users = db.collection('users');
    Map<String, dynamic> user = await users.findOne(where.eq('identifier', userId));

    await db.close();
    return user;
  }
}