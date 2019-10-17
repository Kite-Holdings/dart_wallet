import 'package:e_pay_gateway/e_pay_gateway.dart';

class InternalFundsTransferSerializer extends Serializable{
  String accountNumber;
  int amount;
  String transactionCurrency;
  String narration;

  @override
  Map<String, dynamic> asMap() {
    return {
      "accountNumber": accountNumber,
      "amount": amount,
      "transactionCurrency": transactionCurrency,
      "narration": narration
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    accountNumber = object['accountNumber'].toString();
    amount = int.parse(object['amount'].toString());
    transactionCurrency = object['transactionCurrency'].toString();
    narration = object['narration'].toString();
  }

}