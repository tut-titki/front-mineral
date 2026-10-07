import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'reference_storage.dart';

ReferenceStorage createStorage() => FileReferenceStorage();

class FileReferenceStorage implements ReferenceStorage {
  FileReferenceStorage({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationSupportDirectory;
  final Future<Directory> Function() _directory;
  Future<File> _file(String key) async {
    final root = await _directory();
    final folder = Directory('${root.path}/references');
    await folder.create(recursive: true);
    return File('${folder.path}/${base64Url.encode(utf8.encode(key))}.json');
  }

  @override
  Future<List<Map<String, dynamic>>?> read(String key) async {
    final file = await _file(key);
    if (!await file.exists()) return null;
    final value = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    if (value['version'] != 1) return null;
    return (value['items'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  @override
  Future<void> write(String key, List<Map<String, dynamic>> items) async {
    final file = await _file(key);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      jsonEncode({'version': 1, 'items': items}),
      flush: true,
    );
    await temporary.rename(file.path);
  }
}
