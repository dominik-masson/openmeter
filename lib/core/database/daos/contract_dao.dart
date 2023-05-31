import 'package:drift/drift.dart';

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

  Future<ProviderData> selectProvider(int id) async {
    return await (db.select(db.provider)..where((tbl) => tbl.uid.equals(id)))
        .getSingle();
  }

  Future<int> deleteContract(int id) async {
    return await (db.delete(db.contract)..where((tbl) => tbl.uid.equals(id)))
        .go();
  }

  Future<int> deleteProvider(int id) async {
    return await (db.delete(db.provider)..where((tbl) => tbl.uid.equals(id)))
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
    var count = db.contract.uid.count();

    return await (db.selectOnly(db.contract)..addColumns([count]))
        .map((row) => row.read(count))
        .getSingleOrNull();
  }
}
