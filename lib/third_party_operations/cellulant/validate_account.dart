import 'dart:convert';

import 'package:e_pay_gateway/third_party_operations/cellulant/settings.dart';
import 'package:http/http.dart' as http;
class ValidateAccount {
//   {
// "function": "BEEP.queryBill",
// "payload":
// {"credentials":{"username":"safaricom_api_user","password":"!23qweASD"},"packet":
// [{"serviceID":2,"accountNumber":"4623617002","requestExtraData":""}]}
// }

  dynamic validate() async{
    final Map<String, dynamic> _payload = {
      "function": "BEEP.validateAccount",
      "payload": {
        "credentials":{
          "username": "safaricom_api_user", 
          "password":"!23qweASD"
          },
        "packet": [
          {
            "serviceID":717,
            "accountNumber":"25400001404",
            "requestExtraData":""
          }
        ]
      }
    };

    final http.Response _res = await  http.post(validateAccUrl, body: json.encode(_payload));
    print("..................................");
    print(_res.body);
    print("..................................");

    return json.decode(_res.body);
  }
}