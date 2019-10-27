import 'dart:convert';

import 'package:e_pay_gateway/models.dart/request_responses/transaction_response.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';
import 'package:http/http.dart' as http;

class WalletWalletCallbackController{

  WalletWalletCallbackController({
    this.senderAccount,
    this.recipientAccount,
    this.amount,
    this.cost,
    this.requestId,
    this.transactionId,
    this.callbackUrl,
    this.statusCode,
    this.statusDescription
  });

  final String senderAccount;
  final String recipientAccount;
  String reciepitNo;
  final String callbackUrl;
  final double amount;
  final double cost;
  final String requestId;
  String transactionId;
  String statusCode;
  String statusDescription;
  ResponseObj _responseObj;
  TransactionResult _transactionResult;

  void sendCallBack()async{
    String _resultStatus;
    if(statusCode == '0'){
      _resultStatus = "Completed";
    }
    else{
      _resultStatus = "Failed";
    }

    final ObjectId _resObId = ObjectId();
    reciepitNo = _resObId.toString().split('"')[1];


    _responseObj = ResponseObj(statusCode, statusDescription);
    _transactionResult = TransactionResult(
      resultStatus: _resultStatus,
      reqRef: requestId,
      transactionId: transactionId,
      channel: 'KitePay',
      paymentRef: recipientAccount,
      receiptRef: reciepitNo.toString(), 
      amount: amount.toString(),
      charges: cost.toString(),
      receiverParty: "KitePay",
      senderAccount: senderAccount,
      receiptNo: reciepitNo.toString(),
      completeDateTime: DateTime.now().toString(),
      currentBalance: null,
      availableBalance: null,
    );

    final TransactionResponse _transactionResponse = TransactionResponse(responseObj: _responseObj, transactionResult: _transactionResult);
    _transactionResponse.save();
    // Send to callback url
     try{
       await http.post(callbackUrl, body: json.encode(_transactionResponse.asMap()));
     } catch (e){
       print(e);
     }
  }
}