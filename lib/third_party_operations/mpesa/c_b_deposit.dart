import 'dart:convert';

import 'package:e_pay_gateway/third_party_operations/mpesa/fetch_mpesa_token.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/settings.dart';
import 'package:http/http.dart' as http;

Future depositRequest({String phoneNo, String amount, String accRef})async{
  final String accessToken =await fetchMpesaToken();
  final Map<String, dynamic> payload = {
    "ShortCode": businessShortCode,
    "CommandID": "CustomerPayBillOnline",
    "Amount": amount,
    "Msisdn": phoneNo,
    "BillRefNumber": accRef
    };

  final Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ' + accessToken
  };

  final String url = c2bURL;


  final http.Response r = await http.post(url, headers: headers, body: payload);

  return json.decode(r.body);
}