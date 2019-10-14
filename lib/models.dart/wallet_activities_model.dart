import 'dart:async';

import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class WalletActivitiesModel{

  WalletActivitiesModel({
    this.walletId,
    this.walletNo,
    this.secontPartyAccNo,
    this.action,
    this.amount,
    this.balance
  });
  ///Wallet _id
  ///walletNo
  ///balance
  /// Second Party accountNo
  /// Amount 
  /// Action (received, sent)
  /// timeStamp
  final String walletId;
  final String walletNo;
  final String secontPartyAccNo;
  final WalletActivityAction action;
  final double amount;
  final double balance;
  DateTime timeStamp;

  static Db db =  Db(databaseUrl);
  final DbCollection walletActivities = db.collection('wallet_transaction_activities');

  get walletActivityAction => (){
    if(action == WalletActivityAction.received){
      return "received";
    } else if(action == WalletActivityAction.sent){
      return "sent";
    }
    else{
      return "unknown";
    }
  };

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
      "secontPartyAccNo": secontPartyAccNo,
      "action": walletActivityAction,
      "amount": amount
    });

    final Map<String, dynamic> _obj = await walletActivities.findOne(where.eq('_id', _id)); 

    await db.close();
    return _obj;
  }

  
}

enum WalletActivityAction{
  received,
  sent
}