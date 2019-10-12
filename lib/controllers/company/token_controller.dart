import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/token_model.dart';

class TokenController extends ResourceController{
  @Operation.get()
  Future<Response> getToken()async{
    final TokenModel _tokenModel = TokenModel();
    
    return Response.ok(await _tokenModel.getToken(owner: 'wallet/companies/${request.authorization.clientID}'));
  }
}