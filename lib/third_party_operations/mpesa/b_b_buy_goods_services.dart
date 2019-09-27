import 'dart:convert';

import 'package:e_pay_gateway/third_party_operations/mpesa/fetch_mpesa_token.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/settings.dart';
import 'package:http/http.dart' as http;

Future buyGoodsServices({String tillNo, String amount})async{
  final String accessToken =await fetchMpesaToken();
  final Map<String, dynamic> payload = {
    "Initiator": businessLabel,
    "SecurityCredential": securityCredential,
    "CommandID": "MerchantToMerchantTransfer",
    "SenderIdentifierType": "4",
    "RecieverIdentifierType": "4",
    "Amount": amount,
    "PartyA": businessShortCode,
    "PartyB": tillNo,
    "Remarks": "test",
    "QueueTimeOutURL": callBackURL,
    "ResultURL": callBackURL,
    };

  final Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ' + accessToken
  };

  final String url = b2bURL;


  final http.Response r = await http.post(url, headers: headers, body: payload);

  return json.decode(r.body);
}