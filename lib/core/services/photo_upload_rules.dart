const maxPhotoBytes = 15 * 1024 * 1024;

class PhotoTooLargeException implements Exception {
  const PhotoTooLargeException();
}

void validatePhotoSize(int length) {
  if (length > maxPhotoBytes) throw const PhotoTooLargeException();
  if (length == 0) throw const FormatException('Пустой файл изображения');
}
