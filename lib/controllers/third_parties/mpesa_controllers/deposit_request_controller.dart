import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/mpesa/deposit_request.dart';

class DepositRequestController extends ResourceController{
  @Operation.post()
  Future<Response> deposit(@Bind.body() MpesaDepositRequestSerializer depositRequestSerializer)async{
    return Response.ok(await depositRequestSerializer.sendRequest());
  }
}
