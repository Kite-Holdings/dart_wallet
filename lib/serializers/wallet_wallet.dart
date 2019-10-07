import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/wallet_serializer.dart';
import 'package:e_pay_gateway/settings/settings.dart';

class WalletToWallet extends Serializable{
  String senderAccount;
  String recipientAccount;
  double amount;
  @override
  Map<String, dynamic> asMap() {
    
    return {
      "senderAccount": senderAccount,
      "recipientAccount": recipientAccount,
      "amount": amount
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    senderAccount = object['senderAccount'].toString();
    recipientAccount = object['recipientAccount'].toString();
    amount = double.parse(object['amount'].toString());
  }

  Future<Map<String, dynamic>> performTransaction()async{
    double transactionAmount (){
      return amount + amount * walletRate;
    }

    final WalletSerializer wallet = WalletSerializer();

    // credit sender
    await wallet.credit(accountNo: senderAccount, amount: transactionAmount());
    // debit recipient
    await wallet.debit(accountNo: recipientAccount, amount: amount);

    return{
      "statusCode": 0,
      "message": "success"
    };
  }
}