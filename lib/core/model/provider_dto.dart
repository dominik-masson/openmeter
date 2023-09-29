import '../database/local_database.dart';

class ProviderDto {
  int? id;
  String name;
  String contractNumber;
  int? notice;
  DateTime validFrom;
  DateTime validUntil;
  int? renewal;
  bool? canceled;
  DateTime? canceledDate;
  bool showShouldCanceled = false;

  ProviderDto({
    required this.name,
    required this.contractNumber,
    this.notice,
    required this.validFrom,
    required this.validUntil,
    this.renewal,
    this.canceledDate,
    this.canceled,
    this.id,
    required this.showShouldCanceled,
  });

  ProviderDto.formData(ProviderData data)
      : id = data.id,
        name = data.name,
        contractNumber = data.contractNumber,
        notice = data.notice,
        validFrom = data.validFrom,
        validUntil = data.validUntil,
        renewal = data.renewal,
        canceled = data.canceled,
        canceledDate = data.canceledDate;

  ProviderDto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        contractNumber = json['contractNumber'],
        notice = json['notice'],
        validFrom = DateTime.parse(json['validFrom']),
        validUntil = DateTime.parse(json['validUntil']),
        renewal = json['renewal'],
        canceled = json['canceled'],
        canceledDate = json['canceledDate'] == null
            ? null
            : DateTime.parse(
                json['canceledDate'],
              );

  ProviderDto.fromCompanion(ProviderCompanion companion, int providerId)
      : id = providerId,
        name = companion.name.value,
        contractNumber = companion.contractNumber.value,
        notice = companion.notice.value,
        validFrom = companion.validFrom.value,
        validUntil = companion.validUntil.value,
        renewal = companion.renewal.value,
        canceled = companion.canceled.value,
        canceledDate = companion.canceledDate.value;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contractNumber': contractNumber,
      'notice': notice,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'renewal': renewal,
      'canceled': canceled,
      'canceledDate': canceledDate?.toIso8601String(),
    };
  }

  ProviderData toData() {
    return ProviderData(
      name: name,
      id: id!,
      contractNumber: contractNumber,
      notice: notice,
      validFrom: validFrom,
      validUntil: validUntil,
      canceledDate: canceledDate,
      canceled: canceled,
      renewal: renewal,
    );
  }

  ProviderDto.fromData(ProviderData data)
      : id = data.id,
        contractNumber = data.contractNumber,
        notice = data.notice,
        name = data.name,
        validFrom = data.validFrom,
        validUntil = data.validUntil,
        canceledDate = data.canceledDate,
        canceled = data.canceled,
        renewal = data.renewal;
}
