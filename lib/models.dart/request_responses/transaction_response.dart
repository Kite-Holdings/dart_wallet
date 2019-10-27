import 'package:e_pay_gateway/utils/database_bridge.dart';

class TransactionResponse{
  TransactionResponse({this.responseObj, this.transactionResult});
  final ResponseObj responseObj;
  final TransactionResult transactionResult;
  final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'transactionResponse');

  Map<String, Map<String, String>> asMap(){
    return{
      "response": responseObj.asMap(),
      "transactionResult": transactionResult.asMap(),
    };
  }
  void save()async{
    try{
      await _databaseBridge.save(asMap());
    } catch (e){
      
    }
  }

}

class ResponseObj{
  ResponseObj(this.responseCode, this.responseDesc);
  final String responseCode;
  final String responseDesc;

  Map<String, String> asMap(){
    return{
      "responseCode": responseCode,
      "responseDesc": responseDesc,
    };
  }
}

class TransactionResult{

  TransactionResult({
    this.resultStatus,
    this.reqRef,
    this.transactionId,
    this.channel,
    this.paymentRef,
    this.receiptRef,
    this.amount,
    this.charges,
    this.receiverParty,
    this.senderAccount,
    this.receiptNo,
    this.completeDateTime,
    this.currentBalance,
    this.availableBalance,
  });

  final String resultStatus;
  final String reqRef;
  final String resRef = ObjectId().toString().split('"')[1];
  final String transactionId;
  final String channel;
  final String paymentRef;
  final String receiptRef;
  final String amount;
  final String charges;
  final String receiverParty;
  final String senderAccount;
  final String receiptNo;
  final String completeDateTime;
  final String currentBalance;
  final String availableBalance;

  Map<String, String> asMap(){
    return{
      "resultStatus": resultStatus,
      "reqRef": reqRef,
      "resRef": resRef,
      "transactionId": transactionId,
      "channel": channel,
      "paymentRef": paymentRef,
      "receiptRef": receiptRef,
      "amount": amount,
      "charges": charges,
      "receiverParty": receiverParty,
      "senderAccount": senderAccount,
      "receiptNo": receiptNo,
      "completeDateTime": completeDateTime,
      "currentBalance": currentBalance,
      "availableBalance": availableBalance,
    };
  }
}



// {
//   "Response": {
//     "ResponseCode": "0",
//     "ResponseDesc": "Successfully Completed"
//   },
//   "TransactionResult": {
//     "ResultStatus": "Completed",*
//     "ReqRef": "1017C5LWVWJQWS",* request ref
//     "ResRef": "19284-9353732-1",* response ref
//     "TransactionId": "17004",* transaction id
//     "Channel": "MPESA",* medium
//     "PaymentRef": "19284-9353732-1",*
//     "ReceiptRef": "1020190000007470",*
//     "Amount": "10.0000",* amount
//     "Charges": "0",* cost
//     "ReceiverParty": "mpesa_paybill",* chanel
//     "ReceiverAccount": "810492",* chanel acc
//     "CustomerNo": "254721138458",
//     "CustomerName": "254721138458",
//     "ReceiverIsRegistered": "1",
//     "ReceiptNo": "NJ743YCOO2",* 
//     "CompleteDateTime": "20191007184857",* datetime
//     "CurrentBalance": null,
//     "AvailableBalance": null,
//     "PostedBy": null,
//     "AuthorizedBy": null,
//     "RawResponse": null,
//     "ExtraData": {*
//       "RawResponse": null,
//       "RawRequest": null
//     }
//   }
// }