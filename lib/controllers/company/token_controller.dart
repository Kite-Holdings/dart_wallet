import 'package:e_pay_gateway/e_pay_gateway.dart';

class TokenController extends ResourceController{
  @Operation.get()
  Future<Response> getToken()async{
    print(request.authorization.clientID);
    return Response.ok({'f':'h'});
  }
}