import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/companies%20models/company_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/requests_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/responses_model.dart';
import 'package:e_pay_gateway/models.dart/token_model.dart';
import 'package:pedantic/pedantic.dart';

class TokenController extends ResourceController{
  @Operation.get()
  Future<Response> getToken()async{
    final TokenModel _tokenModel = TokenModel();

    final CompanyModel _companyModel = CompanyModel();
    final Map<String, dynamic> _company = await _companyModel.findById(request.authorization.clientID);

    final RequestsModel _requestsModel = RequestsModel(
      url: '/token',
      requestType: RequestType.token,
      account: _company['data']['name'].toString(),
      metadata: {
        'clientId': request.authorization.clientID,
        'entity': 'cooprate'
      }
    );

    final String _reqId = await _requestsModel.save();

    final Map<String, dynamic> _res = await _tokenModel.getToken(owner: 'wallet/companies/${request.authorization.clientID}');

    final ResponsesModel _responsesModel = ResponsesModel(
      requestId: _reqId,
      responseType: ResposeType.token,
      responseBody: _res
    );

    unawaited(_responsesModel.save());
    
    return Response.ok(_res);
  }
}