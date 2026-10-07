import 'reference_storage_stub.dart'
    if (dart.library.io) 'reference_storage_io.dart'
    as platform;

abstract interface class ReferenceStorage {
  Future<List<Map<String, dynamic>>?> read(String key);
  Future<void> write(String key, List<Map<String, dynamic>> items);
}

ReferenceStorage createReferenceStorage() => platform.createStorage();
