import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:aqueduct/aqueduct.dart';
import 'package:e_pay_gateway/serializers/mpesa/paybill.dart';


class PaybillController extends ResourceController{
  @Operation.post()
  Future<Response> createUser(@Bind.body() MpesaPaybill paybillSerializer)async{
    return Response.ok(await paybillSerializer.performTransaction());
  }
}
