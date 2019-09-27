import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:aqueduct/aqueduct.dart';
import 'package:e_pay_gateway/serializers/mpesa/wallet_buy_goods_services.dart';


class BuyGoodsServicesController extends ResourceController{
  @Operation.post()
  Future<Response> createUser(@Bind.body() WalletToBuyGoodsServices walletBuyGoodsServicesSerializer)async{
    return Response.ok(await walletBuyGoodsServicesSerializer.performTransaction());
  }
}
