import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class TorchController {
  static const _channel = MethodChannel('com.example.openmeter/main');
  static const _enableTorch = 'enableTorch';
  static const _disableTorch = 'disableTorch';
  static const _torchAvailable = 'torchAvailable';
  bool _torch = false;

  TorchController();

  bool get stateTorch => _torch;

  Future<bool> _isTorchAvailable() async {
    try {
      return await _channel.invokeMethod(_torchAvailable) as bool;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('EnableTorch: ${e.message}');
      }
      return false;
    }
  }

  Future<void> getTorch() async {
    bool torchAvailable = await _isTorchAvailable();

    if (!torchAvailable) {
      return;
    }

    _toggleTorch();

    if (_torch) {
      try {
        await _channel.invokeMethod(_enableTorch);
      } on PlatformException catch (e) {
        if (kDebugMode) {
          print('TorchException: ${e.message}');
        }
      }
    } else {
      try {
        await _channel.invokeMethod(_disableTorch);
      } on PlatformException catch (e) {
        if (kDebugMode) {
          print('TorchException: ${e.message}');
        }
      }
    }
  }

  _toggleTorch() {
    _torch = !_torch;
  }

}
