import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/mpesa/deposit_request.dart';

class DepositRequestController extends ResourceController{
  @Operation.post()
  Future<Response> deposit(@Bind.body() MpesaDepositRequestSerializer depositRequestSerializer)async{
    final _ress = await depositRequestSerializer.sendRequest();
    switch (int.parse(_ress['statusCode'].toString())) {
      case 200:
        return Response.ok(_ress['body']);
        break;
      case 400:
        return Response.badRequest(body: _ress['body']);
        break;
      case 500:
        return Response.serverError(body: _ress['body']);
        break;
      default:
    }
  }
}
