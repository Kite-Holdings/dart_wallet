import 'dart:math';

import 'package:e_pay_gateway/controllers/accounts/account_controller.dart';
import 'package:e_pay_gateway/controllers/accounts/accounts_Login_controller.dart';
import 'package:e_pay_gateway/controllers/accounts/consumer_account_controller.dart';
import 'package:e_pay_gateway/controllers/accounts/merchant_account_controllewr.dart';
import 'package:e_pay_gateway/controllers/company/auth.dart';
import 'package:e_pay_gateway/controllers/company/company_controller.dart';
import 'package:e_pay_gateway/controllers/company/token_controller.dart';
import 'package:e_pay_gateway/controllers/responses/fetch_mpesa_responses.dart';
import 'package:e_pay_gateway/controllers/responses/flutterwave_response_controller.dart';
import 'package:e_pay_gateway/controllers/responses/mpesa_responses.dart';
import 'package:e_pay_gateway/controllers/third_parties/coop_controllers/coop_controllers.dart';
import 'package:e_pay_gateway/controllers/third_parties/flutter_wave/flutterwave_card_controller.dart';
import 'package:e_pay_gateway/controllers/third_parties/mpesa_controllers/buy_goods_servisesController.dart';
import 'package:e_pay_gateway/controllers/third_parties/mpesa_controllers/deposit_request_controller.dart';
import 'package:e_pay_gateway/controllers/third_parties/mpesa_controllers/paybill_controller.dart';
import 'package:e_pay_gateway/controllers/third_parties/mpesa_controllers/stk_push_query_request_controller.dart';
import 'package:e_pay_gateway/controllers/third_parties/mpesa_controllers/transfer_to_phone_controller.dart';
import 'package:e_pay_gateway/controllers/wallet/wallet_mpesa_buy_goods_services.dart';
import 'package:e_pay_gateway/controllers/wallet/wallet_mpesa_paybill.dart';
import 'package:e_pay_gateway/controllers/wallet/wallet_mpesa_phone_no.dart';
import 'package:e_pay_gateway/controllers/wallet/wallet_wallet.dart';
import 'package:e_pay_gateway/html_template/card_success.dart';
import 'package:e_pay_gateway/third_party_operations/airtel_kenya/enroll.dart';
import 'package:e_pay_gateway/third_party_operations/cellulant/validate_account.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/c_b_deposit.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/stkPushQueryRequest.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';
import 'package:http/io_client.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';


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
      .link(() => Authorizer.bearer(BearerAouthVerifier()))
      .linkFunction((request)async{
      return Response.ok({'message': "Hello"});
    });

    router
      .route("/cardSuccess")
      .linkFunction((request)async{
        var response = Response.ok(htmlTemplate)
          ..contentType = ContentType.html;
      return response;
    });
    // test
    router
      .route("/test")
      .linkFunction((request)async{
      print(await request.body.decode());
      return Response.ok({'hi': 'hi'});
    });
    // test
    router
      .route("/success")
      .linkFunction((request)async{
      return Response.ok({"message": "done!"});
    });

    // milk test
    router
      .route("/maziwa")
      .linkFunction((request)async{
      final _req = await request.body.decode();
      final _mRes = await depositRequest(
        phoneNo: _req['phoneNo'].toString(),
        amount: _req['amount'].toString(),
        accRef: '001100000001',
        callBackUrl: 'https://e106e561.ngrok.io/test',
        transactionDesc: 'Buy milk',
        referenceNumber: 'maziwa',
        optinalCallback: 'http://18.189.117.13:2011/maziwa/response/${_req["email"].toString()}'
      );
      return Response.ok(_mRes);
    });

    // milik test response
    router
    .route('/maziwa/response/:email')
    .linkFunction((request) async {
      Map<String, dynamic> _body = await request.body.decode();
      if(_body['Body'] != null && _body['Body']['stkCallback'] != null && _body['Body']['stkCallback']['ResultCode'] == 0){
        final Random _r = Random();
        String username = 'elyudde@gmail.com';
        String password = 'Edd13g3niu5';
        final smtpServer = gmail(username, password);
        final message = Message()
          ..from = Address(username, 'Kite Holdings ltd')
          ..recipients.add(request.path.variables['email'])
          ..bccRecipients.add(Address('eliud.kamau@kiteholdings.biz'))
          ..subject = 'Bought milk'
          ..text = (1000 + _r.nextInt(9999 - 1000)).toString();

        try {
          final sendReport = await send(message, smtpServer);
        } on MailerException catch (e) {
          print('Message not sent.');
          print(e);
        }
      }

      return Response.ok("done!");
    });

    // report
    router
      .route("/requestM")
      .linkFunction((request)async{
        DatabaseBridge _dbb = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'mpesaCallbackUrls');
        final Map<String, dynamic> _map = await _dbb.find();
        final _newmap = _map['body'].map((item){
          final ObjectId _id = ObjectId.parse(item['_id'].toString().split('"')[1]);
          item['date'] = _id.dateTime.toString();
          return item;
        }).toList();
      return Response.ok(_newmap);
    });
    router
      .route("/requests")
      .linkFunction((request)async{
        DatabaseBridge _dbb = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'allRequests');
        final Map<String, dynamic> _map = await _dbb.find();
        final _newmap = _map['body'].map((item){
          final ObjectId _id = ObjectId.parse(item['_id'].toString().split('"')[1]);
          item['date'] = _id.dateTime.toString();
          return item;
        }).toList();
      return Response.ok(_newmap);
    }); 
    router
      .route("/responses")
      .linkFunction((request)async{
        DatabaseBridge _dbb = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'allResponses');
        final Map<String, dynamic> _map = await _dbb.find();
        final _newmap = _map['body'].map((item){
          final ObjectId _id = ObjectId.parse(item['_id'].toString().split('"')[1]);
          item['date'] = _id.dateTime.toString();
          return item;
        }).toList();
      return Response.ok(_newmap);
    });

    // Accounts
    // consumer
    router
      .route("accounts/consumer/[:accountId]")
      .link(() => Authorizer.bearer(BearerAouthVerifier()))
    .link(() => ConsumerAccountController());
    // merchant
    router
      .route("accounts/merchant/[:accountId]")
      .link(() => Authorizer.bearer(BearerAouthVerifier()))
    .link(() => MerchantAccountController());
    // Login
    router
      .route('/accounts/login')
      .link(() => Authorizer.basic(AccountLoginIdentifier()))
      .link(() => AccountsLoginController());

    router
      .route('/account')
      .link(() => Authorizer.bearer(BearerAouthVerifier()))
      .link(()=> AccountController());



    //////////////// Third parties ///////////////////
    ///
    
    // Airtel
    router
      .route('/airtel')
      .linkFunction((request){
        airtelEnrol();
        return Response.accepted();
      });

    // Cellulant
    router
      .route('/thirdParties/cellulant/validateAcc')
      .linkFunction((request) async{
        final ValidateAccount _validateAccount = ValidateAccount();
        return Response.ok(await _validateAccount.validate());
      });
    
    
    // Company
    router
      .route('/token')
      .link(() => Authorizer.basic(BasicAouthVerifier()))
      .link(() => TokenController());



    router
      .route("/companies/[:companyId]")
    .link(() => CompaniesController());

    // Cooperative Bank
    // pesalink send
    router
      .route('/thirdParties/coop/peaslink/send')
      .link(() => PesaLinkSendController());

    // pesalink receive
    router
      .route('/thirdParties/coop/peaslink/receive')
      .link(() => PesaLinkReceiveController());

    // internal funds transfer send
    router
      .route('/thirdParties/coop/ift/send')
      .link(() => CoopInternalFundsTransferSendController());

    // internal funds transfer receive
    router
      .route('/thirdParties/coop/ift/receive')
      .link(() => CoopInternalFundsTransferReceiveController());


    // Flutterwave
    // card deposit
    router
      .route('/thirdParties/cardPayment')
      .link(() => Authorizer.bearer(BearerAouthVerifier()))
      .link(()=> FlutterwaveCardController());
    // wallet  card
    router
      .route('/thirdParties/cardToWallet')
      .link(() => Authorizer.bearer(BearerAouthVerifier()))
      .link(()=> FlutterwaveWalletCardController());



    // Mpesa only
    router
      .route('/thirdParties/mpesa/paybill')
      // .link(() => Authorizer.bearer(BearerAouthVerifier()))
      .link(() => PaybillController());
    router
      .route('/thirdParties/mpesa/buygoodsServices')
      // .link(() => Authorizer.bearer(BearerAouthVerifier()))
      .link(() => BuyGoodsServicesController());
    router
      .route('/thirdParties/mpesa/transfertoPhone')
      // .link(() => Authorizer.bearer(BearerAouthVerifier()))
      .link(() => TransferPhoneController());
    router
      .route("/thirdParties/mpesa/depositRequest")
      // .link(() => Authorizer.bearer(BearerAouthVerifier()))
      .link(() => DepositRequestController());
    // stkquerrequest
    router
      .route('//thirdParties/mpesa/stkQueryRequest')
      .link(() => StkPushQueryRequestController());

    
    // Responses
    // callback
    router
      .route("/mResponces/cb/[:requestId]")
      .link(() => MpesaStkCallbackController());
    router
      .route("/flutterWaveResponse")
      .link(()=> FlutterWaveResponseController());


    // get all responses
    router
      .route("/mpesaResponces")
      .link(() => FetchAllMpesaResponsesController());
    // get responses by account refference
    router
      .route("/mpesaResponces/accRef/[:accRef]")
      .link(() => FetchMpesaResponsesByAccRefController());
    // get responses by mpesa refference
    router
      .route("/mpesaResponces/mpesaRef/[:mpesaRef]")
      .link(() => FetchMpesaResponsesByMpesaRefController());


    
    // Wallet 
    router
      .route('/wallet/thirdParties/mpesa/paybill')
      .link(() => Authorizer.bearer(BearerAouthVerifier()))
      .link(() => WalletMpesaPaybillController());
    router
      .route('/wallet/thirdParties/mpesa/buygoodsServices')
      .link(() => Authorizer.bearer(BearerAouthVerifier()))
      .link(() => WalletMpesaBuyGoodsServicesController());
    router
      .route('/wallet/thirdParties/mpesa/transfertoPhone')
      .link(() => Authorizer.bearer(BearerAouthVerifier()))
      .link(() => WalletMpesaPhoneNoController());
    router
      .route("/wallet/wallet/transfer")
      .link(() => Authorizer.bearer(BearerAouthVerifier()))
      .link(() => WalletWalletController());


      // wallet transactions
      router
        .route('/wallet/transactions/:walletNo')
        .linkFunction((request)async{
          final DatabaseBridge _dbb = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'transactions');
          final Map<String, dynamic> _map = await _dbb.findBy(
            where.eq('senderInfo.walletDetails.walletNo', request.path.variables['walletNo'])
            .or(where.eq('recipientInfo.walletDetails.walletNo', request.path.variables['walletNo'])));
          final _newmap = _map['body'].map((item){
            item['senderInfo']['timeStamp'] = item['senderInfo']['timeStamp'].toString();
            item['recipientInfo']['timeStamp'] = item['recipientInfo']['timeStamp'].toString();
            return item;
          }).toList();
          return Response.ok(_newmap);
        });


    return router;
  }
}
