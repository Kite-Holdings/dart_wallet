// import 'package:e_pay_gateway/e_pay_gateway.dart';
// import 'package:e_pay_gateway/serializers/mpesa/rates.dart';
// import 'package:e_pay_gateway/settings/settings.dart';
// import 'package:e_pay_gateway/third_party_operations/mpesa/b_b_paybill.dart';
// import 'package:mongo_dart/mongo_dart.dart';

// class WalletToPaybill extends Serializable{
//   String senderAccount;
//   String businessNo;
//   String accountNo;
//   double amount;
//   @override
//   Map<String, dynamic> asMap() {
//     return {
//       "senderAcount": senderAccount,
//       "businessNo": businessNo,
//       "accountNo": accountNo,
//       "amount": amount
//     };
//   }

//   @override
//   void readFromMap(Map<String, dynamic> object) {
//     senderAccount = object['senderAccount'].toString();
//     businessNo = object['businessNo'].toString();
//     accountNo = object['accountNo'].toString();
//     amount = double.parse(object['amount'].toString());
//   }
//   Future performTransaction()async{
//     double transactionAmount (){
//       return amount + mpesaToPaybillRate() + amount *thirdPatyRate;
//     }

//     final Db db =  Db(databaseUrl);

//     await db.open();
//     final DbCollection wallets = db.collection('wallets');

//     // TODO: Verify if sender wallet got enough cash
//     // If so subract amount from acc
//     await wallets.findAndModify(
//       query: where.eq("wallet_account_no", senderAccount),
//       update: {"\$dec":{'wallet_account_no':transactionAmount()}},
//     );

//     // TODO: Perform B2B check if success
//     var response = await payBill(tillNo: businessNo, amount: amount.toString(), accRef: accountNo);
    

//     // await db.close();
//     return response;
//   }

// }
