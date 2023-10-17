import '../database/local_database.dart';

class TagDto {
  int? id;
  String? uuid;
  String name = '';
  int color = -1;

  TagDto.fromValue({required String name, required int color})
      : name = name,
        color = color;

  TagDto.fromData(Tag data)
      : id = data.id,
        uuid = data.uuid,
        name = data.name,
        color = data.color;
}
