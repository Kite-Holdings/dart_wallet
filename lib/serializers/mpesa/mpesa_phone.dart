import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/b_c_phone_no.dart';

class MpesaToPhoneNo extends Serializable{
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
    /* double transactionAmount (){
      return amount + mpesaToPhoneRate() + amount *thirdPatyRate;
    }

    final Db db =  Db(databaseUrl);

    await db.open();
    final DbCollection wallets = db.collection('wallets');

    // TODO: Verify if sender wallet got enough cash
    // If so subract amount from acc
    await wallets.findAndModify(
      query: where.eq("wallet_account_no", senderAccount),
      update: {"\$dec":{'wallet_account_no':transactionAmount()}},
    );
*/
    // TODO: Perform B2C
    final response = await bPhoneNo(phoneNo: phoneNo, amount: amount.toString());
    

    // await db.close();
    return response;
  }

}
