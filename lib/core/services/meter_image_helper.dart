import 'dart:developer';
import 'dart:io';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/log.dart';

class MeterImageHelper {
  Directory? _saveDir;

  final ImagePicker _picker = ImagePicker();

  Future<String?> selectAndSaveImage(ImageSource mode) async {
    final XFile? image = await _picker.pickImage(source: mode);

    if (image == null) return null;

    return await _saveImage(image);
  }

  Future<void> createDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();

    _saveDir = Directory('${appDir.path}/images/');

    if (!_saveDir!.existsSync()) {
      log(
          name: LogNames.meterImageHelper,
          'Create image directory on path: ${_saveDir!.path}');

      _saveDir!.create(recursive: true);
    }
  }

  String _getDateTime() {
    final DateTime now = DateTime.now();

    return '${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}';
  }

  Future<String?> _saveImage(XFile image) async {
    String filename = basename(image.path);

    if (filename.length > 30) {
      final RegExp exp = RegExp(r'\.(.+)$');
      final fileEnd = exp.firstMatch(filename);

      filename = 'metercount_${_getDateTime()}.${fileEnd![1]}';
    }

    try {
      String imagePath = '${_saveDir!.path}$filename';
      await image.saveTo(imagePath);

      log(
          name: LogNames.meterImageHelper,
          'Image was successfully saved to the new path');

      return imagePath;
    } catch (e) {
      log(
          name: LogNames.meterImageHelper,
          'Error while save Image to new path: $e');

      return null;
    }
  }

  Future<void> deleteImage(String imagePath) async {
    File image = File(imagePath);

    try {
      await image.delete();

      log(
          name: LogNames.meterImageHelper,
          'Successfully deleted image: $imagePath');
    } catch (e) {
      log(
          name: LogNames.meterImageHelper,
          'Error while deleted image at path $imagePath: $e');
    }
  }

  Future<bool> imagesExists() async {
    final items = _saveDir!.listSync();

    return items.isNotEmpty;
  }

  Future<Directory?> getDir() async {
    return _saveDir;
  }

  Future<void> deleteFolder() async {
    if (_saveDir != null) {
      _saveDir!.deleteSync(recursive: true);

      _saveDir = null;
    }
  }

  Future<int> getFolderSize() async {
    if (_saveDir == null) {
      return 0;
    }

    var files = _saveDir!.listSync(recursive: true);

    int dirSize = 0;

    for (var file in files) {
      dirSize += file.statSync().size;
    }

    return dirSize;
  }

  Future<int> getFolderLength() async {
    if (_saveDir == null) {
      return 0;
    }
    return _saveDir!.listSync(recursive: true).length;
  }

  saveImageToGallery(File image) async {
    var result = await ImageGallerySaver.saveImage(
      image.readAsBytesSync(),
    );

    if (result['isSuccess']) {
      return true;
    } else {
      return false;
    }
  }
}
