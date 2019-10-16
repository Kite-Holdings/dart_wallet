import 'dart:convert';

import 'package:e_pay_gateway/third_party_operations/mpesa/fetch_mpesa_token.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/settings.dart';
import 'package:http/http.dart' as http;

Future bPhoneNo({String phoneNo, String amount})async{

  final String accessToken =await fetchMpesaToken();


  final Map<String, dynamic> payload = {
      "InitiatorName": businessLabel,
      "SecurityCredential": securityCredential,
      "CommandID": "BusinessPayment",
      // "SenderIdentifierType": "4",
      // "RecieverIdentifierType": "1",
      "Amount": amount,
      "PartyA": businessShortCode,
      "PartyB": phoneNo,
      "Remarks": "test",
      "QueueTimeOutURL": "https://7eaf6301.ngrok.io/mpesaResponces/cb",
      "ResultURL": "https://7eaf6301.ngrok.io/mpesaResponces/cb",
      "AccountReference": "test123"
  };
  final Map<String, String> headers = {
        'content-type': 'application/json',
        'Authorization': 'Bearer ' + accessToken
    };

  final String url = b2cURL;

  final http.Response r = await http.post(url, headers: headers, body: json.encode(payload));

  return json.decode(r.body);


}
