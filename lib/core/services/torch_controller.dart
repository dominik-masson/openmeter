import 'dart:developer';

import 'package:flutter/services.dart';

import '../../utils/log.dart';

class TorchController {
  static const _channel = MethodChannel('com.example.openmeter/main');
  static const _enableTorch = 'enableTorch';
  static const _disableTorch = 'disableTorch';
  static const _torchAvailable = 'torchAvailable';

  bool _torch = false;

  bool get stateTorch => _torch;

  Future<bool> _isTorchAvailable() async {
    try {
      return await _channel.invokeMethod(_torchAvailable) as bool;
    } on PlatformException catch (e) {
      log(e.message ?? '', name: LogNames.torchHandler);
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
        _torch = false;
        log(e.message ?? '', name: LogNames.torchHandler);
      }
    } else {
      try {
        await _channel.invokeMethod(_disableTorch);
      } on PlatformException catch (e) {
        _torch = false;
        log(e.message ?? '', name: LogNames.torchHandler);
      }
    }
  }

  _toggleTorch() {
    _torch = !_torch;
  }

  void setStateTorch(bool state) {
    _torch = state;
  }
}
