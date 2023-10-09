// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
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
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, typ, note, number, unit, isArchived];
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
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
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
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
    );
  }

  @override
  $MeterTable createAlias(String alias) {
    return $MeterTable(attachedDatabase, alias);
  }
}

class MeterData extends DataClass implements Insertable<MeterData> {
  final int id;
  final String typ;
  final String note;
  final String number;
  final String unit;
  final bool isArchived;
  const MeterData(
      {required this.id,
      required this.typ,
      required this.note,
      required this.number,
      required this.unit,
      required this.isArchived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['typ'] = Variable<String>(typ);
    map['note'] = Variable<String>(note);
    map['number'] = Variable<String>(number);
    map['unit'] = Variable<String>(unit);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  MeterCompanion toCompanion(bool nullToAbsent) {
    return MeterCompanion(
      id: Value(id),
      typ: Value(typ),
      note: Value(note),
      number: Value(number),
      unit: Value(unit),
      isArchived: Value(isArchived),
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
      unit: serializer.fromJson<String>(json['unit']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
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
      'unit': serializer.toJson<String>(unit),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  MeterData copyWith(
          {int? id,
          String? typ,
          String? note,
          String? number,
          String? unit,
          bool? isArchived}) =>
      MeterData(
        id: id ?? this.id,
        typ: typ ?? this.typ,
        note: note ?? this.note,
        number: number ?? this.number,
        unit: unit ?? this.unit,
        isArchived: isArchived ?? this.isArchived,
      );
  @override
  String toString() {
    return (StringBuffer('MeterData(')
          ..write('id: $id, ')
          ..write('typ: $typ, ')
          ..write('note: $note, ')
          ..write('number: $number, ')
          ..write('unit: $unit, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, typ, note, number, unit, isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeterData &&
          other.id == this.id &&
          other.typ == this.typ &&
          other.note == this.note &&
          other.number == this.number &&
          other.unit == this.unit &&
          other.isArchived == this.isArchived);
}

class MeterCompanion extends UpdateCompanion<MeterData> {
  final Value<int> id;
  final Value<String> typ;
  final Value<String> note;
  final Value<String> number;
  final Value<String> unit;
  final Value<bool> isArchived;
  const MeterCompanion({
    this.id = const Value.absent(),
    this.typ = const Value.absent(),
    this.note = const Value.absent(),
    this.number = const Value.absent(),
    this.unit = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  MeterCompanion.insert({
    this.id = const Value.absent(),
    required String typ,
    required String note,
    required String number,
    required String unit,
    this.isArchived = const Value.absent(),
  })  : typ = Value(typ),
        note = Value(note),
        number = Value(number),
        unit = Value(unit);
  static Insertable<MeterData> custom({
    Expression<int>? id,
    Expression<String>? typ,
    Expression<String>? note,
    Expression<String>? number,
    Expression<String>? unit,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typ != null) 'typ': typ,
      if (note != null) 'note': note,
      if (number != null) 'number': number,
      if (unit != null) 'unit': unit,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  MeterCompanion copyWith(
      {Value<int>? id,
      Value<String>? typ,
      Value<String>? note,
      Value<String>? number,
      Value<String>? unit,
      Value<bool>? isArchived}) {
    return MeterCompanion(
      id: id ?? this.id,
      typ: typ ?? this.typ,
      note: note ?? this.note,
      number: number ?? this.number,
      unit: unit ?? this.unit,
      isArchived: isArchived ?? this.isArchived,
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
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeterCompanion(')
          ..write('id: $id, ')
          ..write('typ: $typ, ')
          ..write('note: $note, ')
          ..write('number: $number, ')
          ..write('unit: $unit, ')
          ..write('isArchived: $isArchived')
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
  static const VerificationMeta _usageMeta = const VerificationMeta('usage');
  @override
  late final GeneratedColumn<int> usage = GeneratedColumn<int>(
      'usage', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<int> days = GeneratedColumn<int>(
      'days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, meter, count, usage, date, days, note];
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
    if (data.containsKey('usage')) {
      context.handle(
          _usageMeta, usage.isAcceptableOrUnknown(data['usage']!, _usageMeta));
    } else if (isInserting) {
      context.missing(_usageMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('days')) {
      context.handle(
          _daysMeta, days.isAcceptableOrUnknown(data['days']!, _daysMeta));
    } else if (isInserting) {
      context.missing(_daysMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
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
      usage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      days: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}days'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Entrie extends DataClass implements Insertable<Entrie> {
  final int id;
  final int meter;
  final int count;
  final int usage;
  final DateTime date;
  final int days;
  final String? note;
  const Entrie(
      {required this.id,
      required this.meter,
      required this.count,
      required this.usage,
      required this.date,
      required this.days,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meter'] = Variable<int>(meter);
    map['count'] = Variable<int>(count);
    map['usage'] = Variable<int>(usage);
    map['date'] = Variable<DateTime>(date);
    map['days'] = Variable<int>(days);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      meter: Value(meter),
      count: Value(count),
      usage: Value(usage),
      date: Value(date),
      days: Value(days),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Entrie.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entrie(
      id: serializer.fromJson<int>(json['id']),
      meter: serializer.fromJson<int>(json['meter']),
      count: serializer.fromJson<int>(json['count']),
      usage: serializer.fromJson<int>(json['usage']),
      date: serializer.fromJson<DateTime>(json['date']),
      days: serializer.fromJson<int>(json['days']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'meter': serializer.toJson<int>(meter),
      'count': serializer.toJson<int>(count),
      'usage': serializer.toJson<int>(usage),
      'date': serializer.toJson<DateTime>(date),
      'days': serializer.toJson<int>(days),
      'note': serializer.toJson<String?>(note),
    };
  }

  Entrie copyWith(
          {int? id,
          int? meter,
          int? count,
          int? usage,
          DateTime? date,
          int? days,
          Value<String?> note = const Value.absent()}) =>
      Entrie(
        id: id ?? this.id,
        meter: meter ?? this.meter,
        count: count ?? this.count,
        usage: usage ?? this.usage,
        date: date ?? this.date,
        days: days ?? this.days,
        note: note.present ? note.value : this.note,
      );
  @override
  String toString() {
    return (StringBuffer('Entrie(')
          ..write('id: $id, ')
          ..write('meter: $meter, ')
          ..write('count: $count, ')
          ..write('usage: $usage, ')
          ..write('date: $date, ')
          ..write('days: $days, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, meter, count, usage, date, days, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entrie &&
          other.id == this.id &&
          other.meter == this.meter &&
          other.count == this.count &&
          other.usage == this.usage &&
          other.date == this.date &&
          other.days == this.days &&
          other.note == this.note);
}

class EntriesCompanion extends UpdateCompanion<Entrie> {
  final Value<int> id;
  final Value<int> meter;
  final Value<int> count;
  final Value<int> usage;
  final Value<DateTime> date;
  final Value<int> days;
  final Value<String?> note;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.meter = const Value.absent(),
    this.count = const Value.absent(),
    this.usage = const Value.absent(),
    this.date = const Value.absent(),
    this.days = const Value.absent(),
    this.note = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required int meter,
    required int count,
    required int usage,
    required DateTime date,
    required int days,
    this.note = const Value.absent(),
  })  : meter = Value(meter),
        count = Value(count),
        usage = Value(usage),
        date = Value(date),
        days = Value(days);
  static Insertable<Entrie> custom({
    Expression<int>? id,
    Expression<int>? meter,
    Expression<int>? count,
    Expression<int>? usage,
    Expression<DateTime>? date,
    Expression<int>? days,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (meter != null) 'meter': meter,
      if (count != null) 'count': count,
      if (usage != null) 'usage': usage,
      if (date != null) 'date': date,
      if (days != null) 'days': days,
      if (note != null) 'note': note,
    });
  }

  EntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? meter,
      Value<int>? count,
      Value<int>? usage,
      Value<DateTime>? date,
      Value<int>? days,
      Value<String?>? note}) {
    return EntriesCompanion(
      id: id ?? this.id,
      meter: meter ?? this.meter,
      count: count ?? this.count,
      usage: usage ?? this.usage,
      date: date ?? this.date,
      days: days ?? this.days,
      note: note ?? this.note,
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
    if (usage.present) {
      map['usage'] = Variable<int>(usage.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (days.present) {
      map['days'] = Variable<int>(days.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('meter: $meter, ')
          ..write('count: $count, ')
          ..write('usage: $usage, ')
          ..write('date: $date, ')
          ..write('days: $days, ')
          ..write('note: $note')
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  List<GeneratedColumn> get $columns => [id, uuid, name, typ];
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
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
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
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
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

class RoomData extends DataClass implements Insertable<RoomData> {
  final int id;
  final String uuid;
  final String name;
  final String typ;
  const RoomData(
      {required this.id,
      required this.uuid,
      required this.name,
      required this.typ});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['typ'] = Variable<String>(typ);
    return map;
  }

  RoomCompanion toCompanion(bool nullToAbsent) {
    return RoomCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      typ: Value(typ),
    );
  }

  factory RoomData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomData(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      typ: serializer.fromJson<String>(json['typ']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'typ': serializer.toJson<String>(typ),
    };
  }

  RoomData copyWith({int? id, String? uuid, String? name, String? typ}) =>
      RoomData(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        typ: typ ?? this.typ,
      );
  @override
  String toString() {
    return (StringBuffer('RoomData(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('typ: $typ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, name, typ);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomData &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.typ == this.typ);
}

class RoomCompanion extends UpdateCompanion<RoomData> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> typ;
  const RoomCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.typ = const Value.absent(),
  });
  RoomCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    required String typ,
  })  : uuid = Value(uuid),
        name = Value(name),
        typ = Value(typ);
  static Insertable<RoomData> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? typ,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (typ != null) 'typ': typ,
    });
  }

  RoomCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? name,
      Value<String>? typ}) {
    return RoomCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
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
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
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
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('typ: $typ')
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
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
          .read(DriftSqlType.string, data['${effectivePrefix}room_id'])!,
    );
  }

  @override
  $MeterInRoomTable createAlias(String alias) {
    return $MeterInRoomTable(attachedDatabase, alias);
  }
}

class MeterInRoomData extends DataClass implements Insertable<MeterInRoomData> {
  final int meterId;
  final String roomId;
  const MeterInRoomData({required this.meterId, required this.roomId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meter_id'] = Variable<int>(meterId);
    map['room_id'] = Variable<String>(roomId);
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
      roomId: serializer.fromJson<String>(json['roomId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'meterId': serializer.toJson<int>(meterId),
      'roomId': serializer.toJson<String>(roomId),
    };
  }

  MeterInRoomData copyWith({int? meterId, String? roomId}) => MeterInRoomData(
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
  final Value<String> roomId;
  final Value<int> rowid;
  const MeterInRoomCompanion({
    this.meterId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeterInRoomCompanion.insert({
    required int meterId,
    required String roomId,
    this.rowid = const Value.absent(),
  })  : meterId = Value(meterId),
        roomId = Value(roomId);
  static Insertable<MeterInRoomData> custom({
    Expression<int>? meterId,
    Expression<String>? roomId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (meterId != null) 'meter_id': meterId,
      if (roomId != null) 'room_id': roomId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeterInRoomCompanion copyWith(
      {Value<int>? meterId, Value<String>? roomId, Value<int>? rowid}) {
    return MeterInRoomCompanion(
      meterId: meterId ?? this.meterId,
      roomId: roomId ?? this.roomId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (meterId.present) {
      map['meter_id'] = Variable<int>(meterId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeterInRoomCompanion(')
          ..write('meterId: $meterId, ')
          ..write('roomId: $roomId, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _contractNumberMeta =
      const VerificationMeta('contractNumber');
  @override
  late final GeneratedColumn<String> contractNumber = GeneratedColumn<String>(
      'contract_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noticeMeta = const VerificationMeta('notice');
  @override
  late final GeneratedColumn<int> notice = GeneratedColumn<int>(
      'notice', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
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
  static const VerificationMeta _renewalMeta =
      const VerificationMeta('renewal');
  @override
  late final GeneratedColumn<int> renewal = GeneratedColumn<int>(
      'renewal', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _canceledMeta =
      const VerificationMeta('canceled');
  @override
  late final GeneratedColumn<bool> canceled = GeneratedColumn<bool>(
      'canceled', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("canceled" IN (0, 1))'));
  static const VerificationMeta _canceledDateMeta =
      const VerificationMeta('canceledDate');
  @override
  late final GeneratedColumn<DateTime> canceledDate = GeneratedColumn<DateTime>(
      'canceled_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        contractNumber,
        notice,
        validFrom,
        validUntil,
        renewal,
        canceled,
        canceledDate
      ];
  @override
  String get aliasedName => _alias ?? 'provider';
  @override
  String get actualTableName => 'provider';
  @override
  VerificationContext validateIntegrity(Insertable<ProviderData> instance,
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
    if (data.containsKey('renewal')) {
      context.handle(_renewalMeta,
          renewal.isAcceptableOrUnknown(data['renewal']!, _renewalMeta));
    }
    if (data.containsKey('canceled')) {
      context.handle(_canceledMeta,
          canceled.isAcceptableOrUnknown(data['canceled']!, _canceledMeta));
    }
    if (data.containsKey('canceled_date')) {
      context.handle(
          _canceledDateMeta,
          canceledDate.isAcceptableOrUnknown(
              data['canceled_date']!, _canceledDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProviderData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      contractNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}contract_number'])!,
      notice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}notice']),
      validFrom: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}valid_from'])!,
      validUntil: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}valid_until'])!,
      renewal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}renewal']),
      canceled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}canceled']),
      canceledDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}canceled_date']),
    );
  }

  @override
  $ProviderTable createAlias(String alias) {
    return $ProviderTable(attachedDatabase, alias);
  }
}

class ProviderData extends DataClass implements Insertable<ProviderData> {
  final int id;
  final String name;
  final String contractNumber;
  final int? notice;
  final DateTime validFrom;
  final DateTime validUntil;
  final int? renewal;
  final bool? canceled;
  final DateTime? canceledDate;
  const ProviderData(
      {required this.id,
      required this.name,
      required this.contractNumber,
      this.notice,
      required this.validFrom,
      required this.validUntil,
      this.renewal,
      this.canceled,
      this.canceledDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['contract_number'] = Variable<String>(contractNumber);
    if (!nullToAbsent || notice != null) {
      map['notice'] = Variable<int>(notice);
    }
    map['valid_from'] = Variable<DateTime>(validFrom);
    map['valid_until'] = Variable<DateTime>(validUntil);
    if (!nullToAbsent || renewal != null) {
      map['renewal'] = Variable<int>(renewal);
    }
    if (!nullToAbsent || canceled != null) {
      map['canceled'] = Variable<bool>(canceled);
    }
    if (!nullToAbsent || canceledDate != null) {
      map['canceled_date'] = Variable<DateTime>(canceledDate);
    }
    return map;
  }

  ProviderCompanion toCompanion(bool nullToAbsent) {
    return ProviderCompanion(
      id: Value(id),
      name: Value(name),
      contractNumber: Value(contractNumber),
      notice:
          notice == null && nullToAbsent ? const Value.absent() : Value(notice),
      validFrom: Value(validFrom),
      validUntil: Value(validUntil),
      renewal: renewal == null && nullToAbsent
          ? const Value.absent()
          : Value(renewal),
      canceled: canceled == null && nullToAbsent
          ? const Value.absent()
          : Value(canceled),
      canceledDate: canceledDate == null && nullToAbsent
          ? const Value.absent()
          : Value(canceledDate),
    );
  }

  factory ProviderData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contractNumber: serializer.fromJson<String>(json['contractNumber']),
      notice: serializer.fromJson<int?>(json['notice']),
      validFrom: serializer.fromJson<DateTime>(json['validFrom']),
      validUntil: serializer.fromJson<DateTime>(json['validUntil']),
      renewal: serializer.fromJson<int?>(json['renewal']),
      canceled: serializer.fromJson<bool?>(json['canceled']),
      canceledDate: serializer.fromJson<DateTime?>(json['canceledDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'contractNumber': serializer.toJson<String>(contractNumber),
      'notice': serializer.toJson<int?>(notice),
      'validFrom': serializer.toJson<DateTime>(validFrom),
      'validUntil': serializer.toJson<DateTime>(validUntil),
      'renewal': serializer.toJson<int?>(renewal),
      'canceled': serializer.toJson<bool?>(canceled),
      'canceledDate': serializer.toJson<DateTime?>(canceledDate),
    };
  }

  ProviderData copyWith(
          {int? id,
          String? name,
          String? contractNumber,
          Value<int?> notice = const Value.absent(),
          DateTime? validFrom,
          DateTime? validUntil,
          Value<int?> renewal = const Value.absent(),
          Value<bool?> canceled = const Value.absent(),
          Value<DateTime?> canceledDate = const Value.absent()}) =>
      ProviderData(
        id: id ?? this.id,
        name: name ?? this.name,
        contractNumber: contractNumber ?? this.contractNumber,
        notice: notice.present ? notice.value : this.notice,
        validFrom: validFrom ?? this.validFrom,
        validUntil: validUntil ?? this.validUntil,
        renewal: renewal.present ? renewal.value : this.renewal,
        canceled: canceled.present ? canceled.value : this.canceled,
        canceledDate:
            canceledDate.present ? canceledDate.value : this.canceledDate,
      );
  @override
  String toString() {
    return (StringBuffer('ProviderData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contractNumber: $contractNumber, ')
          ..write('notice: $notice, ')
          ..write('validFrom: $validFrom, ')
          ..write('validUntil: $validUntil, ')
          ..write('renewal: $renewal, ')
          ..write('canceled: $canceled, ')
          ..write('canceledDate: $canceledDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, contractNumber, notice, validFrom,
      validUntil, renewal, canceled, canceledDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderData &&
          other.id == this.id &&
          other.name == this.name &&
          other.contractNumber == this.contractNumber &&
          other.notice == this.notice &&
          other.validFrom == this.validFrom &&
          other.validUntil == this.validUntil &&
          other.renewal == this.renewal &&
          other.canceled == this.canceled &&
          other.canceledDate == this.canceledDate);
}

class ProviderCompanion extends UpdateCompanion<ProviderData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> contractNumber;
  final Value<int?> notice;
  final Value<DateTime> validFrom;
  final Value<DateTime> validUntil;
  final Value<int?> renewal;
  final Value<bool?> canceled;
  final Value<DateTime?> canceledDate;
  const ProviderCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contractNumber = const Value.absent(),
    this.notice = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.renewal = const Value.absent(),
    this.canceled = const Value.absent(),
    this.canceledDate = const Value.absent(),
  });
  ProviderCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String contractNumber,
    this.notice = const Value.absent(),
    required DateTime validFrom,
    required DateTime validUntil,
    this.renewal = const Value.absent(),
    this.canceled = const Value.absent(),
    this.canceledDate = const Value.absent(),
  })  : name = Value(name),
        contractNumber = Value(contractNumber),
        validFrom = Value(validFrom),
        validUntil = Value(validUntil);
  static Insertable<ProviderData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? contractNumber,
    Expression<int>? notice,
    Expression<DateTime>? validFrom,
    Expression<DateTime>? validUntil,
    Expression<int>? renewal,
    Expression<bool>? canceled,
    Expression<DateTime>? canceledDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contractNumber != null) 'contract_number': contractNumber,
      if (notice != null) 'notice': notice,
      if (validFrom != null) 'valid_from': validFrom,
      if (validUntil != null) 'valid_until': validUntil,
      if (renewal != null) 'renewal': renewal,
      if (canceled != null) 'canceled': canceled,
      if (canceledDate != null) 'canceled_date': canceledDate,
    });
  }

  ProviderCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? contractNumber,
      Value<int?>? notice,
      Value<DateTime>? validFrom,
      Value<DateTime>? validUntil,
      Value<int?>? renewal,
      Value<bool?>? canceled,
      Value<DateTime?>? canceledDate}) {
    return ProviderCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contractNumber: contractNumber ?? this.contractNumber,
      notice: notice ?? this.notice,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      renewal: renewal ?? this.renewal,
      canceled: canceled ?? this.canceled,
      canceledDate: canceledDate ?? this.canceledDate,
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
    if (renewal.present) {
      map['renewal'] = Variable<int>(renewal.value);
    }
    if (canceled.present) {
      map['canceled'] = Variable<bool>(canceled.value);
    }
    if (canceledDate.present) {
      map['canceled_date'] = Variable<DateTime>(canceledDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contractNumber: $contractNumber, ')
          ..write('notice: $notice, ')
          ..write('validFrom: $validFrom, ')
          ..write('validUntil: $validUntil, ')
          ..write('renewal: $renewal, ')
          ..write('canceled: $canceled, ')
          ..write('canceledDate: $canceledDate')
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
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
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
      'provider', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES provider (id) ON DELETE SET NULL'));
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
      'bonus', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        meterTyp,
        provider,
        basicPrice,
        energyPrice,
        discount,
        bonus,
        note,
        unit,
        isArchived
      ];
  @override
  String get aliasedName => _alias ?? 'contract';
  @override
  String get actualTableName => 'contract';
  @override
  VerificationContext validateIntegrity(Insertable<ContractData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContractData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContractData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      meterTyp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meter_typ'])!,
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}provider']),
      basicPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}basic_price'])!,
      energyPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}energy_price'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount'])!,
      bonus: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bonus']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
    );
  }

  @override
  $ContractTable createAlias(String alias) {
    return $ContractTable(attachedDatabase, alias);
  }
}

class ContractData extends DataClass implements Insertable<ContractData> {
  final int id;
  final String meterTyp;
  final int? provider;
  final double basicPrice;
  final double energyPrice;
  final double discount;
  final int? bonus;
  final String note;
  final String unit;
  final bool isArchived;
  const ContractData(
      {required this.id,
      required this.meterTyp,
      this.provider,
      required this.basicPrice,
      required this.energyPrice,
      required this.discount,
      this.bonus,
      required this.note,
      required this.unit,
      required this.isArchived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meter_typ'] = Variable<String>(meterTyp);
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<int>(provider);
    }
    map['basic_price'] = Variable<double>(basicPrice);
    map['energy_price'] = Variable<double>(energyPrice);
    map['discount'] = Variable<double>(discount);
    if (!nullToAbsent || bonus != null) {
      map['bonus'] = Variable<int>(bonus);
    }
    map['note'] = Variable<String>(note);
    map['unit'] = Variable<String>(unit);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  ContractCompanion toCompanion(bool nullToAbsent) {
    return ContractCompanion(
      id: Value(id),
      meterTyp: Value(meterTyp),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      basicPrice: Value(basicPrice),
      energyPrice: Value(energyPrice),
      discount: Value(discount),
      bonus:
          bonus == null && nullToAbsent ? const Value.absent() : Value(bonus),
      note: Value(note),
      unit: Value(unit),
      isArchived: Value(isArchived),
    );
  }

  factory ContractData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContractData(
      id: serializer.fromJson<int>(json['id']),
      meterTyp: serializer.fromJson<String>(json['meterTyp']),
      provider: serializer.fromJson<int?>(json['provider']),
      basicPrice: serializer.fromJson<double>(json['basicPrice']),
      energyPrice: serializer.fromJson<double>(json['energyPrice']),
      discount: serializer.fromJson<double>(json['discount']),
      bonus: serializer.fromJson<int?>(json['bonus']),
      note: serializer.fromJson<String>(json['note']),
      unit: serializer.fromJson<String>(json['unit']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'meterTyp': serializer.toJson<String>(meterTyp),
      'provider': serializer.toJson<int?>(provider),
      'basicPrice': serializer.toJson<double>(basicPrice),
      'energyPrice': serializer.toJson<double>(energyPrice),
      'discount': serializer.toJson<double>(discount),
      'bonus': serializer.toJson<int?>(bonus),
      'note': serializer.toJson<String>(note),
      'unit': serializer.toJson<String>(unit),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  ContractData copyWith(
          {int? id,
          String? meterTyp,
          Value<int?> provider = const Value.absent(),
          double? basicPrice,
          double? energyPrice,
          double? discount,
          Value<int?> bonus = const Value.absent(),
          String? note,
          String? unit,
          bool? isArchived}) =>
      ContractData(
        id: id ?? this.id,
        meterTyp: meterTyp ?? this.meterTyp,
        provider: provider.present ? provider.value : this.provider,
        basicPrice: basicPrice ?? this.basicPrice,
        energyPrice: energyPrice ?? this.energyPrice,
        discount: discount ?? this.discount,
        bonus: bonus.present ? bonus.value : this.bonus,
        note: note ?? this.note,
        unit: unit ?? this.unit,
        isArchived: isArchived ?? this.isArchived,
      );
  @override
  String toString() {
    return (StringBuffer('ContractData(')
          ..write('id: $id, ')
          ..write('meterTyp: $meterTyp, ')
          ..write('provider: $provider, ')
          ..write('basicPrice: $basicPrice, ')
          ..write('energyPrice: $energyPrice, ')
          ..write('discount: $discount, ')
          ..write('bonus: $bonus, ')
          ..write('note: $note, ')
          ..write('unit: $unit, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, meterTyp, provider, basicPrice,
      energyPrice, discount, bonus, note, unit, isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContractData &&
          other.id == this.id &&
          other.meterTyp == this.meterTyp &&
          other.provider == this.provider &&
          other.basicPrice == this.basicPrice &&
          other.energyPrice == this.energyPrice &&
          other.discount == this.discount &&
          other.bonus == this.bonus &&
          other.note == this.note &&
          other.unit == this.unit &&
          other.isArchived == this.isArchived);
}

class ContractCompanion extends UpdateCompanion<ContractData> {
  final Value<int> id;
  final Value<String> meterTyp;
  final Value<int?> provider;
  final Value<double> basicPrice;
  final Value<double> energyPrice;
  final Value<double> discount;
  final Value<int?> bonus;
  final Value<String> note;
  final Value<String> unit;
  final Value<bool> isArchived;
  const ContractCompanion({
    this.id = const Value.absent(),
    this.meterTyp = const Value.absent(),
    this.provider = const Value.absent(),
    this.basicPrice = const Value.absent(),
    this.energyPrice = const Value.absent(),
    this.discount = const Value.absent(),
    this.bonus = const Value.absent(),
    this.note = const Value.absent(),
    this.unit = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  ContractCompanion.insert({
    this.id = const Value.absent(),
    required String meterTyp,
    this.provider = const Value.absent(),
    required double basicPrice,
    required double energyPrice,
    required double discount,
    this.bonus = const Value.absent(),
    required String note,
    required String unit,
    this.isArchived = const Value.absent(),
  })  : meterTyp = Value(meterTyp),
        basicPrice = Value(basicPrice),
        energyPrice = Value(energyPrice),
        discount = Value(discount),
        note = Value(note),
        unit = Value(unit);
  static Insertable<ContractData> custom({
    Expression<int>? id,
    Expression<String>? meterTyp,
    Expression<int>? provider,
    Expression<double>? basicPrice,
    Expression<double>? energyPrice,
    Expression<double>? discount,
    Expression<int>? bonus,
    Expression<String>? note,
    Expression<String>? unit,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (meterTyp != null) 'meter_typ': meterTyp,
      if (provider != null) 'provider': provider,
      if (basicPrice != null) 'basic_price': basicPrice,
      if (energyPrice != null) 'energy_price': energyPrice,
      if (discount != null) 'discount': discount,
      if (bonus != null) 'bonus': bonus,
      if (note != null) 'note': note,
      if (unit != null) 'unit': unit,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  ContractCompanion copyWith(
      {Value<int>? id,
      Value<String>? meterTyp,
      Value<int?>? provider,
      Value<double>? basicPrice,
      Value<double>? energyPrice,
      Value<double>? discount,
      Value<int?>? bonus,
      Value<String>? note,
      Value<String>? unit,
      Value<bool>? isArchived}) {
    return ContractCompanion(
      id: id ?? this.id,
      meterTyp: meterTyp ?? this.meterTyp,
      provider: provider ?? this.provider,
      basicPrice: basicPrice ?? this.basicPrice,
      energyPrice: energyPrice ?? this.energyPrice,
      discount: discount ?? this.discount,
      bonus: bonus ?? this.bonus,
      note: note ?? this.note,
      unit: unit ?? this.unit,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContractCompanion(')
          ..write('id: $id, ')
          ..write('meterTyp: $meterTyp, ')
          ..write('provider: $provider, ')
          ..write('basicPrice: $basicPrice, ')
          ..write('energyPrice: $energyPrice, ')
          ..write('discount: $discount, ')
          ..write('bonus: $bonus, ')
          ..write('note: $note, ')
          ..write('unit: $unit, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, uuid, name, color];
  @override
  String get aliasedName => _alias ?? 'tags';
  @override
  String get actualTableName => 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String uuid;
  final String name;
  final int color;
  const Tag(
      {required this.id,
      required this.uuid,
      required this.name,
      required this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      color: Value(color),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
    };
  }

  Tag copyWith({int? id, String? uuid, String? name, int? color}) => Tag(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        color: color ?? this.color,
      );
  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<int> color;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    required int color,
  })  : uuid = Value(uuid),
        name = Value(name),
        color = Value(color);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<int>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
    });
  }

  TagsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? name,
      Value<int>? color}) {
    return TagsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $MeterWithTagsTable extends MeterWithTags
    with TableInfo<$MeterWithTagsTable, MeterWithTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeterWithTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _meterIdMeta =
      const VerificationMeta('meterId');
  @override
  late final GeneratedColumn<int> meterId = GeneratedColumn<int>(
      'meter_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES meter (id) ON DELETE CASCADE'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [meterId, tagId];
  @override
  String get aliasedName => _alias ?? 'meter_with_tags';
  @override
  String get actualTableName => 'meter_with_tags';
  @override
  VerificationContext validateIntegrity(Insertable<MeterWithTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('meter_id')) {
      context.handle(_meterIdMeta,
          meterId.isAcceptableOrUnknown(data['meter_id']!, _meterIdMeta));
    } else if (isInserting) {
      context.missing(_meterIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {meterId, tagId};
  @override
  MeterWithTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeterWithTag(
      meterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}meter_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $MeterWithTagsTable createAlias(String alias) {
    return $MeterWithTagsTable(attachedDatabase, alias);
  }
}

class MeterWithTag extends DataClass implements Insertable<MeterWithTag> {
  final int meterId;
  final String tagId;
  const MeterWithTag({required this.meterId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meter_id'] = Variable<int>(meterId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  MeterWithTagsCompanion toCompanion(bool nullToAbsent) {
    return MeterWithTagsCompanion(
      meterId: Value(meterId),
      tagId: Value(tagId),
    );
  }

  factory MeterWithTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeterWithTag(
      meterId: serializer.fromJson<int>(json['meterId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'meterId': serializer.toJson<int>(meterId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  MeterWithTag copyWith({int? meterId, String? tagId}) => MeterWithTag(
        meterId: meterId ?? this.meterId,
        tagId: tagId ?? this.tagId,
      );
  @override
  String toString() {
    return (StringBuffer('MeterWithTag(')
          ..write('meterId: $meterId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(meterId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeterWithTag &&
          other.meterId == this.meterId &&
          other.tagId == this.tagId);
}

class MeterWithTagsCompanion extends UpdateCompanion<MeterWithTag> {
  final Value<int> meterId;
  final Value<String> tagId;
  final Value<int> rowid;
  const MeterWithTagsCompanion({
    this.meterId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeterWithTagsCompanion.insert({
    required int meterId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : meterId = Value(meterId),
        tagId = Value(tagId);
  static Insertable<MeterWithTag> custom({
    Expression<int>? meterId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (meterId != null) 'meter_id': meterId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeterWithTagsCompanion copyWith(
      {Value<int>? meterId, Value<String>? tagId, Value<int>? rowid}) {
    return MeterWithTagsCompanion(
      meterId: meterId ?? this.meterId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (meterId.present) {
      map['meter_id'] = Variable<int>(meterId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeterWithTagsCompanion(')
          ..write('meterId: $meterId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CostCompareTable extends CostCompare
    with TableInfo<$CostCompareTable, CostCompareData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CostCompareTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
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
  static const VerificationMeta _bonusMeta = const VerificationMeta('bonus');
  @override
  late final GeneratedColumn<int> bonus = GeneratedColumn<int>(
      'bonus', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _usageMeta = const VerificationMeta('usage');
  @override
  late final GeneratedColumn<int> usage = GeneratedColumn<int>(
      'usage', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
      'parent_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES contract (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, basicPrice, energyPrice, bonus, usage, parentId];
  @override
  String get aliasedName => _alias ?? 'cost_compare';
  @override
  String get actualTableName => 'cost_compare';
  @override
  VerificationContext validateIntegrity(Insertable<CostCompareData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('bonus')) {
      context.handle(
          _bonusMeta, bonus.isAcceptableOrUnknown(data['bonus']!, _bonusMeta));
    } else if (isInserting) {
      context.missing(_bonusMeta);
    }
    if (data.containsKey('usage')) {
      context.handle(
          _usageMeta, usage.isAcceptableOrUnknown(data['usage']!, _usageMeta));
    } else if (isInserting) {
      context.missing(_usageMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    } else if (isInserting) {
      context.missing(_parentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CostCompareData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CostCompareData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      basicPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}basic_price'])!,
      energyPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}energy_price'])!,
      bonus: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bonus'])!,
      usage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_id'])!,
    );
  }

  @override
  $CostCompareTable createAlias(String alias) {
    return $CostCompareTable(attachedDatabase, alias);
  }
}

class CostCompareData extends DataClass implements Insertable<CostCompareData> {
  final int id;
  final double basicPrice;
  final double energyPrice;
  final int bonus;
  final int usage;
  final int parentId;
  const CostCompareData(
      {required this.id,
      required this.basicPrice,
      required this.energyPrice,
      required this.bonus,
      required this.usage,
      required this.parentId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['basic_price'] = Variable<double>(basicPrice);
    map['energy_price'] = Variable<double>(energyPrice);
    map['bonus'] = Variable<int>(bonus);
    map['usage'] = Variable<int>(usage);
    map['parent_id'] = Variable<int>(parentId);
    return map;
  }

  CostCompareCompanion toCompanion(bool nullToAbsent) {
    return CostCompareCompanion(
      id: Value(id),
      basicPrice: Value(basicPrice),
      energyPrice: Value(energyPrice),
      bonus: Value(bonus),
      usage: Value(usage),
      parentId: Value(parentId),
    );
  }

  factory CostCompareData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CostCompareData(
      id: serializer.fromJson<int>(json['id']),
      basicPrice: serializer.fromJson<double>(json['basicPrice']),
      energyPrice: serializer.fromJson<double>(json['energyPrice']),
      bonus: serializer.fromJson<int>(json['bonus']),
      usage: serializer.fromJson<int>(json['usage']),
      parentId: serializer.fromJson<int>(json['parentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'basicPrice': serializer.toJson<double>(basicPrice),
      'energyPrice': serializer.toJson<double>(energyPrice),
      'bonus': serializer.toJson<int>(bonus),
      'usage': serializer.toJson<int>(usage),
      'parentId': serializer.toJson<int>(parentId),
    };
  }

  CostCompareData copyWith(
          {int? id,
          double? basicPrice,
          double? energyPrice,
          int? bonus,
          int? usage,
          int? parentId}) =>
      CostCompareData(
        id: id ?? this.id,
        basicPrice: basicPrice ?? this.basicPrice,
        energyPrice: energyPrice ?? this.energyPrice,
        bonus: bonus ?? this.bonus,
        usage: usage ?? this.usage,
        parentId: parentId ?? this.parentId,
      );
  @override
  String toString() {
    return (StringBuffer('CostCompareData(')
          ..write('id: $id, ')
          ..write('basicPrice: $basicPrice, ')
          ..write('energyPrice: $energyPrice, ')
          ..write('bonus: $bonus, ')
          ..write('usage: $usage, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, basicPrice, energyPrice, bonus, usage, parentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CostCompareData &&
          other.id == this.id &&
          other.basicPrice == this.basicPrice &&
          other.energyPrice == this.energyPrice &&
          other.bonus == this.bonus &&
          other.usage == this.usage &&
          other.parentId == this.parentId);
}

class CostCompareCompanion extends UpdateCompanion<CostCompareData> {
  final Value<int> id;
  final Value<double> basicPrice;
  final Value<double> energyPrice;
  final Value<int> bonus;
  final Value<int> usage;
  final Value<int> parentId;
  const CostCompareCompanion({
    this.id = const Value.absent(),
    this.basicPrice = const Value.absent(),
    this.energyPrice = const Value.absent(),
    this.bonus = const Value.absent(),
    this.usage = const Value.absent(),
    this.parentId = const Value.absent(),
  });
  CostCompareCompanion.insert({
    this.id = const Value.absent(),
    required double basicPrice,
    required double energyPrice,
    required int bonus,
    required int usage,
    required int parentId,
  })  : basicPrice = Value(basicPrice),
        energyPrice = Value(energyPrice),
        bonus = Value(bonus),
        usage = Value(usage),
        parentId = Value(parentId);
  static Insertable<CostCompareData> custom({
    Expression<int>? id,
    Expression<double>? basicPrice,
    Expression<double>? energyPrice,
    Expression<int>? bonus,
    Expression<int>? usage,
    Expression<int>? parentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (basicPrice != null) 'basic_price': basicPrice,
      if (energyPrice != null) 'energy_price': energyPrice,
      if (bonus != null) 'bonus': bonus,
      if (usage != null) 'usage': usage,
      if (parentId != null) 'parent_id': parentId,
    });
  }

  CostCompareCompanion copyWith(
      {Value<int>? id,
      Value<double>? basicPrice,
      Value<double>? energyPrice,
      Value<int>? bonus,
      Value<int>? usage,
      Value<int>? parentId}) {
    return CostCompareCompanion(
      id: id ?? this.id,
      basicPrice: basicPrice ?? this.basicPrice,
      energyPrice: energyPrice ?? this.energyPrice,
      bonus: bonus ?? this.bonus,
      usage: usage ?? this.usage,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (basicPrice.present) {
      map['basic_price'] = Variable<double>(basicPrice.value);
    }
    if (energyPrice.present) {
      map['energy_price'] = Variable<double>(energyPrice.value);
    }
    if (bonus.present) {
      map['bonus'] = Variable<int>(bonus.value);
    }
    if (usage.present) {
      map['usage'] = Variable<int>(usage.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CostCompareCompanion(')
          ..write('id: $id, ')
          ..write('basicPrice: $basicPrice, ')
          ..write('energyPrice: $energyPrice, ')
          ..write('bonus: $bonus, ')
          ..write('usage: $usage, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
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
  late final $TagsTable tags = $TagsTable(this);
  late final $MeterWithTagsTable meterWithTags = $MeterWithTagsTable(this);
  late final $CostCompareTable costCompare = $CostCompareTable(this);
  late final MeterDao meterDao = MeterDao(this as LocalDatabase);
  late final EntryDao entryDao = EntryDao(this as LocalDatabase);
  late final RoomDao roomDao = RoomDao(this as LocalDatabase);
  late final ContractDao contractDao = ContractDao(this as LocalDatabase);
  late final TagsDao tagsDao = TagsDao(this as LocalDatabase);
  late final CostCompareDao costCompareDao =
      CostCompareDao(this as LocalDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        meter,
        entries,
        room,
        meterInRoom,
        provider,
        contract,
        tags,
        meterWithTags,
        costCompare
      ];
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
            on: TableUpdateQuery.onTableName('provider',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('contract', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('meter',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('meter_with_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('contract',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('cost_compare', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}
