import 'package:e_pay_gateway/models.dart/wallets/wallet_model.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';
import 'package:password/password.dart';

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

  // save
  Future<Map<String, dynamic>> save()async{

    // hash password
    final String _hash = Password.hash(password, PBKDF2());

    final ObjectId _id = ObjectId();

    await _databaseBridge.insert({
      '_id': _id,
      'identifier': identifier,
      'identifierType': _identifierType,
      'accountType': _accountType,
      'username': username,
      'password': _hash,
      'address': {
        'phoneNo': phoneNo,
        'email': email,
      },
      'wallets': [],
    });
    final _idStr = _id.toString().split('"')[1];
    final String accountRef = '$databaseName/accounts/$_idStr';
    final WalletModel _walletModel = WalletModel(
      accountRefference: accountRef, 
      accountType: accountType == AccountType.consumer ? '0' : '1', 
      companyCode: companyCode
    );
    final Map<String, dynamic> newWallet = await _walletModel.save();
    final String walletRef = newWallet['ref'].toString();
    await _databaseBridge.update(where.eq('_id', _id), modify.push('wallets', walletRef));


    return {
      'identifier': identifier,
      'username': username,
      'accountType': _accountType,
      'address': {
        'phoneNo': phoneNo,
        'email': email,
      },
      'wallets': [{
        'balance': newWallet['balance'],
        'walletAccountNo': newWallet['walletAccountNo']
      }],
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
    final _walletsId = account['wallets'];
    List<Map<String, dynamic>> _wallets = [];
    final DatabaseBridge _walletDatabaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'wallets');
    
    _walletsId.forEach((itemId)async{
      ObjectId _id = ObjectId.parse(itemId.toString().split('/').last);
      final Map<String, dynamic> _wallet = await _walletDatabaseBridge.findOneBy(where.id(_id)); 
      _wallets.add(_wallet);
    });
    account['wallets'] = _wallets;
    return account;
  }
  // TODO: find by _id
  Future<Map<String, dynamic>> findById(String id)async{
    final Map<String, dynamic> account = await _databaseBridge.findOneBy(where.id(ObjectId.parse(id)).excludeFields(['_id', 'password']));
    final _walletsId = account['wallets'];
    final DatabaseBridge _walletDatabaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'wallets');
    
    final List _ids = [];
    _walletsId.forEach((itemId){
      final ObjectId _id = ObjectId.parse(itemId.toString().split('/').last);
      _ids.add(_id);
    });
    final Map<String, dynamic> _walletsMap = await _walletDatabaseBridge.findBy(where.all('_id', _ids).fields(['balance', 'walletAccountNo']).excludeFields(['_id']));
    final _wallets = _walletsMap['body'];

    account['wallets'] = _wallets;
    return account;
  }

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

  bool verifyPassword(String password, String hash){
    return Password.verify(password, hash);
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