import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/request_responses/requests_model.dart';
import 'package:e_pay_gateway/serializers/flutter_wave/flutterwave_card_serializer.dart';
import 'package:e_pay_gateway/third_party_operations/flutter_wave/card_transaction.dart';

class FlutterwaveCardController extends ResourceController{
  @Operation.post()
  Future<Response> cardTransact(@Bind.body() FlutterwaveCardSerializer _flutterwaveCardSerializer)async{
    final FlutterWaveCardDeposit _flutterwaveCard = FlutterWaveCardDeposit(
      cardNo: _flutterwaveCardSerializer.cardNo,
      cvv: _flutterwaveCardSerializer.cvv,
      expiryMonth: _flutterwaveCardSerializer.expiryMonth,
      expiryYear: _flutterwaveCardSerializer.expiryYear,
      currency: _flutterwaveCardSerializer.currency,
      country: _flutterwaveCardSerializer.country,
      amount: _flutterwaveCardSerializer.amount,
      email: _flutterwaveCardSerializer.email,
      reference: _flutterwaveCardSerializer.reference,
      callbackUrl: _flutterwaveCardSerializer.callbackUrl,
      uid: request.authorization.clientID,
      requestTransactionType: RequestTransactionType.wallet
    );

    final _response = await _flutterwaveCard.flutterWaveCardTransact();

    return Response.ok(_response);
  }
}

class FlutterwaveWalletCardController extends ResourceController{
  @Operation.post()
  Future<Response> cardTransact(@Bind.body() FlutterwaveCardSerializer _flutterwaveCardSerializer)async{
    final FlutterWaveCardDeposit _flutterwaveCard = FlutterWaveCardDeposit(
      cardNo: _flutterwaveCardSerializer.cardNo,
      cvv: _flutterwaveCardSerializer.cvv,
      expiryMonth: _flutterwaveCardSerializer.expiryMonth,
      expiryYear: _flutterwaveCardSerializer.expiryYear,
      currency: _flutterwaveCardSerializer.currency,
      country: _flutterwaveCardSerializer.country,
      amount: _flutterwaveCardSerializer.amount,
      email: _flutterwaveCardSerializer.email,
      reference: _flutterwaveCardSerializer.reference,
      callbackUrl: _flutterwaveCardSerializer.callbackUrl,
      uid: request.authorization.clientID,
      requestTransactionType: RequestTransactionType.wallet
      
    );

    final _response = await _flutterwaveCard.flutterWaveCardTransact();

    return Response.ok(_response);
  }
}

