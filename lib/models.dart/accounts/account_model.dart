import 'package:e_pay_gateway/models.dart/wallets/wallet_model.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';

class AccountModel{

  AccountModel({
    this.companyCode,
    this.identifier,
    this.identifierType,
    this.username,
    this.password,
    this.phoneNo,
    this.email,
    this.accountType,
    this.wallets = const [],
  });

  final String companyCode;
  final String identifier;
  final IdentifierType identifierType;
  final String username;
  final String phoneNo;
  final String email;
  final String password;
  final AccountType accountType;
  List wallets;

  final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'accounts');

  // TODO: save
  Future<Map<String, dynamic>> save()async{
    // TODO: hash password

    await _databaseBridge.insert({
      'identifier': identifier,
      'identifierType': _identifierType,
      'accountType': _accountType,
      'username': username,
      'address': {
        'phoneNo': phoneNo,
        'email': email,
      },
      'wallets': [],
    });
    final Map<String, dynamic> account = await _databaseBridge.findOneBy(where.eq('identifier', identifier));
    final _id = account['_id'];
    final String accountRef = '$databaseName + /accounts/ + ${_id.toString()}';
    final WalletModel _walletModel = WalletModel(
      accountRefference: accountRef, 
      accountType: accountType == AccountType.consumer ? '0' : '1', 
      companyCode: companyCode
    );
    final Map<String, dynamic> newWallet = await _walletModel.save();
    final String walletRef = newWallet['ref'].toString();

    await _databaseBridge.update(where.eq('_id', account['_id']), modify.push('wallets', walletRef));


    return {
      'identifier': identifier,
      'username': username,
      'accountType': _accountType,
      'address': {
        'phoneNo': phoneNo,
        'email': email,
      },
      'wallet': {
        'balance': newWallet['balance'],
        'walletAccountNo': newWallet['walletAccountNo']
      },
    };

  }

  // find all
  Future getAll()async{
    final Map<String, dynamic> _accountsMap = await _databaseBridge.find();
    final _accountsList = _accountsMap['body'];
    return _accountsList;
  }
  // find one
  // Find by identifier
  Future<Map<String, dynamic>> findByIdentifier(String accountId)async{
    final Map<String, dynamic> account = await _databaseBridge.findOneBy(where.eq('identifier', accountId));
    return account;
  }
  // TODO: find by


  String get _identifierType{
    switch (identifierType) {
      case IdentifierType.nationalId:
        return 'NationalId';
        break;
      case IdentifierType.birthCertificate:
        return 'BirthCertificate';
        break;
      case IdentifierType.kraPin:
        return 'KRAPin';
        break;
      case IdentifierType.passport:
        return 'Passport';
        break;
      default:
        return 'Undefiened';
    }
  }

  String get _accountType {
    switch (accountType) {
      case AccountType.consumer:
        return 'consumer';
        break;
      case AccountType.merchant:
        return 'merchant';
        break;
      default:
        return 'Undefiened';
    }
  }



}

enum IdentifierType{
  nationalId,
  birthCertificate,
  kraPin,
  passport
}

enum AccountType{
  consumer,
  merchant,
}