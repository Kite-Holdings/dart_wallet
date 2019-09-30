import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/mpesa/rates.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/b_b_buy_goods_services.dart';
import 'package:mongo_dart/mongo_dart.dart';

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
  Future<Map<String, dynamic>> performTransaction()async{
    double transactionAmount (){
      return amount + mpesaToBuyGoodsServicesRate() + amount *thirdPatyRate;
    }

    /* final Db db =  Db(databaseUrl);

    await db.open();
    final DbCollection wallets = db.collection('wallets');

    // TODO: Verify if sender wallet got enough cash
    // If so subract amount from acc
    await wallets.findAndModify(
      query: where.eq("wallet_account_no", senderAccount),
      update: {"\$dec":{'wallet_account_no':transactionAmount()}},
    );
*/

    // TODO: Perform B2B check if success
    Map response = await buyGoodsServices(tillNo: businessNo, amount: amount.toString());
    

    // await db.close();
    return response;
  }

}
