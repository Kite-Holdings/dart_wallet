import 'package:e_pay_gateway/utils/database_bridge.dart';

class StkProcessModel{

  StkProcessModel({
    this.processId,
    this.processState,
    this.requestId,
    this.checkoutRequestID
  });

  final String processId;
  final ProcessState processState;
  final String requestId;
  final String checkoutRequestID;
  DateTime timeInitiated;

  final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'stkPushProcesses');

  void create()async{
    timeInitiated = DateTime.now();
    await _databaseBridge.save({
      'processState': processStateValue(),
      'requestId': requestId,
      'checkoutRequestID': checkoutRequestID,
      'timeInitiated': timeInitiated
    });
  }

  void updateProcessStateById() async {
    await _databaseBridge.findAndModify(
      selector: where.id(ObjectId.parse(processId)), 
      modify: modify.set('processState', processStateValue())
    );
  }

  void updateProcessStateByRequestId() async {
    await _databaseBridge.findAndModify(
      selector: where.eq('requestId', requestId), 
      modify: modify.set('processState', processStateValue())
    );
  }

  void updateProcessStateByCheckoutRequestID() async {
    await _databaseBridge.findAndModify(
      selector: where.eq('checkoutRequestID', checkoutRequestID), 
      modify: modify.set('processState', processStateValue())
    );
  }

  Future<bool> isPending()async{
    final Map _queryRes = await _databaseBridge.findOneBy(where.eq('requestId', requestId),);
    return _queryRes['processState']== 'pending';
  }



  String processStateValue(){
    switch (processState) {
      case ProcessState.pending:
        return 'pending';
        break;
      case ProcessState.cancel:
        return 'cancel';
        break;
      case ProcessState.complete:
        return 'complete';
        break;
      case ProcessState.failed:
        return 'failed';
        break;
      case ProcessState.terminated:
        return 'terminated';
        break;
      default:
        return 'undefiened';
    }
  }

}

enum ProcessState{
  pending,
  cancel,
  complete,
  failed,
  terminated
}