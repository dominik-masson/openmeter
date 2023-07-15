import 'package:drift/drift.dart';

import '../local_database.dart';
import '../tables/tags.dart';

part 'tags_dao.g.dart';

@DriftAccessor(tables: [Tags])
class TagsDao extends DatabaseAccessor<LocalDatabase> with _$TagsDaoMixin {
  final LocalDatabase db;

  TagsDao(this.db) : super(db);

  Future<int> createTag(TagsCompanion tag) async {
    return await db.into(db.tags).insert(tag);
  }

  Future<int> deleteTag(String tagId) async {
    await (delete(db.meterWithTags)..where((tbl) => tbl.tagId.equals(tagId)))
        .go();

    return await (delete(db.tags)..where((tbl) => tbl.uuid.equals(tagId))).go();
  }

  Future<bool> updateTag(TagsCompanion newTag) async {
    return await update(db.tags).replace(newTag);
  }

  Stream<List<Tag>> watchAllTags() {
    return (db.select(db.tags)).watch();
  }

  Future<List<Tag>> getAllTags() async {
    return (select(db.tags)).get();
  }

  Future<Tag> getSingleTag(int tagId) async {
    return await (db.select(db.tags)..where((tbl) => tbl.id.equals(tagId)))
        .getSingle();
  }

  Future<int?> getTableLength() async {
    var count = db.tags.id.count();

    return await (db.selectOnly(db.tags)..addColumns([count]))
        .map((row) => row.read(count))
        .getSingleOrNull();
  }

  Future<int> createMeterWithTag(MeterWithTagsCompanion entity) async {
    return await db.into(db.meterWithTags).insert(entity);
  }

  Future<List<Tag>> getTagsForMeter(int meterId) async {
    final query = select(db.tags).join([
      leftOuterJoin(
        db.meterWithTags,
        db.meterWithTags.tagId.equalsExp(db.tags.uuid),
      )
    ])
      ..where(db.meterWithTags.meterId.equals(meterId));

    return await query.map((r) => r.readTable(db.tags)).get();
  }

  Stream<List<Tag>> watchTagsForMeter(int meterId) {
    final query = select(db.tags).join([
      leftOuterJoin(
        db.meterWithTags,
        db.meterWithTags.tagId.equalsExp(db.tags.uuid),
      )
    ])
      ..where(db.meterWithTags.meterId.equals(meterId));

    return query.map((r) => r.readTable(db.tags)).watch();
  }

  Future<int> removeAssoziation(String tagId, int meterId) async {
    return await (delete(db.meterWithTags)
          ..where(
              (tbl) => tbl.tagId.equals(tagId) & tbl.meterId.equals(meterId)))
        .go();
  }

  Future<List<MeterWithTag>> getAllMeterWithTags() async {
    return await select(db.meterWithTags).get();
  }
}
