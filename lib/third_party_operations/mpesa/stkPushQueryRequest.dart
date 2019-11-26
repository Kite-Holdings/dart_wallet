import 'dart:convert';

import 'package:e_pay_gateway/third_party_operations/mpesa/fetch_mpesa_token.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/settings.dart';
import 'package:e_pay_gateway/models.dart/utils/strigify_count.dart';
import 'package:http/http.dart' as http;


class StkPushQueryRequest{

  StkPushQueryRequest({this.checkoutRequestID});

  final String checkoutRequestID;

  String _businessShortCode;
  String _password;
  String _timestamp;

  Future<Map<String, dynamic>> process() async{    
    final String accessToken =await fetchMpesaToken();
    final now = DateTime.now();
    final String _dt = now.year.toString() + stringifyCount(now.month, 2) + stringifyCount(now.day, 2) + stringifyCount(now.hour, 2) + stringifyCount(now.minute, 2) + stringifyCount(now.second, 2);
    final str = businessShortCode + passkey + _dt;
    final bytes = utf8.encode(str);

    _password = base64.encode(bytes);
    _timestamp = _dt;
    _businessShortCode = businessShortCode;

    final Map<String, String> _payload = {
      "BusinessShortCode": _businessShortCode,
      "Password": _password,
      "Timestamp": _timestamp,
      "CheckoutRequestID": checkoutRequestID
    };

    final Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    final String url = stkPushQueryRequestUrl;
    
    Map<String, dynamic> _message;
    try{
      final http.Response r = await http.post(url, headers: headers, body: json.encode(_payload));
      if(r.statusCode == 200){
        _message = {
          'status': 0,
          'resultCode': json.decode(r.body)['ResultCode'],
          'body': json.decode(r.body)
        };
      } else {
        _message = {
          'status': 1,
          'body': json.decode(r.body)
        };
      }
    } catch (e){
      _message = {
        'status': 101,
        'body': e
      };
    }

    return _message;

  }
}

