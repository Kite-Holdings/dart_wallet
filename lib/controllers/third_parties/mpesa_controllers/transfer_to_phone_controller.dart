import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:aqueduct/aqueduct.dart';
import 'package:e_pay_gateway/serializers/mpesa/mpesa_phone.dart';


class TransferPhoneController extends ResourceController{
  @Operation.post()
  Future<Response> createUser(@Bind.body() MpesaToPhoneNo walletPhoneSerializer)async{
    return Response.ok(await walletPhoneSerializer.performTransaction());
  }
}
