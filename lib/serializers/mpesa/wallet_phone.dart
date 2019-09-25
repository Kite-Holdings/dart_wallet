import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/mpesa/rates.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class WalletToPhoneNo extends Serializable{
  String sender_account;
  String phone_no;
  double amount;
  @override
  Map<String, dynamic> asMap() {
    return {
      "sender_acount": sender_account,
      "phone_no": phone_no,
      "amount": amount
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    sender_account = object['sender_account'].toString();
    phone_no = object['phone_no'].toString();
    amount = double.parse(object['amount'].toString());
  }
  Future<Map<String, dynamic>> performTransaction()async{
    double transactionAmount (){
      return amount + mpesaToPhoneRate() + amount *thirdPatyRate;
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

    // TODO: Perform B2C
    

    await db.close();
    return{
      "statusCode": 0,
      "message": "success"
    };
  }

}