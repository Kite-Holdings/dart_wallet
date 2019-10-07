import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:aqueduct/aqueduct.dart';
import 'package:e_pay_gateway/serializers/mpesa/buy_goods_services.dart';


class BuyGoodsServicesController extends ResourceController{
  @Operation.post()
  Future<Response> createUser(@Bind.body() MpesaBuyGoodsServices buyGoodsServicesSerializer)async{
    return Response.ok(await buyGoodsServicesSerializer.performTransaction());
  }
}
