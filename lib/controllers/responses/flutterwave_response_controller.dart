import 'dart:convert';

import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/flutterwave_models/flutterwave_response_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/requests_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/responses_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/transaction_response.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';

class FlutterWaveResponseController  extends ResourceController{
  @Operation.post()
  Future<Response> operation()async {
    final Map<String, dynamic> _body = await request.body.decode();
    final FlutterwaveResponseModel _flutterwaveResponseModel = FlutterwaveResponseModel(body: _body);
    final String _transactionId = await _flutterwaveResponseModel.save();

    final String _requestId = _body['txRef'].toString();
    final String _recieptNo = _body['flwRef'].toString();
    
    final ObjectId _id = ObjectId.parse(_body['txRef'].toString());
    final RequestsModel _requestModel = RequestsModel();
    final Map<String, dynamic> _data = await _requestModel.getById(_id);
    final String reference = _data['metadata']['reference'] == null ? null : _data['metadata']['reference'].toString();
    final String walletAccountNo = _data['metadata']['walletAccountNo'].toString();
    final String amount = _data['metadata']['amount'].toString();
    final String cardNo = _data['metadata']['cardNo'].toString();
    final String _url = _data['metadata']['callbackUrl'].toString();

    final ResponseObj _responseObj = ResponseObj('0', 'Successfully Completed');
    final TransactionResult _transactionResult = TransactionResult(
      resultStatus: 'Completed',
      reqRef: _requestId,
      transactionId: _transactionId,
      channel: 'CARD',
      paymentRef: reference != null ? reference : walletAccountNo,
      receiptRef: _recieptNo, 
      amount: amount.toString(),
      charges: '0',
      receiverParty: "CARD",
      senderAccount: cardNo,
      receiptNo: _recieptNo,
      completeDateTime: DateTime.now().toString(),
      currentBalance: null,
      availableBalance: null,
    );

    final TransactionResponse _transactionResponse = TransactionResponse(
      responseObj: _responseObj,
      transactionResult: _transactionResult
    );
    _transactionResponse.save();

    // Send to callback url
     try{
      // final dynamic _res = 
      await http.post(_url, body: json.encode(_transactionResponse.asMap()), headers: {'content-type': 'application/json',});

      final ResponsesModel _responsesModel = ResponsesModel(
        requestId: _requestId,
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
        requestId: _requestId,
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