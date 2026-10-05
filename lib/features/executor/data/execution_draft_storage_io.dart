import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:mineral/shared/models/models.dart';
import 'execution_draft_storage.dart';
import 'executor_repository.dart';

ExecutionDraftStorage createStorage() => FileExecutionDraftStorage();

class FileExecutionDraftStorage implements ExecutionDraftStorage {
  FileExecutionDraftStorage({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationSupportDirectory;
  final Future<Directory> Function() _directory;
  Future<void> _pending = Future.value();

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<File> _file(int employeeId, int number) async {
    final root = await _directory();
    final folder = Directory('${root.path}/execution_drafts');
    await folder.create(recursive: true);
    return File('${folder.path}/${employeeId}_$number.json');
  }

  @override
  Future<ExecutionDraft?> load(
    int employeeId,
    int orderNumber,
  ) => _serial(() async {
    final file = await _file(employeeId, orderNumber);
    if (!await file.exists()) return null;
    final value = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    if (value['version'] != 1) {
      throw const FormatException('Unsupported draft version');
    }
    final materials = (value['materials'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );
    if (materials.values.any((v) => !v.isFinite || v <= 0)) {
      throw const FormatException('Invalid material quantity');
    }
    final photos = (value['photos'] as List)
        .map(
          (v) => OrderPhoto(
            name: v['name'] as String,
            bytes: base64Decode(v['bytes'] as String),
          ),
        )
        .toList();
    if (photos.length > 5) throw const FormatException('Invalid photo count');
    return ExecutionDraft(
      work: value['work'] as String,
      faultCode: value['faultCode'] as String,
      comment: value['comment'] as String,
      legacyMaterials: value['legacyMaterials'] as String,
      materials: materials,
      photos: photos,
    );
  });

  @override
  Future<void> save(int employeeId, int orderNumber, ExecutionDraft draft) =>
      _serial(() async {
        final file = await _file(employeeId, orderNumber);
        final temporary = File('${file.path}.tmp');
        await temporary.writeAsString(
          jsonEncode({
            'version': 1,
            'work': draft.work,
            'faultCode': draft.faultCode,
            'comment': draft.comment,
            'legacyMaterials': draft.legacyMaterials,
            'materials': draft.materials,
            'photos': draft.photos
                .map((p) => {'name': p.name, 'bytes': base64Encode(p.bytes)})
                .toList(),
          }),
          flush: true,
        );
        await temporary.rename(file.path);
      });

  @override
  Future<void> remove(int employeeId, int orderNumber) => _serial(() async {
    final file = await _file(employeeId, orderNumber);
    if (await file.exists()) await file.delete();
  });
}
