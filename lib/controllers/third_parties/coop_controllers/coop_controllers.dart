import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/cooperative%20bank/internal_funds_transfer_serializer.dart';
import 'package:e_pay_gateway/serializers/cooperative%20bank/pesalink_serializer.dart';
import 'package:e_pay_gateway/third_party_operations/coop_bank_operations/internal_funds_transfer_operations.dart';
import 'package:e_pay_gateway/third_party_operations/coop_bank_operations/pesalink_operations.dart';

class PesaLinkSendController extends ResourceController{
  @Operation.post()
  Future<Response> transact(@Bind.body() PesalinkSerializer _pesalinkSerializer)async{
    final PesalinkOperations _pesalink = PesalinkOperations(
      accountNumber: _pesalinkSerializer.accountNumber,
      amount: _pesalinkSerializer.amount,
      transactionCurrency: _pesalinkSerializer.transactionCurrency,
      narration: _pesalinkSerializer.narration
    );
    final _response = await _pesalink.send;

    return Response.ok(_response);
  }
}

class PesaLinkReceiveController extends ResourceController{
  @Operation.post()
  Future<Response> transact(@Bind.body() PesalinkSerializer _pesalinkSerializer)async{
    final PesalinkOperations _pesalink = PesalinkOperations(
      accountNumber: _pesalinkSerializer.accountNumber,
      amount: _pesalinkSerializer.amount,
      transactionCurrency: _pesalinkSerializer.transactionCurrency,
      narration: _pesalinkSerializer.narration
    );
    final _response = await _pesalink.receive;

    return Response.ok(_response);
  }
}

class CoopInternalFundsTransferSendController extends ResourceController{
  @Operation.post()
  Future<Response> transact(@Bind.body() InternalFundsTransferSerializer _iftSerializer)async{
    final CoopInternalFundsTransferOperations _ift = CoopInternalFundsTransferOperations(
      accountNumber: _iftSerializer.accountNumber,
      amount: _iftSerializer.amount,
      transactionCurrency: _iftSerializer.transactionCurrency,
      narration: _iftSerializer.narration
    );
    final _response = await _ift.send;

    return Response.ok(_response);
  }
}

class CoopInternalFundsTransferReceiveController extends ResourceController{
  @Operation.post()
  Future<Response> transact(@Bind.body() InternalFundsTransferSerializer _iftSerializer)async{
    final CoopInternalFundsTransferOperations _ift = CoopInternalFundsTransferOperations(
      accountNumber: _iftSerializer.accountNumber,
      amount: _iftSerializer.amount,
      transactionCurrency: _iftSerializer.transactionCurrency,
      narration: _iftSerializer.narration
    );
    final _response = await _ift.receive;

    return Response.ok(_response);
  }
}