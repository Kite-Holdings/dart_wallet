import 'dart:convert';

import 'package:e_pay_gateway/models.dart/utils/strigify_count.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/fetch_mpesa_token.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/settings.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';
import 'package:http/http.dart' as http;

Future depositRequest({
  String phoneNo, 
  String amount, 
  String accRef, 
  String callBackUrl,
  String referenceNumber,
  String transactionDesc,
  })async{


  final String accessToken =await fetchMpesaToken();

  var now = DateTime.now();
  String dt = now.year.toString() + stringifyCount(now.month, 2) + stringifyCount(now.day, 2) + stringifyCount(now.hour, 2) + stringifyCount(now.minute, 2) + stringifyCount(now.second, 2);
  var str = businessShortCode + passkey + dt;
  
  var bytes = utf8.encode(str);
  var _password = base64.encode(bytes);

  DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'mpesaCallbackUrls');
  ObjectId _objId = ObjectId();
  String _objIdStr = _objId.toString().split('"')[1];
  await _databaseBridge.save(
    {
      "_id": _objId,
      "url": callBackUrl,
      "walletAccountNo": accRef,
      "referenceNumber": referenceNumber,
      "transactionDesc": transactionDesc,
      "amount": amount,
    }
  );

  final Map<String, dynamic> payload = {
    "BusinessShortCode": businessShortCode,
    "Password": _password,
    "Timestamp": dt,
    "TransactionType": "CustomerPayBillOnline",
    "Amount": double.parse(amount),
    "PartyA": phoneNo,
    "PartyB": businessShortCode,
    "PhoneNumber": phoneNo,
    "CallBackURL": '${callBackURL}/cb/$_objIdStr',
    "AccountReference": referenceNumber != null ? referenceNumber : accRef,
    "TransactionDesc": transactionDesc
};

  final Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ' + accessToken
  };

  final String url = c2bURL;

  final http.Response r = await http.post(url, headers: headers, body: json.encode(payload));

  return json.decode(r.body);

}
