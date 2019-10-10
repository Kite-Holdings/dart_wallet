import 'dart:async';

import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class TransactionModel {

  TransactionModel({
    this.senderInfo,
    this.recipientInfo,
    this.amount,
    this.cost,
    this.transactionType
  });

  DateTime timeStamp;
  final Map<String, dynamic> senderInfo;
  final Map<String, dynamic> recipientInfo;
  final String transactionType;
  final double amount;
  final double cost;
  double totalAmount;

  static Db db =  Db(databaseUrl);
  final DbCollection transactions = db.collection('transactions');

  Future<Map<String, dynamic>> save()async{
    totalAmount = amount + cost;
    timeStamp = DateTime.now();

    await db.open();

    Map<String, dynamic> _trans = await transactions.insert({
      "senderInfo": senderInfo,
      "recipientInfo": recipientInfo,
      "amount": amount,
      "cost": cost,
      "totalAmount": totalAmount,
      "transactionType": transactionType
    });

    await db.close();
    return _trans;
  }
}