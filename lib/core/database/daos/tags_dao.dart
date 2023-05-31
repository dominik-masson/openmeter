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

  Future<int> deleteTag(int tagId) async {
    return await (delete(db.tags)..where((tbl) => tbl.id.equals(tagId))).go();
  }

  Future<bool> updateTag(TagsCompanion newTag) async {
    return await update(db.tags).replace(newTag);
  }

  Stream<List<Tag>> watchAllTags() {
    return (db.select(db.tags)).watch();
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
}
