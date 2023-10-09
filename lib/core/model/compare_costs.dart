import 'package:drift/drift.dart';

import '../database/local_database.dart';
import 'contract_costs.dart';

class CompareCosts {
  int? id;
  ContractCosts costs;
  int usage;
  int? parentId;

  CompareCosts({
    this.id,
    required this.costs,
    required this.usage,
    this.parentId,
  });

  CostCompareCompanion toCostCompareCompanion() {
    return CostCompareCompanion(
      basicPrice: Value(costs.basicPrice),
      parentId: Value(parentId!),
      energyPrice: Value(costs.energyPrice),
      bonus: Value(costs.bonus ?? 0),
      usage: Value(usage),
    );
  }

  CompareCosts.fromData(CostCompareData costs)
      : id = costs.id,
        usage = costs.usage,
        parentId = costs.parentId,
        costs = ContractCosts(
          basicPrice: costs.basicPrice,
          energyPrice: costs.energyPrice,
          bonus: costs.bonus,
        );

  CostCompareData toData() {
    return CostCompareData(
      bonus: costs.bonus ?? 0,
      basicPrice: costs.basicPrice,
      energyPrice: costs.energyPrice,
      parentId: parentId!,
      usage: usage,
      id: id!,
    );
  }

  toJson() {
    return {
      'usage': usage,
      'basicPrice': costs.basicPrice,
      'energyPrice': costs.energyPrice,
      'bonus': costs.bonus,
    };
  }

  CompareCosts.fromJson(Map json, int this.parentId)
      : costs = ContractCosts(
          basicPrice: json['basicPrice'],
          energyPrice: json['energyPrice'],
          bonus: json['bonus'],
        ),
        usage = json['usage'];
}
