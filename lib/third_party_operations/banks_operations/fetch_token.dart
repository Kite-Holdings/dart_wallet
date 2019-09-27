import 'dart:convert';

import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

FutureOr<RequestOrResponse> fetchPesaLinktoken() async{
  String url = pesalinkTokenUrl;

  Map<String, String> headers = {
    'Content-type' : 'application/x-www-form-urlencoded', 
    'Authorization': pesalinkAuth,
  };
  Map<String, String> body = {
    "grant_type": "password",
    "username": pesaLinkCredetials['username'],
    "password": pesaLinkCredetials['password'],
  };

  bool trustSelfSigned = true;
  HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => trustSelfSigned);
  IOClient ioClient = new IOClient(httpClient);

  http.Response response = await ioClient.post(url, body: body, headers: headers);
  var responseJson = json.decode(response.body);
  return Response.ok(responseJson['access_token']);
}