import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../utils/log.dart';
import '../database/local_database.dart';
import '../model/contract_dto.dart';
import 'database_settings_provider.dart';

class ContractProvider extends ChangeNotifier {
  String _cacheDir = '';
  final String _fileName = 'contract.json';
  List<ContractDto> _contracts = [];
  final List<ContractDto> _firstContracts = [];
  final List<ContractDto> _secondContracts = [];

  int _selectedItemsLength = 0;
  bool _hasSelectedItems = false;

  ContractProvider() {
    _loadFromCache();
  }

  int get getAllContractLength => _contracts.length;

  List<ContractDto> get getFirstContracts => _firstContracts;

  List<ContractDto> get getSecondContracts => _secondContracts;

  bool get getHasSelectedItems => _hasSelectedItems;

  int get getSelectedItemsLength => _selectedItemsLength;

  Future<void> _getDir() async {
    Directory dir = await getTemporaryDirectory();

    _cacheDir = dir.path;
  }

  splitContracts() {
    _firstContracts.clear();
    _secondContracts.clear();

    for (int i = 0; i < _contracts.length; i++) {
      if (i % 2 == 0) {
        _firstContracts.add(_contracts.elementAt(i));
      } else {
        _secondContracts.add(_contracts.elementAt(i));
      }
    }
  }

  _loadFromCache() async {
    await _getDir();

    File file = File('$_cacheDir/$_fileName');

    if (file.existsSync()) {
      try {
        log('load contract data from json', name: LogNames.contractProvider);

        List<dynamic> json = jsonDecode(file.readAsStringSync());

        _contracts.clear();

        _contracts = json.map((e) => ContractDto.fromJson(e)).toList();

        // _contracts.sort((a, b) => a.meterTyp!.compareTo(b.meterTyp!));

        splitContracts();
      } catch (err) {
        log('ERROR: $err', name: LogNames.contractProvider);
      }
    } else {
      log('there is no file', name: LogNames.contractProvider);
    }
  }

  Future<ProviderData> _getProviderData(int id, LocalDatabase db) async {
    return await db.contractDao.selectProvider(id);
  }

  convertData(List<ContractData> data, LocalDatabase db) async {
    _contracts = await Future.wait(data.map((e) async {
      ProviderData? provider;

      if (e.provider != null) {
        provider = await _getProviderData(e.provider!, db);
        return ContractDto.fromData(e, provider);
      } else {
        return ContractDto.fromData(e, null);
      }
    }).toList());

    createCache(_contracts);
    splitContracts();

    notifyListeners();
  }

  createCache(List<ContractDto> items) {
    File file = File('$_cacheDir/$_fileName');
    log('create file to path: $_cacheDir/$_fileName ',
        name: LogNames.contractProvider);

    List<Map<String, dynamic>> jsonList =
        items.map((contract) => contract.toJson()).toList();
    var json = jsonEncode(jsonList);

    file.writeAsStringSync(json, flush: true, mode: FileMode.write);
  }

  deleteCache() async {
    File file = File('$_cacheDir/$_fileName');

    _contracts.clear();
    _firstContracts.clear();
    _secondContracts.clear();

    if (file.existsSync()) {
      log('delete contract cache', name: LogNames.contractProvider);
      file.deleteSync();
    }
  }

  toggleSelectedContracts(ContractDto contractDto) {
    int index =
        _contracts.indexWhere((element) => element.id == contractDto.id);

    if (index >= 0) {
      _contracts.elementAt(index).isSelected =
          !_contracts.elementAt(index).isSelected!;

      int count = 0;

      for (var e in _contracts) {
        if (e.isSelected!) {
          count++;
        }
      }

      _selectedItemsLength = count;

      if (count == 0) {
        _hasSelectedItems = false;
      } else {
        _hasSelectedItems = true;
      }

      splitContracts();

      notifyListeners();
    }
  }

  removeAllSelectedItems() {
    for (ContractDto data in _contracts) {
      if (data.isSelected! == true) {
        data.isSelected = false;
      }
    }

    _hasSelectedItems = false;
    _selectedItemsLength = 0;
    splitContracts();

    notifyListeners();
  }

  deleteAllSelectedContracts(BuildContext context) async {
    Provider.of<DatabaseSettingsProvider>(context, listen: false)
        .setHasUpdate(true);

    final db = Provider.of<LocalDatabase>(context, listen: false);

    for (ContractDto data in _contracts) {
      if (data.isSelected! == true) {
        if (data.provider != null) {
          await db.contractDao.deleteProvider(data.provider!.id!);
        }

        await db.contractDao.deleteContract(data.id!);
      }
    }

    _contracts.removeWhere((element) => element.isSelected == true);
    _hasSelectedItems = false;

    createCache(_contracts);
    splitContracts();

    notifyListeners();
  }

  updateContract(
      {required LocalDatabase db,
      required ContractData data,
      required int? providerId}) async {
    ProviderData? provider;

    if (providerId != null) {
      provider = await _getProviderData(providerId, db);
    }

    int index = _contracts.indexWhere((element) => element.id == data.id);

    _contracts[index] = ContractDto.fromData(data, provider);

    splitContracts();
    notifyListeners();
  }
}
