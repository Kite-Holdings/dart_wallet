import 'package:e_pay_gateway/controllers/utils/counter_intrement.dart';
import 'package:e_pay_gateway/models.dart/utils/strigify_count.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';

class WalletModel{
  // TODO: update comment
  /// This functions create and saves a new Virtual Wallet
  /// It takes three arguments, user refference company code and account type(0 for consumer, 1 for Merchant)
  /// It returns a details of the created virtual wallet

  WalletModel({
    this.companyCode,
    this.accountType,
    this.accountRefference
  });

  String accountRef;
  double balance;
  String walletAccountNo;
  final String companyCode;
  final String accountType;
  final String accountRefference;

  final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'wallets');

  // check if wallet exist
  Future<bool> walletExist(String accountNo)async{
    return _databaseBridge.exists(where.eq("walletAccountNo", accountNo));
  }

  // TODO: create
  Future<Map<String, dynamic>> save() async {
    int c = await companyCounter ('walletAccountNo');
    walletAccountNo = stringifyCount(c, 9);
    walletAccountNo = companyCode + accountType + walletAccountNo;
    accountRef = accountRefference;
    balance = 0;

    try{
        print(await _databaseBridge.insert({
          'balance': balance,
          'accountRef': accountRef,
          'walletAccountNo': walletAccountNo
        }));
    } catch (e){
      print(e);
    }
    Map<String, dynamic> wallet;
    try{
        wallet = await _databaseBridge.findOneBy(where.eq('walletAccountNo', walletAccountNo));
    } catch (e){
    }    
    if(wallet != null){
      final String _walletIdObj= wallet['_id'].toString();
      final String _walletId= _walletIdObj.split('"')[1];
      final String walletRef = '${databaseName}/wallets/$_walletId';
      wallet['ref'] = walletRef;
    }else{
      wallet['ref'] = null;
    }
    return wallet;
  }

  // TODO: get all

  // TODO: get one

  // TODO: get by

  // TODO: get credit
  /// This function decrements wallet ballance by some amount
  /// It takes two arguments, the wallet account number(walletAccountNo) and amount (amount)
  /// It returns a Map of status with balance
  /// If the transaction failed the status is "failed", else "success"
  Future<Map<String, dynamic>> credit({String accountNo, double amount})async{
    // TODO: Verify if sender wallet got enough cash
    // If so subract amount from acc
    try{
      final Map<String, dynamic> _res =await _databaseBridge.findAndModify(
        selector: where.eq("walletAccountNo", accountNo).gt("balance", amount),
        modify: {"\$inc":{"balance": -amount}},
      );
      final _info = _res['body'];
      
      // TODO: Check if succeeded
      return {
        "status": "success",
        "balance": double.parse(_info['balance'].toString()),
        "_id": _info['_id'].toString().split('"')[1]
      };
    } catch(e){
      return {
        "status": "failed",
        "message": e.toString().split('\n')[1] == 'Receiver: null' ? 'Insuficient balance': 'error'
      };
    }
  }

  // TODO: get debit
  /// This function increments wallet ballance by some amount
  /// It takes two arguments, the wallet account number(walletAccountNo) and amount (amount)
  /// It returns a Map of status with balance
  /// If the transaction failed the status is "failed", else "success"
  Future<Map<String, dynamic>> debit({String accountNo, double amount})async{
    // TODO: Verify if sender wallet got enough cash
    // If so subract amount from acc
    try{
      final Map<String, dynamic> _res =await _databaseBridge.findAndModify(
        selector: where.eq("walletAccountNo", accountNo),
        modify: {"\$inc":{'balance':amount}},
      );
      final _info = _res['body'];
      // TODO: Check if succeeded
      return {
        "status": "success",
        "balance": double.parse(_info['balance'].toString()),
        "_id": _info['_id'].toString().split('"')[1]
      };
    }catch(e){
      return {
        "status": "failed",
        "message": 'database error'
      };
    }
  }
}