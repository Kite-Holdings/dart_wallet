import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/mpesa/rates.dart';
import 'package:e_pay_gateway/serializers/wallet_serializer.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/b_c_phone_no.dart';

class WalletToPhoneNo extends Serializable{
  String senderAccount;
  String phoneNo;
  double amount;
  @override
  Map<String, dynamic> asMap() {
    return {
      "senderAcount": senderAccount,
      "phoneNo": phoneNo,
      "amount": amount
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    senderAccount = object['senderAccount'].toString();
    phoneNo = object['phoneNo'].toString();
    amount = double.parse(object['amount'].toString());
  }
  Future performTransaction()async{
    double transactionAmount (){
      return amount + mpesaToPhoneRate() + amount *thirdPatyRate;
    }

    final WalletSerializer wallet = WalletSerializer();

    // credit sender
    await wallet.credit(accountNo: senderAccount, amount: transactionAmount());


    // TODO: Perform B2C
    var response = await bPhoneNo(phoneNo: phoneNo, amount: amount.toString());
    
    return response;
  }

}
