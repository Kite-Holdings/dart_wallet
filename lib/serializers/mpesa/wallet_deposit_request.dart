
import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/c_b_deposit.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/settings.dart';

class WalletDepositRequestSerializer extends Serializable{
  String phoneNo;
  double amount;
  @override
  Map<String, dynamic> asMap() {
    // TODO: implement asMap
    return {
      "phoneNo": phoneNo,
      "amount": amount
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    phoneNo = object['phoneNo'].toString();
    amount = double.parse(object['amount'].toString());
  }
  Future<Map<String, dynamic>> sendRequest()async{
    await depositRequest(phoneNo: phoneNo.toString(), amount: amount.toString(), accRef: businessShortCode);

    return{
      "statusCode": 0,
      "message": "success"
    };
  }
  
}