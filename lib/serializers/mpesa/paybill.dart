import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/b_b_paybill.dart';

class MpesaPaybill extends Serializable{
  String businessNo;
  String accountNo;
  double amount;
  @override
  Map<String, dynamic> asMap() {
    return {
      "businessNo": businessNo,
      "accountNo": accountNo,
      "amount": amount
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    businessNo = object['businessNo'].toString();
    accountNo = object['accountNo'].toString();
    amount = double.parse(object['amount'].toString());
  }
  Future performTransaction()async{

    // TODO: Perform B2B check if success
    final response = await payBill(tillNo: businessNo, amount: amount.toString(), accRef: accountNo);
    

    // await db.close();
    return response;
  }

}
