
import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/c_b_deposit.dart';

class MpesaDepositRequestSerializer extends Serializable{
  String phoneNo;
  String walletAccountNo;
  double amount;
  String callBackUrl;
  String referenceNumber;
  String transactionDesc;
  @override
  Map<String, dynamic> asMap() {
    return {
      "phoneNo": phoneNo,
      "walletAccountNo": walletAccountNo,
      "amount": amount,
      "callBackUrl": callBackUrl,
      "referenceNumber": referenceNumber,
      "transactionDesc": transactionDesc,
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    phoneNo = object['phoneNo'].toString();
    walletAccountNo = object['walletAccountNo'].toString();
    referenceNumber = object['referenceNumber'].toString();
    transactionDesc = object['transactionDesc'].toString();
    callBackUrl = object['callBackUrl'].toString();
    amount = double.parse(object['amount'].toString());
  }
  Future sendRequest()async{
    final response = await depositRequest(
      phoneNo: phoneNo.toString(), 
      amount: amount.toString(), 
      accRef: walletAccountNo, 
      callBackUrl: callBackUrl,
      referenceNumber: referenceNumber,
      transactionDesc: transactionDesc,
      );

    return response;
  }
  
}
