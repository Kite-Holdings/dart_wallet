import 'dart:convert';

import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/mpesa%20models/mpesa_responses_model.dart';
import 'package:e_pay_gateway/models.dart/mpesa%20models/stk_process_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/requests_model.dart';
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
    unawaited(_mpesaResponsesModel.save());

    return Response.ok({"message": "done"});
  }

  @Operation.post('requestId')
  Future<Response> stkCallback(@Bind.path("requestId") String requestId)async{
    final Map<String, dynamic> _body = await request.body.decode();

    // final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'mpesaCallbackUrls');
    // final Map<String, dynamic> _transactionMeta = await _databaseBridge.findOneBy(where.id(ObjectId.parse(requestId)));
    // final String walletAccountNo = _transactionMeta['walletAccountNo'].toString();
    // final String referenceNumber = _transactionMeta['referenceNumber'].toString();
    // final String transactionDesc = _transactionMeta['transactionDesc'].toString();
    // final String phoneNo = _transactionMeta['phoneNo'].toString();
    // final double amount = double.parse(_transactionMeta['amount'].toString());
    // final String _url = _transactionMeta['url'].toString();

    String _recieptNo;

    bool _success = false;

    // ResultCode
    if(_body['Body'] != null && _body['Body']['stkCallback'] != null && _body['Body']['stkCallback']['ResultCode'] == 0){
      _success = true;
      
      
      final Map<String, dynamic> _head = {};
      // MerchantRequestID
      _head['MerchantRequestID'] = _body['Body']['stkCallback']['MerchantRequestID'];
      // CheckoutRequestID
      _head['CheckoutRequestID'] = _body['Body']['stkCallback']['CheckoutRequestID'];

      final _details = _body['Body']['stkCallback']['CallbackMetadata']['Item'];
      final Map<String, dynamic> _item = {};
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


    }
    else{
      _success = false;

    }

    processMpesaResponse(success: _success, body: _body, requestId: requestId, recieptNo: _recieptNo);

    

    return Response.ok({"message": "done"});
  }
}


void processMpesaResponse({bool success, Map<String, dynamic> body, String requestId, String recieptNo})async{
  String transactionId;

  final RequestsModel _requestsModel = RequestsModel();


  final Map<String, dynamic> _transactionMeta = await _requestsModel.getById(ObjectId.parse(requestId));
  String walletAccountNo;
  String referenceNumber;
  String transactionDesc;
  String phoneNo;
  double amount;
  String _url;
  try{
  walletAccountNo = _transactionMeta['metadata']['walletAccountNo'].toString();
  referenceNumber = _transactionMeta['metadata']['referenceNumber'].toString();
  transactionDesc = _transactionMeta['metadata']['transactionDesc'].toString();
  phoneNo = _transactionMeta['metadata']['phoneNo'].toString();
  amount = double.parse(_transactionMeta['metadata']['amount'].toString());
  _url = _transactionMeta['metadata']['callbackUrl'].toString();
  } catch (e){
    walletAccountNo = _transactionMeta['walletAccountNo'].toString();
    referenceNumber = _transactionMeta['referenceNumber'].toString();
    transactionDesc = _transactionMeta['transactionDesc'].toString();
    phoneNo = _transactionMeta['phoneNo'].toString();
    amount = double.parse(_transactionMeta['amount'].toString());
    _url = _transactionMeta['url'].toString();
  }

  body['walletAccountNo'] = walletAccountNo;
  body['referenceNumber'] = referenceNumber;
  body['transactionDesc'] = transactionDesc;
  body['amount'] = amount;

  if(success){

    final MpesaResponsesModel _mpesaResponsesModel = MpesaResponsesModel(body: body);
    transactionId = await _mpesaResponsesModel.save();
    // deposit to wallet
    final WalletModel _walletModel = WalletModel();
    final Map<String, dynamic> _recipientInfo = await _walletModel.debit(amount: amount, accountNo: walletAccountNo);

    // Update stkProcess
    final StkProcessModel _stkProcessModel = StkProcessModel(requestId: requestId, processState: ProcessState.complete);
    _stkProcessModel.updateProcessStateByRequestId();


  } else{
    if(body != null){
      final MpesaResponsesModel _mpesaResponsesModel = MpesaResponsesModel(body: body);
      transactionId = await _mpesaResponsesModel.save();
    }

    // Update stkProcess
    final StkProcessModel _stkProcessModel = StkProcessModel(requestId: requestId, processState: ProcessState.failed);
    _stkProcessModel.updateProcessStateByRequestId();
  }

   // save transaction
  final TransactionModel _transactionModel = TransactionModel(
    senderInfo: body,
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
  final ResponseObj _responseObj = ResponseObj(success ? "0" : "1", success ? "Successfully Completed": "Failed");
  final TransactionResult _transactionResult = TransactionResult(
    resultStatus: success ? 'Completed' : 'Failed',
    reqRef: requestId,
    transactionId: transactionId.toString(),
    channel: 'Mpesa',
    paymentRef: referenceNumber != null ? referenceNumber : walletAccountNo,
    receiptRef: recieptNo.toString(), 
    amount: success ? amount.toString() : null,
    charges: '0',
    receiverParty: "Mpesa",
    senderAccount: phoneNo,
    receiptNo: recieptNo.toString(),
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
    rethrow;
    }

}