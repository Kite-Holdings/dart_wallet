import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class WalletToWallet extends Serializable{
  String sender_account;
  String recipient_account;
  double amount;
  @override
  Map<String, dynamic> asMap() {
    
    return {
      "sender_account": sender_account,
      "recipient_account": recipient_account,
      "": amount
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    sender_account = object['sender_account'].toString();
    recipient_account = object['recipient_account'].toString();
    amount = double.parse(object['amount'].toString());
  }

  Future<Map<String, dynamic>> performTransaction()async{
    double transactionAmount (){
      return amount + amount * walletRate;
    }
    final Db db =  Db(databaseUrl);

    await db.open();
    final DbCollection wallets = db.collection('wallets');

    // TODO: Verify if sender wallet got enough cash
    // If so subract amount from acc
    await wallets.findAndModify(
      query: where.eq("wallet_account_no", sender_account),
      update: {"\$dec":{'wallet_account_no':transactionAmount()}},
    );

    // Then increment recipent acc
    await wallets.findAndModify(
      query: where.eq("wallet_account_no", sender_account),
      update: {"\$inc":{'wallet_account_no':amount}},
    );

    await db.close();
    return{
      "statusCode": 0,
      "message": "success"
    };
  }
}