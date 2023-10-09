import 'dart:developer';

import '../../utils/log.dart';
import '../database/local_database.dart';
import '../model/compare_costs.dart';
import '../model/contract_dto.dart';
import '../provider/contract_provider.dart';
import '../provider/details_contract_provider.dart';

class CompareCostHelper {
  Future<void> saveCompare({
    required CompareCosts compare,
    required LocalDatabase db,
    required DetailsContractProvider provider,
    required ContractProvider contractProvider,
  }) async {
    try {
      if (compare.parentId == null) {
        return;
      }

      if (await db.costCompareDao.getCompareCost(compare.parentId!) == null) {
        int id = await db.costCompareDao
            .createCompareCost(compare.toCostCompareCompanion());

        provider.setCompareId(id);

        contractProvider.updateCompareCosts(
            contractId: compare.parentId!, compare: compare);

        log('create compare costs', name: LogNames.compareCostHelper);
      }

      log('Compare contract already exists!', name: LogNames.compareCostHelper);
    } catch (e) {
      log(
        'Error while create compare contract: $e',
        name: LogNames.compareCostHelper,
        level: LogLevels.errorLevel,
      );
    }
  }

  Future deleteCompare({
    required CompareCosts compare,
    required LocalDatabase db,
    required ContractProvider contractProvider,
    required DetailsContractProvider provider,
  }) async {
    try {
      if (compare.parentId == null || compare.id == null) {
        provider.setCompareContract(null, true);
        return;
      }

      await db.costCompareDao.deleteCompareCost(compare.id!);

      provider.setCompareContract(null, true);

      contractProvider.updateCompareCosts(
          contractId: compare.parentId!, compare: null);

      log('delete compare costs', name: LogNames.compareCostHelper);
    } catch (e) {
      log(
        'Error while delete compare contract: ${e.toString()}',
        name: LogNames.compareCostHelper,
        level: LogLevels.errorLevel,
      );
    }
  }

  Future<bool> createNewContract({
    required CompareCosts compare,
    required LocalDatabase db,
    required ContractProvider contractProvider,
    required DetailsContractProvider provider,
    required ContractDto currentContract,
  }) async {
    try {
      final costs = compare.costs;

      double discount = costs.total! / 12;

      if (costs.bonus != null) {
        double bonus = costs.bonus! / 12;
        discount = discount + bonus;
      }

      costs.discount = discount.roundToDouble();

      final ContractDto newContract = ContractDto(
        costs: costs,
        meterTyp: currentContract.meterTyp,
        isSelected: false,
        unit: currentContract.unit,
      );

      int id = await db.contractDao.createContract(newContract.toCompanion());

      newContract.id = id;

      contractProvider.addNewContract(newContract);

      log('create new contract', name: LogNames.compareCostHelper);

      return true;
    } catch (e) {
      log(
        'Error while create new contract: ${e.toString()}',
        name: LogNames.compareCostHelper,
      );

      return false;
    }
  }

  _getNewContract({
    required CompareCosts compare,
    required ContractDto currentContract,
  }) {
    currentContract.compareCosts = compare;

    return currentContract;
  }

  Future updateCompare({
    required CompareCosts compare,
    required LocalDatabase db,
    required ContractProvider contractProvider,
    required DetailsContractProvider provider,
    required ContractDto currentContract,
  }) async {
    await db.costCompareDao.updateCompareCost(compare.toData());

    provider.setCompareContract(compare, true);

    contractProvider.updateCompareCosts(
        contractId: currentContract.id!, compare: compare);

    provider.setCurrentContract(
        _getNewContract(compare: compare, currentContract: currentContract));

    log('update current compare costs', name: LogNames.compareCostHelper);
  }
}
