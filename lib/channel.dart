import 'package:e_pay_gateway/controllers/third_parties/mpesa_controllers/buy_goods_servisesController.dart';
import 'package:e_pay_gateway/controllers/third_parties/mpesa_controllers/deposit_request_controller.dart';
import 'package:e_pay_gateway/controllers/third_parties/mpesa_controllers/paybill_controller.dart';
import 'package:e_pay_gateway/controllers/third_parties/mpesa_controllers/transfer_to_phone_controller.dart';
import 'package:e_pay_gateway/controllers/users/users_accounts_controller.dart';

import 'e_pay_gateway.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class EPayGatewayChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  
  @override
  Future prepare() async {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://aqueduct.io/docs/http/request_controller/

    router
      .route("users/[:userId]")
    .link(() => UsersController());
    router
      .route("/")
    .linkFunction((request)async{
      // return pesaLinkTransact();
      return Response.ok({"Hi": "Hi"});
    });


    // Mpesa
    router
      .route('/thirdParties/mpesa/paybill')
      .link(() => PaybillController());
    router
      .route('/thirdParties/mpesa/buygoodsServices')
      .link(() => BuyGoodsServicesController());
    router
      .route('/thirdParties/mpesa/transfertoPhone')
      .link(() => TransferPhoneController());
    router
      .route("/thirdParties/mpesa/depositRequest")
      .link(() => DepositRequestController());

    return router;
  }
}
