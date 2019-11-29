import 'dart:convert';

import 'package:e_pay_gateway/third_party_operations/mpesa/settings.dart';
import 'package:http/http.dart' as http;

Future<String> fetchMpesaToken()async{
  final String username = consumerKey;
  final String password = consumerSecret;
  final _base64E = base64Encode(utf8.encode('$username:$password'));
  final String basicAuth = 'Basic $_base64E';

  try{
    http.Response r = await http.get(getTokenURL,headers: <String, String>{'authorization': basicAuth});

    final body = json.decode(r.body);

    return body['access_token'].toString();
  }catch (e){
    return 'error';
  }

}
