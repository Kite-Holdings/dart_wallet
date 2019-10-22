import 'package:e_pay_gateway/e_pay_gateway.dart';
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



}