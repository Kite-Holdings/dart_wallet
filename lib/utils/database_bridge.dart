import 'package:mongo_dart/mongo_dart.dart';
export 'package:mongo_dart/mongo_dart.dart' show where, ObjectId, modify;
export 'package:e_pay_gateway/settings/settings.dart' show databaseUrl,databaseName;

class DatabaseBridge{

  DatabaseBridge({
    this.dbUrl,
    this.collectionName
  }){
    _db = Db(dbUrl);
    _dbCollection = _db.collection(collectionName);
  }

  final String dbUrl;
  final String collectionName;
  Db _db;
  DbCollection _dbCollection;

  // Save
  Future<Map<String, dynamic>> save(Map<String, dynamic> obj) async {
    return await _inserOpertations(obj, OpertationType.save);
  }

  // Insert
  Future<Map<String, dynamic>> insert(Map<String, dynamic> obj) async {
    return await _inserOpertations(obj, OpertationType.insert);
  }

  // Update
  Future<Map<String, dynamic>> update(SelectorBuilder selector, ModifierBuilder modifier) async {
    final Map<String, dynamic> _response = {};
    await _db.open();
    try{
      _response['body'] = await _dbCollection.update(selector, modifier);
      await _db.close();
      _response['status'] = '0';
    } catch (e){
      await _db.close();
      _response['status'] = '1';
      _response['body'] = e;
    }
    return _response;
  }
  // find and update
  Future<Map<String, dynamic>> findAndModify({SelectorBuilder selector, modify}) async {
    final Map<String, dynamic> _response = {};
    await _db.open();
    try{
      _response['body'] = await _dbCollection.findAndModify(query: selector, update: modify, returnNew: true);
      await _db.close();
      _response['status'] = '0';
    } catch (e){
      await _db.close();
      _response['status'] = '1';
      _response['body'] = e;
    }
    return _response;
  }

  // TODO: Delete

  // Find one
  Future<Map<String, dynamic>> findOneBy(SelectorBuilder selector) async {
    await _db.open();
    final Map<String, dynamic> _m =await _dbCollection.findOne(selector);
    await _db.close();
    return _m;
    // return _findOpertations(selector, OpertationType.findOne);
  }

  // Find by
  Future<Map<String, dynamic>> findBy([SelectorBuilder selector]) async {
    return _findOpertations(selector, OpertationType.findBy);
  }

  // Find all
  Future<Map<String, dynamic>> find([SelectorBuilder selector]) async {
    return _findOpertations(selector, OpertationType.findAll);
  }

  // Exist
  Future<bool> exists(SelectorBuilder selector)async{
    await _db.open();
    final int _count = await _dbCollection.count(selector);
    await _db.close();
    return _count > 0;
  }

  // Insert opertation
  Future<Map<String, dynamic>> _inserOpertations(Map<String, dynamic> obj, OpertationType opertationType) async {
    final Map<String, dynamic> _response = {};
    await _db.open();
    try{
      switch (opertationType) {
        case OpertationType.save:
          _response['body'] = await _dbCollection.insert(obj);
          
          break;
        case OpertationType.insert:
          _response['body'] = await _dbCollection.insert(obj);
          break;
        default:
          _response['body'] = {};
      }
      await _db.close();
      _response['status'] = '0';
    } catch (e){
      await _db.close();
      _response['status'] = '1';
      _response['body'] = e;
    }
    return _response;
  }

  // Find opertation
  Future<Map<String, dynamic>> _findOpertations(SelectorBuilder selector, OpertationType opertationType) async {
    final Map<String, dynamic> _response = {};
    final List<Map<String, dynamic>> _responsesList = [];
    Stream<Map<String, dynamic>> _dataStream;
    await _db.open();
    try{
      switch (opertationType) {
        case OpertationType.findAll:
          _dataStream = _dbCollection.find();
          break;
        case OpertationType.findOne:
          _dataStream = _dbCollection.find(selector);
          break;
        case OpertationType.findBy:
          _dataStream = _dbCollection.find(selector);
          break;
        default:
          _dataStream = null;
      }
      await _dataStream.forEach(_responsesList.add);
      _response['body'] = _responsesList;
      await _db.close();
      _response['status'] = '0';

    } catch (e){
      await _db.close();
      _response['status'] = '1';
      _response['body'] = e;
    }
    return _response;
  }
}

enum OpertationType{
  save,
  insert,
  update,
  delete,
  findAll,
  findOne,
  findBy
}