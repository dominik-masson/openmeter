import 'package:drift/drift.dart' as drift;

import '../database/local_database.dart';
import '../model/contract_dto.dart';
import '../model/provider_dto.dart';
import '../provider/contract_provider.dart';

class ProviderHelper {
  Future<ProviderDto> createProvider({
    required LocalDatabase db,
    required ProviderDto provider,
    int? contractId,
  }) async {
    final providerCompanion = ProviderCompanion(
      name: drift.Value(provider.name),
      contractNumber: drift.Value(provider.contractNumber),
      notice: drift.Value(provider.notice),
      validFrom: drift.Value(provider.validFrom),
      validUntil: drift.Value(provider.validUntil),
      renewal: drift.Value(provider.renewal),
      canceled: drift.Value(provider.canceled),
      canceledDate: drift.Value(provider.canceledDate),
    );

    int providerId = await db.contractDao.createProvider(providerCompanion);

    if (contractId != null) {
      await db.contractDao.linkProviderToContract(
        contractId: contractId,
        providerId: providerId,
      );
    }

    return ProviderDto.fromCompanion(providerCompanion, providerId);
  }

  Future<ProviderDto?> updateProvider({
    required LocalDatabase db,
    required ProviderDto provider,
  }) async {
    await db.contractDao.updateProvider(provider.toData());

    return provider;
  }

  deleteProvider({
    required LocalDatabase db,
    required ProviderDto provider,
    required ContractProvider contractProvider,
    required int contractId,
  }) async {
    await db.contractDao.deleteProvider(provider.id!);

    contractProvider.removeProvider(contractId: contractId);
  }

  removeCanceledState({
    required LocalDatabase db,
    required ProviderDto provider,
  }) async {
    provider.canceled = false;
    provider.canceledDate = null;

    return await updateProvider(db: db, provider: provider);
  }

  ProviderDto showShouldCanceled(
      {required ProviderDto provider,
      required DateTime end,
      required DateTime current}) {
    int? notice = provider.notice;

    int dateDifference = end.difference(current).inDays ~/ 30;

    bool isCanceled = provider.canceled ?? false;

    if (notice != null && (dateDifference - notice) == 1 && !isCanceled) {
      provider.showShouldCanceled = true;
    }

    return provider;
  }

  ProviderDto renewalContract({
    required ProviderDto provider,
    required DateTime end,
    required DateTime current,
    required LocalDatabase db,
  }) {
    int? renewal = provider.renewal;

    if (end.isBefore(current) && renewal != null) {
      provider.validUntil = DateTime(end.year, end.month + renewal, end.day);

      updateProvider(db: db, provider: provider);
    }

    return provider;
  }

  List<ContractDto> prepareProvider(
      List<ContractDto> contracts, LocalDatabase db) {
    for (ContractDto item in contracts) {
      if (item.provider != null) {
        ProviderDto provider = item.provider!;

        DateTime contractEnd = provider.validUntil;

        DateTime currentDate = DateTime.now();

        provider = showShouldCanceled(
          provider: provider,
          current: currentDate,
          end: contractEnd,
        );

        provider = renewalContract(
          provider: provider,
          end: contractEnd,
          current: currentDate,
          db: db,
        );
      }
    }

    return contracts;
  }
}
