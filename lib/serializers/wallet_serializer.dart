import 'package:e_pay_gateway/controllers/utils/counter_intrement.dart';
import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/utils.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class WalletSerializer extends Serializable{
  String accountRef;
  double balance;
  String walletAccountNo;


  static Db db =  Db(databaseUrl);
  final DbCollection wallets = db.collection('wallets');

  @override
  Map<String, dynamic> asMap() {
    return {
      "accountRef": accountRef,
      "balance": balance,
      "walletAccountNo": walletAccountNo,
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    accountRef = object['accountRef'].toString();
    balance = double.parse(object['balance'].toString());
    walletAccountNo = object['walletAccountNo'].toString();
  }


  /// This functions create and saves a new Virtual Wallet
  /// It takes three arguments, user refference company code and account type(0 for consumer, 1 for Merchant)
  /// It returns a details of the created virtual wallet
  Future<Map<String, dynamic>> save({String companyCode, String accountType,String accountRefference})async{
    int c = await companyCounter ('wallet_account');
    walletAccountNo = stringifyCount(c);
    walletAccountNo = companyCode + accountType + walletAccountNo;
    accountRef = accountRefference;
    balance = 0;
    await db.open();

    await wallets.insert({
      'balance': balance,
      'accountRef': accountRef,
      'walletAccountNo': walletAccountNo
    });
    Map<String, dynamic> wallet = await wallets.findOne(where.eq('walletAccountNo', walletAccountNo));
    await db.close();
    String wallet_ref = databaseName + '/wallets/' + wallet['_id'].toString() ;
    wallet['ref'] = wallet_ref;
    return wallet;
  }

  // TODO: create a fuction to check if wallet exist

  /// This function decrements wallet ballance by some amount
  /// It takes two arguments, the wallet account number(walletAccountNo) and amount (amount)
  /// It returns a Map of status with balance
  /// If the transaction failed the status is "failed", else "success"
  Future<Map<String, dynamic>> credit({String accountNo, double amount})async{
    await db.open();

    // TODO: Verify if sender wallet got enough cash
    // If so subract amount from acc
    final Map<String, dynamic> _info =await wallets.findAndModify(
      query: where.eq("walletAccountNo", accountNo),
      update: {"\$inc":{'balance': -amount}},
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
  /// It takes two arguments, the wallet account number(walletAccountNo) and amount (amount)
  /// It returns a Map of status with balance
  /// If the transaction failed the status is "failed", else "success"
  Future<Map<String, dynamic>> debit({String accountNo, double amount})async{

    await db.open();

    // TODO: Verify if sender wallet got enough cash
    // If so subract amount from acc
    final Map<String, dynamic> _info =await wallets.findAndModify(
      query: where.eq("walletAccountNo", accountNo),
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