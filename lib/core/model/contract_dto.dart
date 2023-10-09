import 'package:drift/drift.dart';

import '../database/local_database.dart';
import 'compare_costs.dart';
import 'contract_costs.dart';
import 'provider_dto.dart';

class ContractDto {
  int? id;
  String meterTyp;
  ContractCosts costs;
  String? note;
  ProviderDto? provider;
  bool? isSelected;
  bool isArchived = false;
  CompareCosts? compareCosts;
  String unit;

  ContractDto({
    this.id,
    required this.meterTyp,
    required this.costs,
    this.note,
    this.provider,
    this.isSelected,
    required this.unit,
  });

  ContractDto.fromData(ContractData data, ProviderData? provider)
      : id = data.id,
        meterTyp = data.meterTyp,
        costs = ContractCosts(
          basicPrice: data.basicPrice,
          energyPrice: data.energyPrice,
          discount: data.discount,
          bonus: data.bonus,
        ),
        note = data.note,
        provider = provider == null ? null : ProviderDto.formData(provider),
        isSelected = false,
        isArchived = data.isArchived,
        unit = data.unit;

  ContractDto.fromCompanion({
    required ContractCompanion data,
    required int contractId,
    this.provider,
  })  : id = contractId,
        meterTyp = data.meterTyp.value,
        costs = ContractCosts(
          basicPrice: data.basicPrice.value,
          energyPrice: data.energyPrice.value,
          discount: data.discount.value,
          bonus: data.bonus.value,
        ),
        note = data.note.value,
        isSelected = false,
        isArchived = data.isArchived.value,
        unit = data.unit.value;

  ContractDto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        meterTyp = json['meterTyp'],
        costs = ContractCosts(
          basicPrice: json['basicPrice'],
          energyPrice: json['energyPrice'],
          discount: json['discount'],
          bonus: json['bonus'],
        ),
        note = json['note'],
        isSelected = json['isSelected'],
        isArchived = json['isArchived'],
        provider = json['provider'] == null
            ? null
            : ProviderDto.fromJson(json['provider']),
        compareCosts = json['compareCosts'] == null
            ? null
            : CompareCosts.fromJson(
                json['compareCosts'],
                json['id'],
              ),
        unit = json['unit'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meterTyp': meterTyp,
      'unit': unit,
      'basicPrice': costs.basicPrice,
      'energyPrice': costs.energyPrice,
      'discount': costs.discount,
      'bonus': costs.bonus,
      'note': note,
      'isSelected': isSelected,
      'isArchived': isArchived,
      'provider': provider?.toJson(),
      'compareCosts': compareCosts?.toJson(),
    };
  }

  ContractCompanion toCompanion() {
    return ContractCompanion(
      bonus: Value(costs.bonus),
      energyPrice: Value(costs.energyPrice),
      discount: Value(costs.discount ?? 0),
      basicPrice: Value(costs.basicPrice),
      meterTyp: Value(meterTyp),
      isArchived: Value(isArchived),
      provider: Value(provider?.id),
      note: Value(note ?? ''),
      unit: Value(unit),
    );
  }
}
