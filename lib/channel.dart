import 'package:e_pay_gateway/controllers/accounts/consumer_account_controller.dart';
import 'package:e_pay_gateway/controllers/accounts/merchant_account_controllewr.dart';
import 'package:e_pay_gateway/controllers/company/auth.dart';
import 'package:e_pay_gateway/controllers/company/company_controller.dart';
import 'package:e_pay_gateway/controllers/company/token_controller.dart';
import 'package:e_pay_gateway/controllers/third_parties/mpesa_controllers/buy_goods_servisesController.dart';
import 'package:e_pay_gateway/controllers/third_parties/mpesa_controllers/deposit_request_controller.dart';
import 'package:e_pay_gateway/controllers/third_parties/mpesa_controllers/paybill_controller.dart';
import 'package:e_pay_gateway/controllers/third_parties/mpesa_controllers/transfer_to_phone_controller.dart';
import 'package:e_pay_gateway/controllers/wallet/wallet_mpesa_buy_goods_services.dart';
import 'package:e_pay_gateway/controllers/wallet/wallet_mpesa_paybill.dart';
import 'package:e_pay_gateway/controllers/wallet/wallet_mpesa_phone_no.dart';
import 'package:e_pay_gateway/controllers/wallet/wallet_wallet.dart';
import 'package:e_pay_gateway/models.dart/token_model.dart';

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
      .route("/")
    .linkFunction((request)async{
      // return pesaLinkTransact();
      final TokenModel tokenModel = TokenModel();
      return Response.ok(await tokenModel.verifyToken("CDANv5SDFV2PYuFLFLXO"));
      // return Response.ok(await tokenModel.getToken(owner: "wallets/companies/5d9f4c5396369ead33772e64"));
    });

    // Accounts
    // consumer
    router
      .route("accounts/consumer/:accountId")
    .link(() => ConsumerAccountController());
    // merchant
    router
      .route("accounts/merchant/:accountId")
    .link(() => MerchantAccountController());
    
    
    // Company
    router
      .route('/token')
      .link(() => Authorizer.basic(PasswordVerifier()))
      .link(() => TokenController());



    router
      .route("/companies/[:accountId]")
    .link(() => CompaniesController());



    // Mpesa only
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


    
    // Wallet 
    router
      .route('/wallet/thirdParties/mpesa/paybill')
      .link(() => WalletMpesaPaybillController());
    router
      .route('/wallet/thirdParties/mpesa/buygoodsServices')
      .link(() => WalletMpesaBuyGoodsServicesController());
    router
      .route('/wallet/thirdParties/mpesa/transfertoPhone')
      .link(() => WalletMpesaPhoneNoController());
    router
      .route("/wallet/wallet/transfer")
      .link(() => WalletWalletController());


    return router;
  }
}
