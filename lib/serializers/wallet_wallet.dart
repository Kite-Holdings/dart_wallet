import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/transaction_model.dart';
import 'package:e_pay_gateway/models.dart/wallet_activities_model.dart';
import 'package:e_pay_gateway/serializers/wallet_serializer.dart';
import 'package:e_pay_gateway/settings/settings.dart';

class WalletToWallet extends Serializable{
  String senderAccount;
  String recipientAccount;
  double amount;
  @override
  Map<String, dynamic> asMap() {
    
    return {
      "senderAccount": senderAccount,
      "recipientAccount": recipientAccount,
      "amount": amount
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    senderAccount = object['senderAccount'].toString();
    recipientAccount = object['recipientAccount'].toString();
    amount = double.parse(object['amount'].toString());
  }

  Future<Map<String, dynamic>> performTransaction()async{
    double transactionAmount (){
      return amount + amount * walletRate;
    }

    final WalletSerializer wallet = WalletSerializer();

    // credit sender
    final Map<String, dynamic> _newSenderInfo = await wallet.credit(accountNo: senderAccount, amount: transactionAmount());
    // debit recipient
    final Map<String, dynamic> _newRecipientInfo = await wallet.debit(accountNo: recipientAccount, amount: amount);

    WalletActivitiesModel _senderWalletActivity = WalletActivitiesModel(
      walletId: _newSenderInfo['_id'].toString(),
      walletNo: senderAccount,
      secontPartyAccNo: recipientAccount,
      action: WalletActivityAction.sent,
      amount: transactionAmount(),
      balance: double.parse(_newSenderInfo['balance'].toString())
    );

    WalletActivitiesModel _recipientWalletActivity = WalletActivitiesModel(
      walletId: _newRecipientInfo['_id'].toString(),
      walletNo: recipientAccount,
      secontPartyAccNo: senderAccount,
      action: WalletActivityAction.received,
      amount: amount,
      balance: double.parse(_newRecipientInfo['balance'].toString())
    );

    _senderWalletActivity.save().then((Map<String, dynamic> senderObj){
      _recipientWalletActivity.save().then((Map<String, dynamic> recipientObj){
        final TransactionModel trans = TransactionModel(
        senderInfo: senderObj,
          recipientInfo: recipientObj,
          amount: amount,
          transactionType: "WalletToWallet",
          cost: transactionAmount() - amount,
        );
        trans.save();
      });
      
    });
      
    



    return{
      "statusCode": 0,
      "message": "success",
      "object": _newSenderInfo
    };
  }
}