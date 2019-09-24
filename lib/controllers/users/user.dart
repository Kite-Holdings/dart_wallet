import 'package:e_pay_gateway/controllers/wallets/wallet.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class User {
  Future<Map<String, dynamic>> create({String identifier, String identifier_type, String username, String phone_no, String email})async{
    final Db db =  Db(databaseUrl);

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
      Wallet wallet = Wallet();
      Map<String, dynamic> new_wallet = await wallet.create(user_ref);
      String wallet_ref = new_wallet['ref'].toString();

      await users.update(where.eq('_id', user['_id']), modify.push('wallets', wallet_ref));


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
      if(e['code'] == 11000){
        return {'error': "user already exist"};
      }
      return {'error': "an error occured"};
    }


  }
}