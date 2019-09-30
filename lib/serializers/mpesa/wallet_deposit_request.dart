
import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/c_b_deposit.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/settings.dart';

class WalletDepositRequestSerializer extends Serializable{
  String phoneNo;
  String walletAccountNo;
  double amount;
  @override
  Map<String, dynamic> asMap() {
    return {
      "phoneNo": phoneNo,
      "walletAccountNo": walletAccountNo,
      "amount": amount
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    phoneNo = object['phoneNo'].toString();
    walletAccountNo = object['walletAccountNo'].toString();
    amount = double.parse(object['amount'].toString());
  }
  Future<Map<String, dynamic>> sendRequest()async{
    Map response = await depositRequest(phoneNo: phoneNo.toString(), amount: amount.toString(), accRef: walletAccountNo);

    return response;
  }
  
}
