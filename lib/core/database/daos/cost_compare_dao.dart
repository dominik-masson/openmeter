import 'package:drift/drift.dart';

import '../local_database.dart';
import '../tables/cost_compare.dart';

part 'cost_compare_dao.g.dart';

@DriftAccessor(tables: [CostCompare])
class CostCompareDao extends DatabaseAccessor<LocalDatabase>
    with _$CostCompareDaoMixin {
  final LocalDatabase db;

  CostCompareDao(this.db) : super(db);

  Future<CostCompareData?> getCompareCost(int parentId) async {
    return await (select(db.costCompare)
          ..where((tbl) => tbl.parentId.equals(parentId)))
        .getSingleOrNull();
  }

  Future createCompareCost(CostCompareCompanion costs) async {
    return await into(db.costCompare).insert(costs);
  }

  Future deleteCompareCost(int id) async {
    return await (delete(db.costCompare)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future updateCompareCost(CostCompareData cost) async {
    return await update(db.costCompare).replace(cost);
  }
}
