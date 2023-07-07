import '../database/local_database.dart';
import 'provider_dto.dart';

class ContractDto {
  int? id;
  String? meterTyp;
  double? basicPrice;
  double? energyPrice;
  double? discount;
  int? bonus;
  String? note;
  ProviderDto? provider;
  bool? isSelected;

  ContractDto.fromData(ContractData data, ProviderData? provider)
      : id = data.uid,
        meterTyp = data.meterTyp,
        basicPrice = data.basicPrice,
        energyPrice = data.energyPrice,
        discount = data.discount,
        bonus = data.bonus,
        note = data.note,
        provider = provider == null ? null : ProviderDto.formData(provider),
        isSelected = false;

  ContractDto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        meterTyp = json['meterTyp'],
        basicPrice = json['basicPrice'],
        energyPrice = json['energyPrice'],
        discount = json['discount'],
        bonus = json['bonus'],
        note = json['note'],
        isSelected = json['isSelected'],
        provider = json['provider'] == null
            ? null
            : ProviderDto.fromJson(json['provider']);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meterTyp': meterTyp,
      'basicPrice': basicPrice,
      'energyPrice': energyPrice,
      'discount': discount,
      'bonus': bonus,
      'note': note,
      'isSelected': isSelected,
      'provider': provider?.toJson(),
    };
  }
}
