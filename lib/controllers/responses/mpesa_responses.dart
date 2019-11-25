import 'dart:convert';

import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/mpesa%20models/mpesa_responses_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/responses_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/transaction_response.dart';
import 'package:e_pay_gateway/models.dart/transaction_model.dart';
import 'package:e_pay_gateway/models.dart/wallets/wallet_model.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';


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

  @Operation.post('requestId')
  Future<Response> stkCallback(@Bind.path("requestId") String requestId)async{
    final Map<String, dynamic> _body = await request.body.decode();

    final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'mpesaCallbackUrls');
    final Map<String, dynamic> _transactionMeta = await _databaseBridge.findOneBy(where.id(ObjectId.parse(requestId)));
    final String walletAccountNo = _transactionMeta['walletAccountNo'].toString();
    final String referenceNumber = _transactionMeta['referenceNumber'].toString();
    final String transactionDesc = _transactionMeta['transactionDesc'].toString();
    final String phoneNo = _transactionMeta['phoneNo'].toString();
    final double amount = double.parse(_transactionMeta['amount'].toString());
    final String _url = _transactionMeta['url'].toString();

    // Future data  TODO: 
    // final RequestsModel _requestsModel = RequestsModel();
    // final Map<String, dynamic> _transactionMeta = await _requestsModel.getById(ObjectId.parse(requestId));
    // final String walletAccountNo = _transactionMeta['metadata']['walletAccountNo'].toString();
    // final String referenceNumber = _transactionMeta['metadata']['referenceNumber'].toString();
    // final String transactionDesc = _transactionMeta['metadata']['transactionDesc'].toString();
    // final String phoneNo = _transactionMeta['metadata']['phoneNo'].toString();
    // final double amount = double.parse(_transactionMeta['metadata']['amount'].toString());
    // final String _url = _transactionMeta['metadata']['calbackUrl'].toString();


    _body['flag'] = "unprocessed";
    _body['type'] = "stkPush";
    _body['walletAccountNo'] = walletAccountNo;
    _body['referenceNumber'] = referenceNumber;
    _body['transactionDesc'] = transactionDesc;
    _body['amount'] = amount;

    String _transactionId;
    String _resultStatus;
    String _recieptNo;

    // ResultCode
    if(_body['Body'] != null && _body['Body']['stkCallback'] != null && _body['Body']['stkCallback']['ResultCode'] == 0){
      
      
      Map<String, dynamic> _head = {};
      // MerchantRequestID
      _head['MerchantRequestID'] = _body['Body']['stkCallback']['MerchantRequestID'];
      // CheckoutRequestID
      _head['CheckoutRequestID'] = _body['Body']['stkCallback']['CheckoutRequestID'];

      final _details = _body['Body']['stkCallback']['CallbackMetadata']['Item'];
      Map<String, dynamic> _item = {};
      for(int i = 0; i < int.parse(_details.length.toString()); i++){
        _item[_details[i]['Name'].toString()] = _details[i]['Value'];

        if(_details[i]['Name'].toString() == 'MpesaReceiptNumber'){
          _recieptNo = _details[i]['Value'].toString();
        }
      }

      _body['MpesaReceiptNumber'] = _item['MpesaReceiptNumber'];

      _body['Body'] = {
        "head": _head,
        "data": _item
      };
      
      _body['flag'] = "complete";

      final MpesaResponsesModel _mpesaResponsesModel = MpesaResponsesModel(body: _body);
      _transactionId = await _mpesaResponsesModel.save();
      // deposit to wallet
      final WalletModel _walletModel = WalletModel();
      final Map<String, dynamic> _recipientInfo = await _walletModel.debit(amount: amount, accountNo: walletAccountNo);
      _resultStatus = "Completed";
    }
    else{

      final MpesaResponsesModel _mpesaResponsesModel = MpesaResponsesModel(body: _body);
      _transactionId = await _mpesaResponsesModel.save();
      _resultStatus = "Failed";
    }

    
    // save transaction
    final TransactionModel _transactionModel = TransactionModel(
      senderInfo: _body,
      recipientInfo: null,
      companyCode: walletAccountNo.isNotEmpty ? walletAccountNo[0]+walletAccountNo[1]+walletAccountNo[2] : '000',
      amount: amount,
      cost: 0,
      totalAmount: amount,
      transactionType: TransactionType.mpesaToWallet,
      state: TransactionState.complete
    );

    await _transactionModel.save();

    // Save response
    final ResponseObj _responseObj = ResponseObj("0", "Successfully Completed");
    final TransactionResult _transactionResult = TransactionResult(
      resultStatus: _resultStatus,
      reqRef: requestId,
      transactionId: _transactionId.toString(),
      channel: 'Mpesa',
      paymentRef: referenceNumber != null ? referenceNumber : walletAccountNo,
      receiptRef: _recieptNo.toString(), 
      amount: amount.toString(),
      charges: '0',
      receiverParty: "Mpesa",
      senderAccount: phoneNo,
      receiptNo: _recieptNo.toString(),
      completeDateTime: DateTime.now().toString(),
      currentBalance: null,
      availableBalance: null,
    );
    final TransactionResponse _transactionResponse = TransactionResponse(responseObj: _responseObj, transactionResult: _transactionResult);
     _transactionResponse.save();

    // Send to callback url
     try{
      // final dynamic _res = 
      await http.post(_url, body: json.encode(_transactionResponse.asMap()), headers: {'content-type': 'application/json',});

      final ResponsesModel _responsesModel = ResponsesModel(
        requestId: requestId,
        responseType: ResposeType.callBack,
        responseBody: {
          'endpoint': _url,
          'status': 'success',
          'body': _transactionResponse.asMap()
        }
      );

      unawaited(_responsesModel.save());
     } catch (e){
       print(e);
       final ResponsesModel _responsesModel = ResponsesModel(
        requestId: requestId,
        responseType: ResposeType.callBack,
        responseBody: {
          'endpoint': _url,
          'status': 'failed',
          'body': e.toString()
        }
      );

      unawaited(_responsesModel.save());
     }
    

    return Response.ok({"message": "done"});
  }
}