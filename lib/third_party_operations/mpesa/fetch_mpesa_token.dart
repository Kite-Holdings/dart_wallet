import 'dart:convert';

import 'package:e_pay_gateway/third_party_operations/mpesa/settings.dart';
import 'package:http/http.dart' as http;

Future<String> fetchMpesaToken()async{
  String username = consumerKey;
  String password = consumerSecret;
  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));

  http.Response r = await http.get('https://api.somewhere.io',headers: <String, String>{'authorization': basicAuth});

  var body = json.decode(r.body);

  return body['access_token'].toString();
}