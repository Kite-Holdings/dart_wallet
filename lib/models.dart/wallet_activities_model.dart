import 'dart:async';

import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class WalletActivitiesModel{

  WalletActivitiesModel({
    this.walletId,
    this.walletNo,
    this.secontPartyWalleNo,
    this.action,
    this.amount,
    this.balance
  });
  ///Wallet _id
  ///walletNo
  ///balance
  /// Second Party walletNo
  /// Amount 
  /// Action (received, sent)
  /// timeStamp
  final String walletId;
  final String walletNo;
  final String secontPartyWalleNo;
  final String action;
  final double amount;
  final double balance;
  DateTime timeStamp;

  static Db db =  Db(databaseUrl);
  final DbCollection walletActivities = db.collection('wallet_transaction_activities');

  Future<Map<String, dynamic>> save()async{
    timeStamp = DateTime.now();
    ObjectId _id = ObjectId();
    await db.open();
    await walletActivities.insert({
      "_id": _id,
      "walletDetails": {
        "walletId": walletId,
        "walletNo": walletNo,
        "balance": balance,
      },
      "timeStamp": timeStamp,
      "secontPartyWalleNo": secontPartyWalleNo,
      "action": action,
      "amount": amount
    });

    final Map<String, dynamic> _obj = await walletActivities.findOne(where.eq('_id', _id)); 

    await db.close();
    return _obj;
  }
  
}