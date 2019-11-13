import 'package:e_pay_gateway/e_pay_gateway.dart';

class AccountSerializer extends Serializable{
  String username;
  String phoneNo;
  @override
  Map<String, dynamic> asMap() {
    return {
      'username': username,
      'phoneNo': phoneNo,
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    username = object['username'].toString();
    phoneNo = object['phoneNo'].toString();
  }

}