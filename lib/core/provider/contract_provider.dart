import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/log.dart';
import '../database/local_database.dart';
import '../model/compare_costs.dart';
import '../model/contract_dto.dart';
import '../model/provider_dto.dart';
import '../helper/provider_helper.dart';

class ContractProvider extends ChangeNotifier {
  final ProviderHelper _providerHelper = ProviderHelper();

  String _cacheDir = '';
  final String _fileName = 'contract.json';
  List<ContractDto> _contracts = [];
  final List<ContractDto> _firstContracts = [];
  final List<ContractDto> _secondContracts = [];

  int _selectedItemsLength = 0;
  bool _hasSelectedItems = false;

  List<ContractDto> _archivedContracts = [];

  int get getArchivedContractsLength => _archivedContracts.length;

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
        _archivedContracts.clear();

        for (var element in json) {
          bool isArchived = element['isArchived'];

          if (isArchived) {
            _archivedContracts.add(ContractDto.fromJson(element));
          } else {
            _contracts.add(ContractDto.fromJson(element));
          }
        }

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

  prepareProvider(LocalDatabase db, bool isArchived) {
    if (isArchived) {
      _archivedContracts =
          _providerHelper.prepareProvider(_archivedContracts, db);
    } else {
      _contracts = _providerHelper.prepareProvider(_contracts, db);
    }
  }

  _getCompareCosts(LocalDatabase db, List<ContractDto> contracts) async {
    for (ContractDto contract in contracts) {
      final CostCompareData? costs =
          await db.costCompareDao.getCompareCost(contract.id!);

      if (costs != null) {
        final CompareCosts costsDto = CompareCosts.fromData(costs);

        contract.compareCosts = costsDto;
      }
    }
  }

  List<ContractDto> _getAllContracts() {
    final List<ContractDto> allContracts = _contracts + _archivedContracts;

    allContracts.sort(
      (a, b) => a.id!.compareTo(b.id!),
    );

    return allContracts;
  }

  convertData(
      {required List<ContractData> data,
      required LocalDatabase db,
      required bool isArchived}) async {
    if (isArchived) {
      _archivedContracts = await Future.wait(data.map((e) async {
        ProviderData? provider;

        if (e.provider != null) {
          provider = await _getProviderData(e.provider!, db);
          return ContractDto.fromData(e, provider);
        } else {
          return ContractDto.fromData(e, null);
        }
      }).toList());

      await _getCompareCosts(db, _archivedContracts);
    } else {
      _contracts = await Future.wait(data.map((e) async {
        ProviderData? provider;

        if (e.provider != null) {
          provider = await _getProviderData(e.provider!, db);
          return ContractDto.fromData(e, provider);
        } else {
          return ContractDto.fromData(e, null);
        }
      }).toList());

      await _getCompareCosts(db, _contracts);

      splitContracts();
    }

    createCache(_getAllContracts());

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

  _toggleSelected(List<ContractDto> toggleList, int contractId) {
    int index = toggleList.indexWhere((element) => element.id == contractId);

    if (index >= 0) {
      toggleList.elementAt(index).isSelected =
          !toggleList.elementAt(index).isSelected!;

      int count = 0;

      for (var e in toggleList) {
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
    }
  }

  toggleSelectedContracts(ContractDto contractDto) {
    if (contractDto.isArchived) {
      _toggleSelected(_archivedContracts, contractDto.id!);
    } else {
      _toggleSelected(_contracts, contractDto.id!);
      splitContracts();
    }

    notifyListeners();
  }

  removeAllSelectedItems(bool notify) {
    for (ContractDto data in _contracts) {
      if (data.isSelected! == true) {
        data.isSelected = false;
      }
    }

    for (ContractDto data in _archivedContracts) {
      if (data.isSelected! == true) {
        data.isSelected = false;
      }
    }

    _hasSelectedItems = false;
    _selectedItemsLength = 0;
    splitContracts();

    if (notify) {
      notifyListeners();
    }
  }

  _deleteContracts(
      {required List<ContractDto> currentList,
      required LocalDatabase db}) async {
    for (ContractDto data in currentList) {
      if (data.isSelected! == true) {
        if (data.provider != null) {
          await db.contractDao.deleteProvider(data.provider!.id!);
        }

        await db.contractDao.deleteContract(data.id!);
      }
    }

    currentList.removeWhere((element) => element.isSelected == true);
  }

  deleteAllSelectedContracts(LocalDatabase db, bool isArchiv) async {
    if (isArchiv) {
      await _deleteContracts(currentList: _archivedContracts, db: db);
    } else {
      await _deleteContracts(currentList: _contracts, db: db);
      splitContracts();
    }

    _hasSelectedItems = false;

    createCache(_getAllContracts());

    notifyListeners();
  }

  deleteSingleContract(
      {required ContractDto contract, required LocalDatabase db}) async {
    if (contract.isArchived) {
      _archivedContracts.removeWhere((element) => element.id == contract.id);
    } else {
      _contracts.removeWhere((element) => element.id == contract.id);
      splitContracts();
    }

    if (contract.provider != null) {
      await db.contractDao.deleteProvider(contract.provider!.id!);
    }

    await db.contractDao.deleteContract(contract.id!);
    createCache(_getAllContracts());

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

    if (data.isArchived) {
      int index =
          _archivedContracts.indexWhere((element) => element.id == data.id);

      CompareCosts? compareCosts = _archivedContracts[index].compareCosts;

      _archivedContracts[index] = ContractDto.fromData(data, provider);
      _archivedContracts[index].compareCosts = compareCosts;
    } else {
      int index = _contracts.indexWhere((element) => element.id == data.id);

      CompareCosts? compareCosts = _contracts[index].compareCosts;

      _contracts[index] = ContractDto.fromData(data, provider);
      _contracts[index].compareCosts = compareCosts;

      splitContracts();
    }

    createCache(_getAllContracts());

    log('Update Contract', name: LogNames.contractProvider);

    notifyListeners();
  }

  ContractDto getSingleSelectedContract() {
    final contract =
        _contracts.firstWhere((element) => element.isSelected == true);

    removeAllSelectedItems(false);

    return contract;
  }

  updateProvider({
    required LocalDatabase db,
    required ProviderDto provider,
    required int contractId,
    required bool isArchiv,
  }) async {
    await db.contractDao.updateProvider(provider.toData());

    if (isArchiv) {
      int index =
          _archivedContracts.indexWhere((element) => element.id == contractId);

      _archivedContracts[index].provider = provider;

      prepareProvider(db, true);
    } else {
      int index = _contracts.indexWhere((element) => element.id == contractId);

      _contracts[index].provider = provider;

      prepareProvider(db, false);
    }

    createCache(_getAllContracts());

    log('Update Provider', name: LogNames.contractProvider);

    notifyListeners();
  }

  removeProvider({
    required int contractId,
  }) {
    int index = _contracts.indexWhere((element) => element.id == contractId);

    if (index != -1) {
      _contracts[index].provider = null;
    } else {
      index =
          _archivedContracts.indexWhere((element) => element.id == contractId);
      _archivedContracts[index].provider = null;
    }

    createCache(_getAllContracts());

    log('Remove provider from contract with id: $contractId',
        name: LogNames.contractProvider);

    notifyListeners();
  }

  updateCompareCosts({
    required bool isArchived,
    required int contractId,
    required CompareCosts? compare,
  }) {
    if (isArchived) {
      int index =
          _archivedContracts.indexWhere((element) => element.id == contractId);

      _archivedContracts[index].compareCosts = compare;
    } else {
      int index = _contracts.indexWhere((element) => element.id == contractId);

      _contracts[index].compareCosts = compare;
    }

    createCache(_getAllContracts());

    log('Update Compare costs for contract id: $contractId',
        name: LogNames.contractProvider);

    notifyListeners();
  }

  addNewContract(ContractDto newContract, ContractDto oldContract) {
    _contracts.add(newContract);

    oldContract.isArchived = true;
    _archivedContracts.add(oldContract);
    _contracts.removeWhere((element) => element.id! == oldContract.id!);

    createCache(_getAllContracts());
    splitContracts();

    notifyListeners();
  }

  archiveAllSelectedContract(LocalDatabase db) async {
    for (ContractDto contract in _contracts) {
      if (contract.isSelected != null && contract.isSelected!) {
        await db.contractDao
            .updateIsArchived(contractId: contract.id!, isArchived: true);

        contract.isArchived = true;
      }
    }
  }

  unarchiveSelectedContracts(LocalDatabase db) async {
    for (ContractDto contract in _archivedContracts) {
      if (contract.isSelected != null && contract.isSelected!) {
        await db.contractDao
            .updateIsArchived(contractId: contract.id!, isArchived: false);

        contract.isArchived = false;
      }
    }
  }

  unarchiveSingleContract(LocalDatabase db, ContractDto contract) async {
    await db.contractDao
        .updateIsArchived(contractId: contract.id!, isArchived: false);

    contract.isArchived = false;
  }

  List<ContractDto> get getArchivedContracts => _archivedContracts;
}
