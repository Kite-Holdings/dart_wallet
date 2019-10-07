import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/b_b_buy_goods_services.dart';

class MpesaBuyGoodsServices extends Serializable{
  String businessNo;
  double amount;
  @override
  Map<String, dynamic> asMap() {
    return {
      "businessNo": businessNo,
      "amount": amount
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    businessNo = object['businessNo'].toString();
    amount = double.parse(object['amount'].toString());
  }
  Future performTransaction()async{

    // TODO: Perform B2B check if success
    final response = await buyGoodsServices(tillNo: businessNo, amount: amount.toString());
    

    // await db.close();
    return response;
  }

}
