import 'dart:async';

import 'package:flutter/services.dart';

class ImageGallerySaverPlus {
  static const MethodChannel _channel = const MethodChannel(
    'image_gallery_saver_plus',
  );

  /// save image to Gallery
  /// imageBytes can't null
  /// [creationDate] optional. When provided (iOS only), the asset is imported
  /// through PHPhotoLibrary and its creation date shown in Photos is set to
  /// this value.
  /// return Map type
  /// for example:{"isSuccess":true, "filePath":String?}
  static FutureOr<dynamic> saveImage(
    Uint8List imageBytes, {
    int quality = 80,
    String? name,
    bool isReturnImagePathOfIOS = false,
    DateTime? creationDate,
  }) async {
    final result = await _channel
        .invokeMethod('saveImageToGallery', <String, dynamic>{
          'imageBytes': imageBytes,
          'quality': quality,
          'name': name,
          'isReturnImagePathOfIOS': isReturnImagePathOfIOS,
          'creationDate': creationDate?.millisecondsSinceEpoch,
        });
    return result;
  }

  /// Save the PNG，JPG，JPEG image or video located at [file] to the local device media gallery.
  /// [creationDate] optional. When provided (iOS only), the asset is imported
  /// through PHPhotoLibrary and its creation date shown in Photos is set to
  /// this value (works for both images and videos).
  static Future saveFile(
    String file, {
    String? name,
    bool isReturnPathOfIOS = false,
    DateTime? creationDate,
  }) async {
    final result = await _channel
        .invokeMethod('saveFileToGallery', <String, dynamic>{
          'file': file,
          'name': name,
          'isReturnPathOfIOS': isReturnPathOfIOS,
          'creationDate': creationDate?.millisecondsSinceEpoch,
        });
    return result;
  }
}
