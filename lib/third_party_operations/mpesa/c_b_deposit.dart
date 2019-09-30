import 'dart:convert';

import 'package:e_pay_gateway/third_party_operations/mpesa/fetch_mpesa_token.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/settings.dart';
import 'package:http/http.dart' as http;

Future depositRequest({String phoneNo, String amount, String accRef})async{
  final String accessToken =await fetchMpesaToken();

  var now = DateTime.now();
  String dt = now.year.toString() + now.month.toString() + now.day.toString() + now.hour.toString() + now.minute.toString() + now.second.toString();
dt = "20190930143854";
  
  var str = businessShortCode + passkey + dt;
  
  var bytes = utf8.encode(str);
  var _password = base64.encode(bytes);
print(accRef);

  final Map<String, dynamic> payload = {
    "BusinessShortCode": businessShortCode,
    "Password": _password,
    "Timestamp": dt,
    "TransactionType": "CustomerPayBillOnline",
    "Amount": double.parse(amount),
    "PartyA": phoneNo,
    "PartyB": businessShortCode,
    "PhoneNumber": phoneNo,
    "CallBackURL": callBackURL,
    "AccountReference": accRef,
    "TransactionDesc": "Kite Holdings"
};

  final Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ' + accessToken
  };

  final String url = c2bURL;


  final http.Response r = await http.post(url, headers: headers, body: json.encode(payload));

  return json.decode(r.body);

// return {"ff":"ff"};
}
