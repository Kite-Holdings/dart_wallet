import 'dart:convert';

import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/mpesa%20models/mpesa_responses_model.dart';
import 'package:e_pay_gateway/models.dart/transaction_model.dart';
import 'package:e_pay_gateway/models.dart/wallets/wallet_model.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';
import 'package:http/http.dart' as http;


class MpesaStkCallbackController extends ResourceController{
  @Operation.post()
  Future<Response> defaultStkCallback()async{
    final Map<String, dynamic> _body = await request.body.decode();
    _body['flag'] = "unprocessed";
    _body['type'] = "stkPush";

    final MpesaResponsesModel _mpesaResponsesModel = MpesaResponsesModel(body: _body);
    _mpesaResponsesModel.save();

    return Response.ok({"message": "done"});
  }

  @Operation.post('transactionId')
  Future<Response> stkCallback(@Bind.path("transactionId") String transactionId)async{
    final Map<String, dynamic> _body = await request.body.decode();
    final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'mpesaCallbackUrls');
    final Map<String, dynamic> _transactionMeta = await _databaseBridge.findOneBy(where.id(ObjectId.parse(transactionId)));
    final String walletAccountNo = _transactionMeta['body'][0]['walletAccountNo'].toString();
    final String referenceNumber = _transactionMeta['body'][0]['referenceNumber'].toString();
    final String transactionDesc = _transactionMeta['body'][0]['transactionDesc'].toString();
    final double amount = double.parse(_transactionMeta['body'][0]['amount'].toString());
    final String _url = _transactionMeta['body'][0]['url'].toString();
    _body['flag'] = "unprocessed";
    _body['type'] = "stkPush";
    _body['walletAccountNo'] = walletAccountNo;
    _body['referenceNumber'] = referenceNumber;
    _body['transactionDesc'] = transactionDesc;
    _body['amount'] = amount;

    // ResultCode
    if(_body['Body']['stkCallback']['ResultCode'] == 0){
      Map<String, dynamic> _head = {};
      // MerchantRequestID
      _head['MerchantRequestID'] = _body['Body']['stkCallback']['MerchantRequestID'];
      // CheckoutRequestID
      _head['CheckoutRequestID'] = _body['Body']['stkCallback']['CheckoutRequestID'];

      final _details = _body['Body']['stkCallback']['CallbackMetadata']['Item'];
      Map<String, dynamic> _item = {};
      for(int i = 0; i < int.parse(_details.length.toString()); i++){
        _item[_details[i]['Name'].toString()] = _details[i]['Value'];
      }

      _body['MpesaReceiptNumber'] = _item['MpesaReceiptNumber'];

      _body['Body'] = {
        "head": _head,
        "data": _item
      };
      
      _body['flag'] = "complete";

      final MpesaResponsesModel _mpesaResponsesModel = MpesaResponsesModel(body: _body);
      _mpesaResponsesModel.save();
    }
    else{

      final MpesaResponsesModel _mpesaResponsesModel = MpesaResponsesModel(body: _body);
      _mpesaResponsesModel.save();
    }

    // deposit to wallet
    final WalletModel _walletModel = WalletModel();
    final Map<String, dynamic> _recipientInfo = await _walletModel.debit(amount: amount, accountNo: walletAccountNo);
    // save transaction
    final TransactionModel _transactionModel = TransactionModel(
      senderInfo: _body,
      recipientInfo: _recipientInfo,
      companyCode: walletAccountNo.isNotEmpty ? walletAccountNo[0]+walletAccountNo[1]+walletAccountNo[2] : '000',
      amount: amount,
      cost: 0,
      totalAmount: amount,
      transactionType: TransactionType.mpesaToWallet,
      state: TransactionState.complete
    );

    await _transactionModel.save();

    // Send to callback url
     try{
       await http.post(_url, body: json.encode(_body));
     } catch (e){
       print(e);
     }
    
    return Response.ok({"message": "done"});
  }
}
