import 'dart:developer';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/log.dart';

class MeterImageHelper {
  final ImagePicker _picker = ImagePicker();

  Future<String?> selectAndSaveImage(ImageSource mode) async {
    final XFile? image = await _picker.pickImage(source: mode);

    if (image == null) return null;

    return await _saveImage(image);
  }

  Future<Directory> _createDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();

    final finalDir = Directory('${appDir.path}/images/');

    if (await finalDir.exists()) {
      return finalDir;
    } else {
      log(
          name: LogNames.meterImageHelper,
          'Create image directory on path: ${finalDir.path}');

      return await finalDir.create(recursive: true);
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

    final Directory appDir = await _createDirectory();

    try {
      String imagePath = '${appDir.path}/$filename';
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
    final dir = await _createDirectory();

    final items = dir.listSync();

    return items.isNotEmpty;
  }

  Future<Directory> getDir() async {
    return await _createDirectory();
  }

  Future<void> deleteFolder() async {
    final dir = await _createDirectory();

    dir.deleteSync(recursive: true);
  }

  Future<int> getFolderSize() async {
    final dir = await _createDirectory();

    var files = dir.listSync(recursive: true);

    int dirSize = 0;

    for (var file in files) {
      dirSize += file.statSync().size;
    }

    return dirSize;
  }

  Future<int> getFolderLength() async {
    final dir = await _createDirectory();

    return dir.listSync(recursive: true).length;
  }
}
