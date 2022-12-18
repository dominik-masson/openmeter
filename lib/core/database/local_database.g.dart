// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class MeterData extends DataClass implements Insertable<MeterData> {
  final int id;
  final String typ;
  final String note;
  final String number;
  const MeterData(
      {required this.id,
      required this.typ,
      required this.note,
      required this.number});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['typ'] = Variable<String>(typ);
    map['note'] = Variable<String>(note);
    map['number'] = Variable<String>(number);
    return map;
  }

  MeterCompanion toCompanion(bool nullToAbsent) {
    return MeterCompanion(
      id: Value(id),
      typ: Value(typ),
      note: Value(note),
      number: Value(number),
    );
  }

  factory MeterData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeterData(
      id: serializer.fromJson<int>(json['id']),
      typ: serializer.fromJson<String>(json['typ']),
      note: serializer.fromJson<String>(json['note']),
      number: serializer.fromJson<String>(json['number']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'typ': serializer.toJson<String>(typ),
      'note': serializer.toJson<String>(note),
      'number': serializer.toJson<String>(number),
    };
  }

  MeterData copyWith({int? id, String? typ, String? note, String? number}) =>
      MeterData(
        id: id ?? this.id,
        typ: typ ?? this.typ,
        note: note ?? this.note,
        number: number ?? this.number,
      );
  @override
  String toString() {
    return (StringBuffer('MeterData(')
          ..write('id: $id, ')
          ..write('typ: $typ, ')
          ..write('note: $note, ')
          ..write('number: $number')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, typ, note, number);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeterData &&
          other.id == this.id &&
          other.typ == this.typ &&
          other.note == this.note &&
          other.number == this.number);
}

class MeterCompanion extends UpdateCompanion<MeterData> {
  final Value<int> id;
  final Value<String> typ;
  final Value<String> note;
  final Value<String> number;
  const MeterCompanion({
    this.id = const Value.absent(),
    this.typ = const Value.absent(),
    this.note = const Value.absent(),
    this.number = const Value.absent(),
  });
  MeterCompanion.insert({
    this.id = const Value.absent(),
    required String typ,
    required String note,
    required String number,
  })  : typ = Value(typ),
        note = Value(note),
        number = Value(number);
  static Insertable<MeterData> custom({
    Expression<int>? id,
    Expression<String>? typ,
    Expression<String>? note,
    Expression<String>? number,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typ != null) 'typ': typ,
      if (note != null) 'note': note,
      if (number != null) 'number': number,
    });
  }

  MeterCompanion copyWith(
      {Value<int>? id,
      Value<String>? typ,
      Value<String>? note,
      Value<String>? number}) {
    return MeterCompanion(
      id: id ?? this.id,
      typ: typ ?? this.typ,
      note: note ?? this.note,
      number: number ?? this.number,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (typ.present) {
      map['typ'] = Variable<String>(typ.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeterCompanion(')
          ..write('id: $id, ')
          ..write('typ: $typ, ')
          ..write('note: $note, ')
          ..write('number: $number')
          ..write(')'))
        .toString();
  }
}

class $MeterTable extends Meter with TableInfo<$MeterTable, MeterData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeterTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typMeta = const VerificationMeta('typ');
  @override
  late final GeneratedColumn<String> typ = GeneratedColumn<String>(
      'typ', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
      'number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, typ, note, number];
  @override
  String get aliasedName => _alias ?? 'meter';
  @override
  String get actualTableName => 'meter';
  @override
  VerificationContext validateIntegrity(Insertable<MeterData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('typ')) {
      context.handle(
          _typMeta, typ.isAcceptableOrUnknown(data['typ']!, _typMeta));
    } else if (isInserting) {
      context.missing(_typMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeterData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeterData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      typ: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}typ'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}number'])!,
    );
  }

  @override
  $MeterTable createAlias(String alias) {
    return $MeterTable(attachedDatabase, alias);
  }
}

class Entrie extends DataClass implements Insertable<Entrie> {
  final int id;
  final int meter;
  final int count;
  final DateTime date;
  const Entrie(
      {required this.id,
      required this.meter,
      required this.count,
      required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meter'] = Variable<int>(meter);
    map['count'] = Variable<int>(count);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      meter: Value(meter),
      count: Value(count),
      date: Value(date),
    );
  }

  factory Entrie.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entrie(
      id: serializer.fromJson<int>(json['id']),
      meter: serializer.fromJson<int>(json['meter']),
      count: serializer.fromJson<int>(json['count']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'meter': serializer.toJson<int>(meter),
      'count': serializer.toJson<int>(count),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  Entrie copyWith({int? id, int? meter, int? count, DateTime? date}) => Entrie(
        id: id ?? this.id,
        meter: meter ?? this.meter,
        count: count ?? this.count,
        date: date ?? this.date,
      );
  @override
  String toString() {
    return (StringBuffer('Entrie(')
          ..write('id: $id, ')
          ..write('meter: $meter, ')
          ..write('count: $count, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, meter, count, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entrie &&
          other.id == this.id &&
          other.meter == this.meter &&
          other.count == this.count &&
          other.date == this.date);
}

class EntriesCompanion extends UpdateCompanion<Entrie> {
  final Value<int> id;
  final Value<int> meter;
  final Value<int> count;
  final Value<DateTime> date;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.meter = const Value.absent(),
    this.count = const Value.absent(),
    this.date = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required int meter,
    required int count,
    required DateTime date,
  })  : meter = Value(meter),
        count = Value(count),
        date = Value(date);
  static Insertable<Entrie> custom({
    Expression<int>? id,
    Expression<int>? meter,
    Expression<int>? count,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (meter != null) 'meter': meter,
      if (count != null) 'count': count,
      if (date != null) 'date': date,
    });
  }

  EntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? meter,
      Value<int>? count,
      Value<DateTime>? date}) {
    return EntriesCompanion(
      id: id ?? this.id,
      meter: meter ?? this.meter,
      count: count ?? this.count,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (meter.present) {
      map['meter'] = Variable<int>(meter.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('meter: $meter, ')
          ..write('count: $count, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entrie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _meterMeta = const VerificationMeta('meter');
  @override
  late final GeneratedColumn<int> meter = GeneratedColumn<int>(
      'meter', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES meter (id) ON DELETE CASCADE'));
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
      'count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, meter, count, date];
  @override
  String get aliasedName => _alias ?? 'entries';
  @override
  String get actualTableName => 'entries';
  @override
  VerificationContext validateIntegrity(Insertable<Entrie> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('meter')) {
      context.handle(
          _meterMeta, meter.isAcceptableOrUnknown(data['meter']!, _meterMeta));
    } else if (isInserting) {
      context.missing(_meterMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
          _countMeta, count.isAcceptableOrUnknown(data['count']!, _countMeta));
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entrie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entrie(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      meter: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}meter'])!,
      count: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}count'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class RoomData extends DataClass implements Insertable<RoomData> {
  final int id;
  final String name;
  final String typ;
  const RoomData({required this.id, required this.name, required this.typ});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['typ'] = Variable<String>(typ);
    return map;
  }

  RoomCompanion toCompanion(bool nullToAbsent) {
    return RoomCompanion(
      id: Value(id),
      name: Value(name),
      typ: Value(typ),
    );
  }

  factory RoomData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      typ: serializer.fromJson<String>(json['typ']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'typ': serializer.toJson<String>(typ),
    };
  }

  RoomData copyWith({int? id, String? name, String? typ}) => RoomData(
        id: id ?? this.id,
        name: name ?? this.name,
        typ: typ ?? this.typ,
      );
  @override
  String toString() {
    return (StringBuffer('RoomData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('typ: $typ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, typ);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomData &&
          other.id == this.id &&
          other.name == this.name &&
          other.typ == this.typ);
}

class RoomCompanion extends UpdateCompanion<RoomData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> typ;
  const RoomCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.typ = const Value.absent(),
  });
  RoomCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String typ,
  })  : name = Value(name),
        typ = Value(typ);
  static Insertable<RoomData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? typ,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (typ != null) 'typ': typ,
    });
  }

  RoomCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String>? typ}) {
    return RoomCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      typ: typ ?? this.typ,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (typ.present) {
      map['typ'] = Variable<String>(typ.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('typ: $typ')
          ..write(')'))
        .toString();
  }
}

class $RoomTable extends Room with TableInfo<$RoomTable, RoomData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typMeta = const VerificationMeta('typ');
  @override
  late final GeneratedColumn<String> typ = GeneratedColumn<String>(
      'typ', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, typ];
  @override
  String get aliasedName => _alias ?? 'room';
  @override
  String get actualTableName => 'room';
  @override
  VerificationContext validateIntegrity(Insertable<RoomData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('typ')) {
      context.handle(
          _typMeta, typ.isAcceptableOrUnknown(data['typ']!, _typMeta));
    } else if (isInserting) {
      context.missing(_typMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoomData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      typ: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}typ'])!,
    );
  }

  @override
  $RoomTable createAlias(String alias) {
    return $RoomTable(attachedDatabase, alias);
  }
}

class MeterInRoomData extends DataClass implements Insertable<MeterInRoomData> {
  final int meterId;
  final int roomId;
  const MeterInRoomData({required this.meterId, required this.roomId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meter_id'] = Variable<int>(meterId);
    map['room_id'] = Variable<int>(roomId);
    return map;
  }

  MeterInRoomCompanion toCompanion(bool nullToAbsent) {
    return MeterInRoomCompanion(
      meterId: Value(meterId),
      roomId: Value(roomId),
    );
  }

  factory MeterInRoomData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeterInRoomData(
      meterId: serializer.fromJson<int>(json['meterId']),
      roomId: serializer.fromJson<int>(json['roomId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'meterId': serializer.toJson<int>(meterId),
      'roomId': serializer.toJson<int>(roomId),
    };
  }

  MeterInRoomData copyWith({int? meterId, int? roomId}) => MeterInRoomData(
        meterId: meterId ?? this.meterId,
        roomId: roomId ?? this.roomId,
      );
  @override
  String toString() {
    return (StringBuffer('MeterInRoomData(')
          ..write('meterId: $meterId, ')
          ..write('roomId: $roomId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(meterId, roomId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeterInRoomData &&
          other.meterId == this.meterId &&
          other.roomId == this.roomId);
}

class MeterInRoomCompanion extends UpdateCompanion<MeterInRoomData> {
  final Value<int> meterId;
  final Value<int> roomId;
  const MeterInRoomCompanion({
    this.meterId = const Value.absent(),
    this.roomId = const Value.absent(),
  });
  MeterInRoomCompanion.insert({
    required int meterId,
    required int roomId,
  })  : meterId = Value(meterId),
        roomId = Value(roomId);
  static Insertable<MeterInRoomData> custom({
    Expression<int>? meterId,
    Expression<int>? roomId,
  }) {
    return RawValuesInsertable({
      if (meterId != null) 'meter_id': meterId,
      if (roomId != null) 'room_id': roomId,
    });
  }

  MeterInRoomCompanion copyWith({Value<int>? meterId, Value<int>? roomId}) {
    return MeterInRoomCompanion(
      meterId: meterId ?? this.meterId,
      roomId: roomId ?? this.roomId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (meterId.present) {
      map['meter_id'] = Variable<int>(meterId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeterInRoomCompanion(')
          ..write('meterId: $meterId, ')
          ..write('roomId: $roomId')
          ..write(')'))
        .toString();
  }
}

class $MeterInRoomTable extends MeterInRoom
    with TableInfo<$MeterInRoomTable, MeterInRoomData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeterInRoomTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _meterIdMeta =
      const VerificationMeta('meterId');
  @override
  late final GeneratedColumn<int> meterId = GeneratedColumn<int>(
      'meter_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES meter (id) ON DELETE CASCADE'));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
      'room_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES room (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [meterId, roomId];
  @override
  String get aliasedName => _alias ?? 'meter_in_room';
  @override
  String get actualTableName => 'meter_in_room';
  @override
  VerificationContext validateIntegrity(Insertable<MeterInRoomData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('meter_id')) {
      context.handle(_meterIdMeta,
          meterId.isAcceptableOrUnknown(data['meter_id']!, _meterIdMeta));
    } else if (isInserting) {
      context.missing(_meterIdMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {meterId, roomId};
  @override
  MeterInRoomData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeterInRoomData(
      meterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}meter_id'])!,
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}room_id'])!,
    );
  }

  @override
  $MeterInRoomTable createAlias(String alias) {
    return $MeterInRoomTable(attachedDatabase, alias);
  }
}

class ProviderData extends DataClass implements Insertable<ProviderData> {
  final int uid;
  final String name;
  final String contractNumber;
  final int notice;
  final DateTime validFrom;
  final DateTime validUntil;
  const ProviderData(
      {required this.uid,
      required this.name,
      required this.contractNumber,
      required this.notice,
      required this.validFrom,
      required this.validUntil});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<int>(uid);
    map['name'] = Variable<String>(name);
    map['contract_number'] = Variable<String>(contractNumber);
    map['notice'] = Variable<int>(notice);
    map['valid_from'] = Variable<DateTime>(validFrom);
    map['valid_until'] = Variable<DateTime>(validUntil);
    return map;
  }

  ProviderCompanion toCompanion(bool nullToAbsent) {
    return ProviderCompanion(
      uid: Value(uid),
      name: Value(name),
      contractNumber: Value(contractNumber),
      notice: Value(notice),
      validFrom: Value(validFrom),
      validUntil: Value(validUntil),
    );
  }

  factory ProviderData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderData(
      uid: serializer.fromJson<int>(json['uid']),
      name: serializer.fromJson<String>(json['name']),
      contractNumber: serializer.fromJson<String>(json['contractNumber']),
      notice: serializer.fromJson<int>(json['notice']),
      validFrom: serializer.fromJson<DateTime>(json['validFrom']),
      validUntil: serializer.fromJson<DateTime>(json['validUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<int>(uid),
      'name': serializer.toJson<String>(name),
      'contractNumber': serializer.toJson<String>(contractNumber),
      'notice': serializer.toJson<int>(notice),
      'validFrom': serializer.toJson<DateTime>(validFrom),
      'validUntil': serializer.toJson<DateTime>(validUntil),
    };
  }

  ProviderData copyWith(
          {int? uid,
          String? name,
          String? contractNumber,
          int? notice,
          DateTime? validFrom,
          DateTime? validUntil}) =>
      ProviderData(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        contractNumber: contractNumber ?? this.contractNumber,
        notice: notice ?? this.notice,
        validFrom: validFrom ?? this.validFrom,
        validUntil: validUntil ?? this.validUntil,
      );
  @override
  String toString() {
    return (StringBuffer('ProviderData(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('contractNumber: $contractNumber, ')
          ..write('notice: $notice, ')
          ..write('validFrom: $validFrom, ')
          ..write('validUntil: $validUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uid, name, contractNumber, notice, validFrom, validUntil);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderData &&
          other.uid == this.uid &&
          other.name == this.name &&
          other.contractNumber == this.contractNumber &&
          other.notice == this.notice &&
          other.validFrom == this.validFrom &&
          other.validUntil == this.validUntil);
}

class ProviderCompanion extends UpdateCompanion<ProviderData> {
  final Value<int> uid;
  final Value<String> name;
  final Value<String> contractNumber;
  final Value<int> notice;
  final Value<DateTime> validFrom;
  final Value<DateTime> validUntil;
  const ProviderCompanion({
    this.uid = const Value.absent(),
    this.name = const Value.absent(),
    this.contractNumber = const Value.absent(),
    this.notice = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.validUntil = const Value.absent(),
  });
  ProviderCompanion.insert({
    this.uid = const Value.absent(),
    required String name,
    required String contractNumber,
    required int notice,
    required DateTime validFrom,
    required DateTime validUntil,
  })  : name = Value(name),
        contractNumber = Value(contractNumber),
        notice = Value(notice),
        validFrom = Value(validFrom),
        validUntil = Value(validUntil);
  static Insertable<ProviderData> custom({
    Expression<int>? uid,
    Expression<String>? name,
    Expression<String>? contractNumber,
    Expression<int>? notice,
    Expression<DateTime>? validFrom,
    Expression<DateTime>? validUntil,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (name != null) 'name': name,
      if (contractNumber != null) 'contract_number': contractNumber,
      if (notice != null) 'notice': notice,
      if (validFrom != null) 'valid_from': validFrom,
      if (validUntil != null) 'valid_until': validUntil,
    });
  }

  ProviderCompanion copyWith(
      {Value<int>? uid,
      Value<String>? name,
      Value<String>? contractNumber,
      Value<int>? notice,
      Value<DateTime>? validFrom,
      Value<DateTime>? validUntil}) {
    return ProviderCompanion(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      contractNumber: contractNumber ?? this.contractNumber,
      notice: notice ?? this.notice,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<int>(uid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contractNumber.present) {
      map['contract_number'] = Variable<String>(contractNumber.value);
    }
    if (notice.present) {
      map['notice'] = Variable<int>(notice.value);
    }
    if (validFrom.present) {
      map['valid_from'] = Variable<DateTime>(validFrom.value);
    }
    if (validUntil.present) {
      map['valid_until'] = Variable<DateTime>(validUntil.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderCompanion(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('contractNumber: $contractNumber, ')
          ..write('notice: $notice, ')
          ..write('validFrom: $validFrom, ')
          ..write('validUntil: $validUntil')
          ..write(')'))
        .toString();
  }
}

class $ProviderTable extends Provider
    with TableInfo<$ProviderTable, ProviderData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<int> uid = GeneratedColumn<int>(
      'uid', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contractNumberMeta =
      const VerificationMeta('contractNumber');
  @override
  late final GeneratedColumn<String> contractNumber = GeneratedColumn<String>(
      'contract_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noticeMeta = const VerificationMeta('notice');
  @override
  late final GeneratedColumn<int> notice = GeneratedColumn<int>(
      'notice', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _validFromMeta =
      const VerificationMeta('validFrom');
  @override
  late final GeneratedColumn<DateTime> validFrom = GeneratedColumn<DateTime>(
      'valid_from', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _validUntilMeta =
      const VerificationMeta('validUntil');
  @override
  late final GeneratedColumn<DateTime> validUntil = GeneratedColumn<DateTime>(
      'valid_until', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [uid, name, contractNumber, notice, validFrom, validUntil];
  @override
  String get aliasedName => _alias ?? 'provider';
  @override
  String get actualTableName => 'provider';
  @override
  VerificationContext validateIntegrity(Insertable<ProviderData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contract_number')) {
      context.handle(
          _contractNumberMeta,
          contractNumber.isAcceptableOrUnknown(
              data['contract_number']!, _contractNumberMeta));
    } else if (isInserting) {
      context.missing(_contractNumberMeta);
    }
    if (data.containsKey('notice')) {
      context.handle(_noticeMeta,
          notice.isAcceptableOrUnknown(data['notice']!, _noticeMeta));
    } else if (isInserting) {
      context.missing(_noticeMeta);
    }
    if (data.containsKey('valid_from')) {
      context.handle(_validFromMeta,
          validFrom.isAcceptableOrUnknown(data['valid_from']!, _validFromMeta));
    } else if (isInserting) {
      context.missing(_validFromMeta);
    }
    if (data.containsKey('valid_until')) {
      context.handle(
          _validUntilMeta,
          validUntil.isAcceptableOrUnknown(
              data['valid_until']!, _validUntilMeta));
    } else if (isInserting) {
      context.missing(_validUntilMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  ProviderData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderData(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}uid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      contractNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}contract_number'])!,
      notice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}notice'])!,
      validFrom: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}valid_from'])!,
      validUntil: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}valid_until'])!,
    );
  }

  @override
  $ProviderTable createAlias(String alias) {
    return $ProviderTable(attachedDatabase, alias);
  }
}

class ContractData extends DataClass implements Insertable<ContractData> {
  final int uid;
  final String meterTyp;
  final int provider;
  final double basicPrice;
  final double energyPrice;
  final double discount;
  final int bonus;
  final String note;
  const ContractData(
      {required this.uid,
      required this.meterTyp,
      required this.provider,
      required this.basicPrice,
      required this.energyPrice,
      required this.discount,
      required this.bonus,
      required this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<int>(uid);
    map['meter_typ'] = Variable<String>(meterTyp);
    map['provider'] = Variable<int>(provider);
    map['basic_price'] = Variable<double>(basicPrice);
    map['energy_price'] = Variable<double>(energyPrice);
    map['discount'] = Variable<double>(discount);
    map['bonus'] = Variable<int>(bonus);
    map['note'] = Variable<String>(note);
    return map;
  }

  ContractCompanion toCompanion(bool nullToAbsent) {
    return ContractCompanion(
      uid: Value(uid),
      meterTyp: Value(meterTyp),
      provider: Value(provider),
      basicPrice: Value(basicPrice),
      energyPrice: Value(energyPrice),
      discount: Value(discount),
      bonus: Value(bonus),
      note: Value(note),
    );
  }

  factory ContractData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContractData(
      uid: serializer.fromJson<int>(json['uid']),
      meterTyp: serializer.fromJson<String>(json['meterTyp']),
      provider: serializer.fromJson<int>(json['provider']),
      basicPrice: serializer.fromJson<double>(json['basicPrice']),
      energyPrice: serializer.fromJson<double>(json['energyPrice']),
      discount: serializer.fromJson<double>(json['discount']),
      bonus: serializer.fromJson<int>(json['bonus']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<int>(uid),
      'meterTyp': serializer.toJson<String>(meterTyp),
      'provider': serializer.toJson<int>(provider),
      'basicPrice': serializer.toJson<double>(basicPrice),
      'energyPrice': serializer.toJson<double>(energyPrice),
      'discount': serializer.toJson<double>(discount),
      'bonus': serializer.toJson<int>(bonus),
      'note': serializer.toJson<String>(note),
    };
  }

  ContractData copyWith(
          {int? uid,
          String? meterTyp,
          int? provider,
          double? basicPrice,
          double? energyPrice,
          double? discount,
          int? bonus,
          String? note}) =>
      ContractData(
        uid: uid ?? this.uid,
        meterTyp: meterTyp ?? this.meterTyp,
        provider: provider ?? this.provider,
        basicPrice: basicPrice ?? this.basicPrice,
        energyPrice: energyPrice ?? this.energyPrice,
        discount: discount ?? this.discount,
        bonus: bonus ?? this.bonus,
        note: note ?? this.note,
      );
  @override
  String toString() {
    return (StringBuffer('ContractData(')
          ..write('uid: $uid, ')
          ..write('meterTyp: $meterTyp, ')
          ..write('provider: $provider, ')
          ..write('basicPrice: $basicPrice, ')
          ..write('energyPrice: $energyPrice, ')
          ..write('discount: $discount, ')
          ..write('bonus: $bonus, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uid, meterTyp, provider, basicPrice, energyPrice, discount, bonus, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContractData &&
          other.uid == this.uid &&
          other.meterTyp == this.meterTyp &&
          other.provider == this.provider &&
          other.basicPrice == this.basicPrice &&
          other.energyPrice == this.energyPrice &&
          other.discount == this.discount &&
          other.bonus == this.bonus &&
          other.note == this.note);
}

class ContractCompanion extends UpdateCompanion<ContractData> {
  final Value<int> uid;
  final Value<String> meterTyp;
  final Value<int> provider;
  final Value<double> basicPrice;
  final Value<double> energyPrice;
  final Value<double> discount;
  final Value<int> bonus;
  final Value<String> note;
  const ContractCompanion({
    this.uid = const Value.absent(),
    this.meterTyp = const Value.absent(),
    this.provider = const Value.absent(),
    this.basicPrice = const Value.absent(),
    this.energyPrice = const Value.absent(),
    this.discount = const Value.absent(),
    this.bonus = const Value.absent(),
    this.note = const Value.absent(),
  });
  ContractCompanion.insert({
    this.uid = const Value.absent(),
    required String meterTyp,
    required int provider,
    required double basicPrice,
    required double energyPrice,
    required double discount,
    required int bonus,
    required String note,
  })  : meterTyp = Value(meterTyp),
        provider = Value(provider),
        basicPrice = Value(basicPrice),
        energyPrice = Value(energyPrice),
        discount = Value(discount),
        bonus = Value(bonus),
        note = Value(note);
  static Insertable<ContractData> custom({
    Expression<int>? uid,
    Expression<String>? meterTyp,
    Expression<int>? provider,
    Expression<double>? basicPrice,
    Expression<double>? energyPrice,
    Expression<double>? discount,
    Expression<int>? bonus,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (meterTyp != null) 'meter_typ': meterTyp,
      if (provider != null) 'provider': provider,
      if (basicPrice != null) 'basic_price': basicPrice,
      if (energyPrice != null) 'energy_price': energyPrice,
      if (discount != null) 'discount': discount,
      if (bonus != null) 'bonus': bonus,
      if (note != null) 'note': note,
    });
  }

  ContractCompanion copyWith(
      {Value<int>? uid,
      Value<String>? meterTyp,
      Value<int>? provider,
      Value<double>? basicPrice,
      Value<double>? energyPrice,
      Value<double>? discount,
      Value<int>? bonus,
      Value<String>? note}) {
    return ContractCompanion(
      uid: uid ?? this.uid,
      meterTyp: meterTyp ?? this.meterTyp,
      provider: provider ?? this.provider,
      basicPrice: basicPrice ?? this.basicPrice,
      energyPrice: energyPrice ?? this.energyPrice,
      discount: discount ?? this.discount,
      bonus: bonus ?? this.bonus,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<int>(uid.value);
    }
    if (meterTyp.present) {
      map['meter_typ'] = Variable<String>(meterTyp.value);
    }
    if (provider.present) {
      map['provider'] = Variable<int>(provider.value);
    }
    if (basicPrice.present) {
      map['basic_price'] = Variable<double>(basicPrice.value);
    }
    if (energyPrice.present) {
      map['energy_price'] = Variable<double>(energyPrice.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (bonus.present) {
      map['bonus'] = Variable<int>(bonus.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContractCompanion(')
          ..write('uid: $uid, ')
          ..write('meterTyp: $meterTyp, ')
          ..write('provider: $provider, ')
          ..write('basicPrice: $basicPrice, ')
          ..write('energyPrice: $energyPrice, ')
          ..write('discount: $discount, ')
          ..write('bonus: $bonus, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $ContractTable extends Contract
    with TableInfo<$ContractTable, ContractData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContractTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<int> uid = GeneratedColumn<int>(
      'uid', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _meterTypMeta =
      const VerificationMeta('meterTyp');
  @override
  late final GeneratedColumn<String> meterTyp = GeneratedColumn<String>(
      'meter_typ', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<int> provider = GeneratedColumn<int>(
      'provider', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES provider (uid) ON DELETE CASCADE'));
  static const VerificationMeta _basicPriceMeta =
      const VerificationMeta('basicPrice');
  @override
  late final GeneratedColumn<double> basicPrice = GeneratedColumn<double>(
      'basic_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _energyPriceMeta =
      const VerificationMeta('energyPrice');
  @override
  late final GeneratedColumn<double> energyPrice = GeneratedColumn<double>(
      'energy_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
      'discount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _bonusMeta = const VerificationMeta('bonus');
  @override
  late final GeneratedColumn<int> bonus = GeneratedColumn<int>(
      'bonus', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [uid, meterTyp, provider, basicPrice, energyPrice, discount, bonus, note];
  @override
  String get aliasedName => _alias ?? 'contract';
  @override
  String get actualTableName => 'contract';
  @override
  VerificationContext validateIntegrity(Insertable<ContractData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    }
    if (data.containsKey('meter_typ')) {
      context.handle(_meterTypMeta,
          meterTyp.isAcceptableOrUnknown(data['meter_typ']!, _meterTypMeta));
    } else if (isInserting) {
      context.missing(_meterTypMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('basic_price')) {
      context.handle(
          _basicPriceMeta,
          basicPrice.isAcceptableOrUnknown(
              data['basic_price']!, _basicPriceMeta));
    } else if (isInserting) {
      context.missing(_basicPriceMeta);
    }
    if (data.containsKey('energy_price')) {
      context.handle(
          _energyPriceMeta,
          energyPrice.isAcceptableOrUnknown(
              data['energy_price']!, _energyPriceMeta));
    } else if (isInserting) {
      context.missing(_energyPriceMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    } else if (isInserting) {
      context.missing(_discountMeta);
    }
    if (data.containsKey('bonus')) {
      context.handle(
          _bonusMeta, bonus.isAcceptableOrUnknown(data['bonus']!, _bonusMeta));
    } else if (isInserting) {
      context.missing(_bonusMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  ContractData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContractData(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}uid'])!,
      meterTyp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meter_typ'])!,
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}provider'])!,
      basicPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}basic_price'])!,
      energyPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}energy_price'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount'])!,
      bonus: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bonus'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
    );
  }

  @override
  $ContractTable createAlias(String alias) {
    return $ContractTable(attachedDatabase, alias);
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  late final $MeterTable meter = $MeterTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $RoomTable room = $RoomTable(this);
  late final $MeterInRoomTable meterInRoom = $MeterInRoomTable(this);
  late final $ProviderTable provider = $ProviderTable(this);
  late final $ContractTable contract = $ContractTable(this);
  late final MeterDao meterDao = MeterDao(this as LocalDatabase);
  late final EntryDao entryDao = EntryDao(this as LocalDatabase);
  late final RoomDao roomDao = RoomDao(this as LocalDatabase);
  late final ContractDao contractDao = ContractDao(this as LocalDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [meter, entries, room, meterInRoom, provider, contract];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('meter',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('entries', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('meter',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('meter_in_room', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('room',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('meter_in_room', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('provider',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('contract', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}
