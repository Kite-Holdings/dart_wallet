import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/accounts/account_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/requests_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/responses_model.dart';
import 'package:e_pay_gateway/models.dart/token_model.dart';
import 'package:pedantic/pedantic.dart';

class AccountsLoginController extends ResourceController{
  @Operation.get()
  Future<Response> getToken()async{
    final TokenModel _tokenModel = TokenModel();

    final AccountModel _accountModel = AccountModel();
    final Map<String, dynamic> _account = await _accountModel.findById(request.authorization.clientID);


    final RequestsModel _requestsModel = RequestsModel(
      url: '/accounts/login',
      requestType: RequestType.token,
      account: _account['address']['email'].toString(),
      metadata: {
        'clientId': request.authorization.clientID,
        'entity': 'user'
      }
    );

    final String _reqId = await _requestsModel.save();

    final Map<String, dynamic> _res = await _tokenModel.getToken(owner: 'wallet/accounts/${request.authorization.clientID}');

    final ResponsesModel _responsesModel = ResponsesModel(
      requestId: _reqId,
      responseType: ResposeType.token,
      responseBody: _res
    );

    unawaited(_responsesModel.save());
    
    return Response.ok(_res);
  }

}