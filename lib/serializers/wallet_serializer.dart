import 'package:e_pay_gateway/controllers/utils/counter_intrement.dart';
import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/utils.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class WalletSerializer extends Serializable{
  String user_ref;
  double balance;
  String wallet_account_no;


  static Db db =  Db(databaseUrl);
  final DbCollection wallets = db.collection('wallets');

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


  /// This functions create and saves a new Virtual Wallet
  /// It takes two arguments, user refference and wallet account number
  /// It returns a details of the created virtual wallet
  // TODO:  accept wallet no
  Future<Map<String, dynamic>> save(String userRef)async{
    int c = await companyCounter ('wallet_account');
    wallet_account_no = stringifyCount(c);
    wallet_account_no = companyCode + wallet_account_no;
    user_ref = userRef;
    balance = 0;
    await db.open();

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

  // TODO: create a fuction to check if wallet exist

  /// This function decrements wallet ballance by some amount
  /// It takes two arguments, the wallet account number(wallet_account_no) and amount (amount)
  /// It returns a Map of status with balance
  /// If the transaction failed the status is "failed", else "success"
  Future<Map<String, dynamic>> credit({String accountNo, double amount})async{
    await db.open();

    // TODO: Verify if sender wallet got enough cash
    // If so subract amount from acc
    final Map<String, dynamic> _info =await wallets.findAndModify(
      query: where.eq("wallet_account_no", accountNo),
      update: {"\$dec":{'balance': amount}},
      returnNew: true
    );
    await db.close();
    
    // TODO: Check if succeeded
    return {
      "status": "success",
      "balance": double.parse(_info['balance'].toString())
    };
  }



  /// This function increments wallet ballance by some amount
  /// It takes two arguments, the wallet account number(wallet_account_no) and amount (amount)
  /// It returns a Map of status with balance
  /// If the transaction failed the status is "failed", else "success"
  Future<Map<String, dynamic>> debit({String accountNo, double amount})async{

    await db.open();

    // TODO: Verify if sender wallet got enough cash
    // If so subract amount from acc
    final Map<String, dynamic> _info =await wallets.findAndModify(
      query: where.eq("wallet_account_no", accountNo),
      update: {"\$inc":{'balance':amount}},
      returnNew: true
    );
    await db.close();
    
     // TODO: Check if succeeded
    return {
      "status": "success",
      "balance": double.parse(_info['balance'].toString())
    };
  }



}