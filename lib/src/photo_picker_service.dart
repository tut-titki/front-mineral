import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'models.dart';

class PhotoPickerService {
  static final instance = PhotoPickerService();
  final _picker = ImagePicker();
  Future<List<OrderPhoto>>? _recovery;
  bool _recoveryTaken = false;

  bool get supportsCamera =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<List<OrderPhoto>> pickCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
      requestFullMetadata: false,
    );
    return image == null ? [] : [await _read(image)];
  }

  Future<List<OrderPhoto>> pickGallery(int remaining) async {
    if (remaining <= 0) return [];
    if (remaining == 1) {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
        requestFullMetadata: false,
      );
      return image == null ? [] : [await _read(image)];
    }
    final images = await _picker.pickMultiImage(
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
      limit: remaining,
      requestFullMetadata: false,
    );
    return Future.wait(images.take(remaining).map(_read));
  }

  void recoverLostPhotos() {
    _recovery ??= _recover();
  }

  Future<List<OrderPhoto>> takeRecoveredPhotos() async {
    recoverLostPhotos();
    final images = await _recovery!;
    if (_recoveryTaken) return [];
    _recoveryTaken = true;
    return images.take(5).toList();
  }

  Future<List<OrderPhoto>> _recover() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return [];
    try {
      final response = await _picker.retrieveLostData();
      return await Future.wait((response.files ?? []).take(5).map(_read));
    } on PlatformException {
      return [];
    } on MissingPluginException {
      return [];
    } on Exception {
      return [];
    }
  }

  Future<OrderPhoto> _read(XFile file) async {
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) throw const FormatException('Пустой файл изображения');
    return OrderPhoto(name: file.name, bytes: bytes);
  }
}
