import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/transaction_model.dart';
import 'package:e_pay_gateway/models.dart/wallet_models/wallet_activities_model.dart';
import 'package:e_pay_gateway/models.dart/wallets/wallet_model.dart';
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

  Future<Map<String, dynamic>> performTransaction({String companyCode})async{
    final WalletModel _walletModel = WalletModel();
    final bool _senderExist = await _walletModel.walletExist(senderAccount);
    final bool _recipientExist = await _walletModel.walletExist(recipientAccount);
    if(!_senderExist){
      return {
          "statusCode": 2,
          "message": "Sender Wallet account does not exist",
        };
    } else if(!_recipientExist){
      return {
          "statusCode": 2,
          "message": "Recipient Wallet account does not exist",
        };
    } else{
      double transactionAmount (){
        return amount + amount * walletRate;
      }

      
      // credit sender
      final Map<String, dynamic> _newSenderInfo = await _walletModel.credit(accountNo: senderAccount, amount: transactionAmount());
      // if success
      if(_newSenderInfo['status'] == 'success'){
        // debit recipient
        final Map<String, dynamic> _newRecipientInfo = await _walletModel.debit(accountNo: recipientAccount, amount: amount);

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

        await _senderWalletActivity.save().then((Map<String, dynamic> senderObj){
          _recipientWalletActivity.save().then((Map<String, dynamic> recipientObj){
            final TransactionModel trans = TransactionModel(
              senderInfo: senderObj,
              companyCode: companyCode,
              recipientInfo: recipientObj,
              amount: amount,
              transactionType: TransactionType.walletToWallet,
              cost: transactionAmount() - amount,
              state: TransactionState.complete
            );
            trans.save();
          });
          
        });
          
        



        return{
          "statusCode": 0,
          "message": "success",
          "object": _newSenderInfo
        };
      } // endif
      else{
        return {
          "statusCode": 1,
          "message": _newSenderInfo['message'],
          "object": _newSenderInfo
        };
      }
    }
  }
}