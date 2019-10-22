import 'dart:convert';

import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/mpesa%20models/mpesa_responses_model.dart';

class FetchAllMpesaResponsesController extends ResourceController{
  @Operation.get()
  Future<Response> fetchAllMpesaResponses()async{
    MpesaResponsesModel _mpesaResponsesModel = MpesaResponsesModel();
    Map<String, dynamic> _res = await _mpesaResponsesModel.findAll();
    // TODO: Check if status is 0
    return Response.ok(_res['body']);
  }
}

class FetchMpesaResponsesByAccRefController extends ResourceController{
  @Operation.get('accRef')
  Future<Response> fetchAllMpesaResponses(@Bind.path("accRef") String accRef)async{
    MpesaResponsesModel _mpesaResponsesModel = MpesaResponsesModel();
    Map<String, dynamic> _res = await _mpesaResponsesModel.findByAccRef(accRef);
    // TODO: Check if status is 0
    return Response.ok(_res['body']);
  }
}

class FetchMpesaResponsesByMpesaRefController extends ResourceController{
  @Operation.get('mpesaRef')
  Future<Response> fetchAllMpesaResponses(@Bind.path("mpesaRef") String mpesaRef)async{
    MpesaResponsesModel _mpesaResponsesModel = MpesaResponsesModel();
    Map<String, dynamic> _res = await _mpesaResponsesModel.findByMpesaReceiptNumber(mpesaRef);
    // TODO: Check if status is 0
    return Response.ok(_res['body']);
  }
}