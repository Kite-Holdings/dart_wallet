
import 'dart:convert';

import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:e_pay_gateway/third_part_operations/banks_operations/fetch_token.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

FutureOr<RequestOrResponse> pesaLinkTransact() async{

  String url = pesalinkTransactUrl;

  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json', 
    'Authorization': "Bearer $fetchPesaLinktoken()",
  };
  Map<String, dynamic> body = 
    {
      "MessageReference": "40ca18c6765086089a1",
      "CallBackUrl": "https://yourdomain.com/ftresponse",
      "Source": {
        "AccountNumber": "36001873000",
        "Amount": 777,
        "TransactionCurrency": "KES",
        "Narration": "Supplier Payment"
      },
      "Destinations": [
        {
          "ReferenceNumber": "40ca18c6765086089a1_1",
          "AccountNumber": "54321987654321",
          "BankCode": "11",
          "Amount": 777,
          "TransactionCurrency": "KES",
          "Narration": "Electricity Payment"
        }
      ]
    };

  bool trustSelfSigned = true;
  HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => trustSelfSigned);
  IOClient ioClient = new IOClient(httpClient);

  http.Response response = await ioClient.post(url, body: json.encode(body), headers: headers);
  var responseJson = json.decode(response.body);
  return Response.ok(responseJson);
}