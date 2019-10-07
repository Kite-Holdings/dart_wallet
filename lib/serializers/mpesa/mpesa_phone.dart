import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/b_c_phone_no.dart';

class MpesaToPhoneNo extends Serializable{
  String phoneNo;
  double amount;
  @override
  Map<String, dynamic> asMap() {
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
  Future performTransaction()async{
    // TODO: Perform B2C
    final response = await bPhoneNo(phoneNo: phoneNo, amount: amount.toString());
    

    // await db.close();
    return response;
  }

}
