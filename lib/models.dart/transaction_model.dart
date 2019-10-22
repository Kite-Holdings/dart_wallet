import 'dart:async';

import 'package:e_pay_gateway/settings/settings.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';

class TransactionModel {

  TransactionModel({
    this.senderInfo,
    this.companyCode,
    this.recipientInfo,
    this.amount,
    this.cost,
    this.totalAmount,
    this.transactionType,
    this.state = TransactionState.processing
    
  });

  DateTime timeStamp;
  final String companyCode;
  final Map<String, dynamic> senderInfo;
  final Map<String, dynamic> recipientInfo;
  final TransactionType transactionType;
  final TransactionState state;
  final double amount;
  final double cost;
  double totalAmount;

  final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'transactions');

  Future<Map<String, dynamic>> save()async{
    totalAmount = amount + cost;
    timeStamp = DateTime.now();


    final Map<String, dynamic> _trans = await _databaseBridge.insert({
      "senderInfo": senderInfo,
      "companyCode": companyCode,
      "recipientInfo": recipientInfo,
      "amount": amount,
      "cost": cost,
      "totalAmount": totalAmount,
      "transactionType": _transactionType,
      "state": _state
    });

    return _trans;
  }

  String get _transactionType {
    switch (transactionType) {
      case TransactionType.walletToWallet:
        return "WalletToWallet";
        break;
      case TransactionType.walletToMpesaPaybill:
        return "WalletToMpesaPaybill";
        break;
      case TransactionType.walletToMpesaBuygoods:
        return "WalletToMpesaBuygoods";
        break;
      case TransactionType.walletToCoopPeaslink:
        return "WalletToCoopPesalink";
        break;
      case TransactionType.walletToCoopIft:
        return "WalletToCoopIft";
        break;
      default:
        return "UnDefiened";
    }
  }

  String get _state {
    switch (state) {
      case TransactionState.processing:
        return "processing";        
        break;
      case TransactionState.complete:
        return "complete";        
        break;
      case TransactionState.failed:
        return "failed";        
        break;
      case TransactionState.cancled:
        return "cancled";        
        break;
      default:
        return "UnDefiened";
    }
  }
  


}

enum TransactionType{
  walletToWallet,
  walletToMpesaPaybill,
  walletToMpesaBuygoods,
  walletToCoopPeaslink,
  walletToCoopIft,
}

enum TransactionState{
  processing,
  complete,
  failed,
  cancled,
}