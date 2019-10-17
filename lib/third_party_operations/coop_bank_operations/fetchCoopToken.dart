import 'dart:convert';

import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/third_party_operations/coop_bank_operations/settings.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

Future<String> fetchCoopToken()async{
  final String username = coopConsumerKey;
  final String password = coopConsumerSecret;
  final String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
  final Map<String, String> _headers = {
    'authorization': basicAuth,
    "Accept": "application/json",
    "Content-Type": "application/x-www-form-urlencoded"
  };

  bool trustSelfSigned = true;
  HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => trustSelfSigned);
  IOClient ioClient = new IOClient(httpClient);


  final http.Response r = await ioClient.post(coopTokenUrl, body: {'grant_type': 'client_credentials'}, headers: _headers, );

  final body = json.decode(r.body);

  return body['access_token'].toString();

}
