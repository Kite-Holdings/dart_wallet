import 'package:e_pay_gateway/controllers/utils/counter_intrement.dart';
import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class WalletSerializer extends Serializable{
  String user_ref;
  double balance;
  String wallet_account_no;

  @override
  Map<String, dynamic> asMap() {
    return {
      "user_ref": user_ref,
      "balance": balance,
      "wallet_account_no": wallet_account_no,
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    user_ref = object['user_ref'].toString();
    balance = double.parse(object['balance'].toString());
    wallet_account_no = object['wallet_account_no'].toString();
  }

  Future<Map<String, dynamic>> save(String userRef)async{
    int c = await companyCounter ('wallet_account');
    wallet_account_no = stringifyCount(c);
    wallet_account_no = companyCode + wallet_account_no;

    user_ref = userRef;
    balance = 0;

    final Db db =  Db(databaseUrl);

    await db.open();

    final DbCollection wallets = db.collection('wallets');


    await wallets.insert({
      'balance': balance,
      'user_ref': user_ref,
      'wallet_account_no': wallet_account_no
    });
    Map<String, dynamic> wallet = await wallets.findOne(where.eq('wallet_account_no', wallet_account_no));
    await db.close();
    
    
    String wallet_ref = databaseName + '/wallets/' + wallet['_id'].toString() ;
    wallet['ref'] = wallet_ref;

    return wallet;
  }
  String stringifyCount(int count){
    String c = count.toString();
    for(int i = c.length; i< 9; i++){
      c = '0' + c;
    }
    return c;
  }

}