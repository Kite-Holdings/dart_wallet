import 'package:aqueduct/aqueduct.dart';
import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/accounts/account_model.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class BasicAouthVerifier extends AuthValidator {
  @override
  FutureOr<Authorization> validate<T>(AuthorizationParser<T> parser, T authorizationData, {List<AuthScope> requiredScope}) async {
    List<String> _aouthDetails = authorizationData.toString().split(":");
    Db db = Db(databaseUrl);
    final DbCollection _companies = db.collection("companies");
    await db.open();
    final Map<String, dynamic> _company = await _companies.findOne(where.eq("consumerKey", _aouthDetails[0]));
    await db.close();
    if(_company == null) {
      return null;
      }

    if (_company['secreteKey'].toString() == _aouthDetails[1]) {
      return null;
    }

    return Authorization(_company['_id'].toString().split('\"')[1], 0, this, );
  }
    
  
}

class AccountLoginIdentifier extends AuthValidator {

  final AccountModel _accountModel = AccountModel();

  @override
  FutureOr<Authorization> validate<T>(AuthorizationParser<T> parser, T authorizationData, {List<AuthScope> requiredScope}) async {
    List<String> _aouthDetails = authorizationData.toString().split(":");
    Db db = Db(databaseUrl);
    final DbCollection _accounts = db.collection("accounts");
    await db.open();
    final Map<String, dynamic> _account = await _accounts.findOne(where.eq("address.email", _aouthDetails[0]));
    await db.close();
    if(_account == null) {
      return null;
      }
    if (_accountModel.verifyPassword(_aouthDetails[1], _account['password'].toString())) {
      return Authorization(_account['_id'].toString().split('\"')[1], 0, this, );
    } else {
      return null;
    }

    return Authorization(_account['_id'].toString().split('\"')[1], 0, this, );
  }
    
  
}

class                                                                                           BearerAouthVerifier extends AuthValidator{
  @override
  FutureOr<Authorization> validate<T>(AuthorizationParser<T> parser, T authorizationData, {List<AuthScope> requiredScope}) async {
    String _token = authorizationData.toString();
    Db db = Db(databaseUrl);
    final DbCollection _tokens = db.collection("tokens");
    await db.open();
    final Map<String, dynamic> _tokenInfo = await _tokens.findOne(where.eq("token", _token));
    int seconds = (DateTime.now().millisecondsSinceEpoch/1000).floor();
    await db.close();
    if (_tokenInfo == null) {
      return null;
    }

    if (seconds >= int.parse(_tokenInfo['validTill'].toString())) {
      return null;
    }

    return Authorization(_tokenInfo['ownerRef'].toString().split("/")[2], 0, this, );
  }
}