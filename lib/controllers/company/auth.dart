import 'package:aqueduct/aqueduct.dart';
import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/accounts/account_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/requests_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/responses_model.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:pedantic/pedantic.dart';

class BasicAouthVerifier extends AuthValidator {
  @override
  FutureOr<Authorization> validate<T>(AuthorizationParser<T> parser, T authorizationData, {List<AuthScope> requiredScope}) async {
    List<String> _aouthDetails = authorizationData.toString().split(":");
    Db db = Db(databaseUrl);
    final DbCollection _companies = db.collection("companies");
    await db.open();
    final Map<String, dynamic> _company = await _companies.findOne(where.eq("consumerKey", _aouthDetails[0]));
    await db.close();
    String _id;
    if(_company == null) {
      // 
      final RequestsModel _requestsModel = RequestsModel(
        url: '/accounts/login',
        requestType: RequestType.token,
        account: _aouthDetails[0],
        metadata: {
          'clientId': _id,
          'entity': 'user'
        }
      );

      final String _reqId = await _requestsModel.save();
      final ResponsesModel _responsesModel = ResponsesModel(
        requestId: _reqId,
        responseType: ResposeType.token,
        responseBody: {"message": "Wrong Consumer Key"},
        status: ResponsesStatus.failed
      );
      unawaited(_responsesModel.save());
      //
      return Authorization(null, 0, null);
      }

    if (_company['secretKey'].toString() == _aouthDetails[1].toString()) {
      _id = _company['_id'].toString().split('\"')[1];
      return Authorization(_id, 0, this, );

    } else {
      // 
      _id = _company['_id'].toString().split('\"')[1];
      final RequestsModel _requestsModel = RequestsModel(
        url: '/accounts/login',
        requestType: RequestType.token,
        account: _aouthDetails[0],
        metadata: {
          'clientId': _id,
          'entity': 'user'
        }
      );

      final String _reqId = await _requestsModel.save();
      final ResponsesModel _responsesModel = ResponsesModel(
        requestId: _reqId,
        responseType: ResposeType.token,
        responseBody: {"message": "Wrong Consumer Secret"},
        status: ResponsesStatus.failed
      );
      unawaited(_responsesModel.save());
      //
      return Authorization(null, 0, null);
    }
  }
    
  
}

class AccountLoginIdentifier extends AuthValidator {

  final AccountModel _accountModel = AccountModel();

  @override
  FutureOr<Authorization> validate<T>(AuthorizationParser<T> parser, T authorizationData, {List<AuthScope> requiredScope}) async {
    final List<String> _aouthDetails = authorizationData.toString().split(":");
    Db db = Db(databaseUrl);
    final DbCollection _accounts = db.collection("accounts");
    await db.open();
    final Map<String, dynamic> _account = await _accounts.findOne(where.eq("address.email", _aouthDetails[0]));
    await db.close();

    String _id;


    if(_account == null) {

      final RequestsModel _requestsModel = RequestsModel(
        url: '/accounts/login',
        requestType: RequestType.token,
        account: _aouthDetails[0],
        metadata: {
          'clientId': _id,
          'entity': 'user'
        }
      );

      final String _reqId = await _requestsModel.save();
      final ResponsesModel _responsesModel = ResponsesModel(
        requestId: _reqId,
        responseType: ResposeType.token,
        responseBody: {"message": "Wrong Email"},
        status: ResponsesStatus.failed
      );
      unawaited(_responsesModel.save());
      
      return Authorization(null, 0, null);

    } 
    else if (_accountModel.verifyPassword(_aouthDetails[1], _account['password'].toString())) {
      _id = _account['_id'].toString().split('\"')[1];
      return Authorization(_id, 0, this, );
    }
    else {
      _id = _account['_id'].toString().split('\"')[1];
      final RequestsModel _requestsModel = RequestsModel(
        url: '/accounts/login',
        requestType: RequestType.token,
        account: _aouthDetails[0],
        metadata: {
          'clientId': _id,
          'entity': 'user'
        }
      );

      final String _reqId = await _requestsModel.save();
      final ResponsesModel _responsesModel = ResponsesModel(
        requestId: _reqId,
        responseType: ResposeType.token,
        responseBody: {"message": "Wrong Password"},
        status: ResponsesStatus.warning
      );
      unawaited(_responsesModel.save());
      return Authorization(null, 0, null);
    }

  }
    
  
}

class BearerAouthVerifier extends AuthValidator{
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