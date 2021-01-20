import 'package:myuwi/Repository/Intefaces/ILocalStorageRepository.dart';
import 'package:flutter/foundation.dart';

class LocalStorageService {
  LocalStorageService(
      {@required ILocalStorageRepository localStorageRepository})
      : _localStorageRepository = localStorageRepository;

  ILocalStorageRepository _localStorageRepository;

  Future<dynamic> getAll(String key) async {
    return await _localStorageRepository.getAll(key);
  }

  Future<void> save(String key, dynamic item) async {
    await _localStorageRepository.save(key, item);
  }
}
