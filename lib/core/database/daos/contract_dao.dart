import 'package:drift/drift.dart';

import '../../model/contract_dto.dart';
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

  Stream<List<ContractData>> watchALlContracts() {
    return db.select(db.contract).watch();
  }

  Future<List<ContractDto>> getAllContractsWithProvider() async {
    List<ContractDto> result = [];
    List<ContractData> contracts = await select(db.contract).get();

    for (ContractData contract in contracts) {
      if (contract.provider != null) {
        ProviderData provider = await selectProvider(contract.provider!);

        result.add(ContractDto.fromData(contract, provider));
      } else {
        result.add(ContractDto.fromData(contract, null));
      }
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
}
