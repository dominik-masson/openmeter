import '../database/local_database.dart';

class ProviderDto {
  int? id;
  String? name;
  String? contractNumber;
  int? notice;
  DateTime? validFrom;
  DateTime? validUntil;

  ProviderDto.formData(ProviderData data)
      : id = data.uid,
        name = data.name,
        contractNumber = data.contractNumber,
        notice = data.notice,
        validFrom = data.validFrom,
        validUntil = data.validUntil;

  ProviderDto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        contractNumber = json['contractNumber'],
        notice = json['notice'],
        validFrom = DateTime.parse(json['validFrom']),
        validUntil = DateTime.parse(json['validUntil']);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contractNumber': contractNumber,
      'notice': notice,
      'validFrom': validFrom?.toIso8601String() ?? '',
      'validUntil': validUntil?.toIso8601String() ?? '',
    };
  }
}
