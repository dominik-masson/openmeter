import 'package:drift/drift.dart';

import '../../model/compare_costs.dart';
import '../../model/contract_dto.dart';
import '../../model/provider_dto.dart';
import '../local_database.dart';
import '../tables/contract.dart';

part 'contract_dao.g.dart';

@DriftAccessor(tables: [Contract, Provider])
class ContractDao extends DatabaseAccessor<LocalDatabase>
    with _$ContractDaoMixin {
  final LocalDatabase db;

  ContractDao(this.db) : super(db);

  Future<int> createProvider(ProviderCompanion provider) async {
    return await db.into(db.provider).insert(provider);
  }

  Future<int> createContract(ContractCompanion contract) async {
    return await db.into(db.contract).insert(contract);
  }

  Stream<List<ContractData>> watchAllContracts(bool isArchived) {
    return (select(db.contract)
          ..where((tbl) => tbl.isArchived.equals(isArchived)))
        .watch();
  }

  Future<List<ContractDto>> getAllContractsDto() async {
    List<ContractDto> result = [];
    List<ContractData> contracts = await select(db.contract).get();

    for (ContractData contract in contracts) {
      ContractDto contractDto = ContractDto.fromData(contract, null);

      if (contract.provider != null) {
        ProviderData provider = await selectProvider(contract.provider!);

        contractDto.provider = ProviderDto.fromData(provider);
      }

      final compareCosts = await db.costCompareDao.getCompareCost(contract.id);

      if (compareCosts != null) {
        contractDto.compareCosts = CompareCosts.fromData(compareCosts);
      }

      result.add(contractDto);
    }

    return result;
  }

  Future<ProviderData> selectProvider(int id) async {
    return await (db.select(db.provider)..where((tbl) => tbl.id.equals(id)))
        .getSingle();
  }

  Future<int> deleteContract(int id) async {
    return await (db.delete(db.contract)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<int> deleteProvider(int id) async {
    return await (db.delete(db.provider)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<ContractData> getContractByTyp(String meterTyp) async {
    return await (db.select(db.contract)
          ..where((tbl) => tbl.meterTyp.equals(meterTyp)))
        .getSingle();
  }

  Future<bool> updateContract(ContractData contractData) async {
    return await update(db.contract).replace(contractData);
  }

  Future<bool> updateProvider(ProviderData providerData) async {
    return await update(db.provider).replace(providerData);
  }

  Future<int?> getTableLength() async {
    var count = db.contract.id.count();

    return await (db.selectOnly(db.contract)..addColumns([count]))
        .map((row) => row.read(count))
        .getSingleOrNull();
  }

  Future<int> linkProviderToContract(
      {required int contractId, required int providerId}) async {
    return await (update(db.contract)
          ..where((tbl) => tbl.id.equals(contractId)))
        .write(
      ContractCompanion(
        provider: Value(providerId),
      ),
    );
  }

  Future updateIsArchived(
      {required int contractId, required bool isArchived}) async {
    return await (update(contract)..where((tbl) => tbl.id.equals(contractId)))
        .write(ContractCompanion(isArchived: Value(isArchived)));
  }
}
