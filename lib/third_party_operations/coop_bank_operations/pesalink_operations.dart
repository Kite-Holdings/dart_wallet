import 'dart:convert';

import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:e_pay_gateway/third_party_operations/coop_bank_operations/fetchCoopToken.dart';
import 'package:e_pay_gateway/third_party_operations/coop_bank_operations/settings.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/settings.dart';
import 'package:http/io_client.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:http/http.dart' as http;

class PesalinkOperations{

  PesalinkOperations({
    this.accountNumber,
    this.bankCode,
    this.amount,
    this.transactionCurrency = 'KES',
    this.narration
  });


  String messageReference;
  String callBackUrl;
  String accountNumber;
  String bankCode;
  int amount;
  String transactionCurrency;
  String narration;

  String transactionType;
  String transactionAction;

  static Db db =  Db(databaseUrl);
  final DbCollection companies = db.collection('coop_bank_transaction');

  Future get send => _transact(sending: true);
  Future get receive => _transact(sending: false);

  Future _transact({bool sending}) async{
    callBackURL = coopCallbackUrl;
    final String _accNumber = coopAccountNumber;
    final String _url = peaslinkUrl;
    final String _accessToken = await fetchCoopToken();

    messageReference = "test";


    final Map<String, dynamic> payload = {
      "MessageReference": messageReference,
      "CallBackUrl": callBackURL,
      "Source": {
        "AccountNumber": sending ? _accNumber : accountNumber,
        "Amount": amount,
        "TransactionCurrency": transactionCurrency,
        "Narration": narration
      },
      "Destinations": [
        {
          "ReferenceNumber": '${messageReference}_1',
          "AccountNumber": sending ? accountNumber : _accNumber,
          "BankCode": bankCode,
          "Amount": amount,
          "TransactionCurrency": transactionCurrency,
          "Narration": narration
        }
      ]
    };

    final Map<String, String> headers = {
        'content-type': 'application/json',
        'Authorization': 'Bearer $_accessToken'
    };
    bool trustSelfSigned = true;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = new IOClient(httpClient);

    final http.Response r = await ioClient.post(_url, headers: headers, body: json.encode(payload));

    return json.decode(r.body);

  }
}