import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/mpesa/rates.dart';
import 'package:e_pay_gateway/serializers/wallet_serializer.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/b_b_buy_goods_services.dart';

class WalletToBuyGoodsServices extends Serializable{
  String senderAccount;
  String businessNo;
  double amount;
  @override
  Map<String, dynamic> asMap() {
    return {
      "senderAcount": senderAccount,
      "businessNo": businessNo,
      "amount": amount
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    senderAccount = object['senderAccount'].toString();
    businessNo = object['businessNo'].toString();
    amount = double.parse(object['amount'].toString());
  }
  Future performTransaction()async{
    double transactionAmount (){
      return amount + mpesaToBuyGoodsServicesRate() + amount *thirdPatyRate;
    }

    final WalletSerializer wallet = WalletSerializer();

    // credit sender
    await wallet.credit(accountNo: senderAccount, amount: transactionAmount());

    // TODO: Perform B2B check if success
    var response = await buyGoodsServices(tillNo: businessNo, amount: amount.toString());
    
    return response;
  }

}
