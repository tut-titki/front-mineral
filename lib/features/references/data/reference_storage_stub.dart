import 'reference_storage.dart';

ReferenceStorage createStorage() => MemoryReferenceStorage();

class MemoryReferenceStorage implements ReferenceStorage {
  final _items = <String, List<Map<String, dynamic>>>{};
  @override
  Future<List<Map<String, dynamic>>?> read(String key) async => _items[key];
  @override
  Future<void> write(String key, List<Map<String, dynamic>> items) async {
    _items[key] = items;
  }
}
