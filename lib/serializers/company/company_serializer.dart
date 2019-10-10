import 'package:e_pay_gateway/e_pay_gateway.dart';

class CompanySerializer extends Serializable{
  String name;


  @override
  Map<String, dynamic> asMap() {
    return {
      "name": name,
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    name = object['name'].toString();
  }


}
