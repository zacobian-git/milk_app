// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milk_database.dart';

// ignore_for_file: type=lint
class $VendorsTable extends Vendors with TableInfo<$VendorsTable, Vendor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VendorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _milkTypeMeta = const VerificationMeta(
    'milkType',
  );
  @override
  late final GeneratedColumn<String> milkType = GeneratedColumn<String>(
    'milk_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultQtyMlMeta = const VerificationMeta(
    'defaultQtyMl',
  );
  @override
  late final GeneratedColumn<int> defaultQtyMl = GeneratedColumn<int>(
    'default_qty_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveryTimeMeta = const VerificationMeta(
    'deliveryTime',
  );
  @override
  late final GeneratedColumn<String> deliveryTime = GeneratedColumn<String>(
    'delivery_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingBalancePaiseMeta =
      const VerificationMeta('openingBalancePaise');
  @override
  late final GeneratedColumn<int> openingBalancePaise = GeneratedColumn<int>(
    'opening_balance_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    milkType,
    defaultQtyMl,
    deliveryTime,
    notes,
    openingBalancePaise,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vendors';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vendor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('milk_type')) {
      context.handle(
        _milkTypeMeta,
        milkType.isAcceptableOrUnknown(data['milk_type']!, _milkTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_milkTypeMeta);
    }
    if (data.containsKey('default_qty_ml')) {
      context.handle(
        _defaultQtyMlMeta,
        defaultQtyMl.isAcceptableOrUnknown(
          data['default_qty_ml']!,
          _defaultQtyMlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultQtyMlMeta);
    }
    if (data.containsKey('delivery_time')) {
      context.handle(
        _deliveryTimeMeta,
        deliveryTime.isAcceptableOrUnknown(
          data['delivery_time']!,
          _deliveryTimeMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('opening_balance_paise')) {
      context.handle(
        _openingBalancePaiseMeta,
        openingBalancePaise.isAcceptableOrUnknown(
          data['opening_balance_paise']!,
          _openingBalancePaiseMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vendor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vendor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      milkType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}milk_type'],
      )!,
      defaultQtyMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_qty_ml'],
      )!,
      deliveryTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_time'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      openingBalancePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_paise'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VendorsTable createAlias(String alias) {
    return $VendorsTable(attachedDatabase, alias);
  }
}

class Vendor extends DataClass implements Insertable<Vendor> {
  final int id;
  final String name;
  final String? phone;
  final String milkType;
  final int defaultQtyMl;
  final String? deliveryTime;
  final String? notes;
  final int openingBalancePaise;
  final bool isActive;
  final DateTime createdAt;
  const Vendor({
    required this.id,
    required this.name,
    this.phone,
    required this.milkType,
    required this.defaultQtyMl,
    this.deliveryTime,
    this.notes,
    required this.openingBalancePaise,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['milk_type'] = Variable<String>(milkType);
    map['default_qty_ml'] = Variable<int>(defaultQtyMl);
    if (!nullToAbsent || deliveryTime != null) {
      map['delivery_time'] = Variable<String>(deliveryTime);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['opening_balance_paise'] = Variable<int>(openingBalancePaise);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VendorsCompanion toCompanion(bool nullToAbsent) {
    return VendorsCompanion(
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      milkType: Value(milkType),
      defaultQtyMl: Value(defaultQtyMl),
      deliveryTime: deliveryTime == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryTime),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      openingBalancePaise: Value(openingBalancePaise),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Vendor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vendor(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      milkType: serializer.fromJson<String>(json['milkType']),
      defaultQtyMl: serializer.fromJson<int>(json['defaultQtyMl']),
      deliveryTime: serializer.fromJson<String?>(json['deliveryTime']),
      notes: serializer.fromJson<String?>(json['notes']),
      openingBalancePaise: serializer.fromJson<int>(
        json['openingBalancePaise'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'milkType': serializer.toJson<String>(milkType),
      'defaultQtyMl': serializer.toJson<int>(defaultQtyMl),
      'deliveryTime': serializer.toJson<String?>(deliveryTime),
      'notes': serializer.toJson<String?>(notes),
      'openingBalancePaise': serializer.toJson<int>(openingBalancePaise),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vendor copyWith({
    int? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    String? milkType,
    int? defaultQtyMl,
    Value<String?> deliveryTime = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? openingBalancePaise,
    bool? isActive,
    DateTime? createdAt,
  }) => Vendor(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    milkType: milkType ?? this.milkType,
    defaultQtyMl: defaultQtyMl ?? this.defaultQtyMl,
    deliveryTime: deliveryTime.present ? deliveryTime.value : this.deliveryTime,
    notes: notes.present ? notes.value : this.notes,
    openingBalancePaise: openingBalancePaise ?? this.openingBalancePaise,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Vendor copyWithCompanion(VendorsCompanion data) {
    return Vendor(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      milkType: data.milkType.present ? data.milkType.value : this.milkType,
      defaultQtyMl: data.defaultQtyMl.present
          ? data.defaultQtyMl.value
          : this.defaultQtyMl,
      deliveryTime: data.deliveryTime.present
          ? data.deliveryTime.value
          : this.deliveryTime,
      notes: data.notes.present ? data.notes.value : this.notes,
      openingBalancePaise: data.openingBalancePaise.present
          ? data.openingBalancePaise.value
          : this.openingBalancePaise,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vendor(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('milkType: $milkType, ')
          ..write('defaultQtyMl: $defaultQtyMl, ')
          ..write('deliveryTime: $deliveryTime, ')
          ..write('notes: $notes, ')
          ..write('openingBalancePaise: $openingBalancePaise, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phone,
    milkType,
    defaultQtyMl,
    deliveryTime,
    notes,
    openingBalancePaise,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vendor &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.milkType == this.milkType &&
          other.defaultQtyMl == this.defaultQtyMl &&
          other.deliveryTime == this.deliveryTime &&
          other.notes == this.notes &&
          other.openingBalancePaise == this.openingBalancePaise &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class VendorsCompanion extends UpdateCompanion<Vendor> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String> milkType;
  final Value<int> defaultQtyMl;
  final Value<String?> deliveryTime;
  final Value<String?> notes;
  final Value<int> openingBalancePaise;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const VendorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.milkType = const Value.absent(),
    this.defaultQtyMl = const Value.absent(),
    this.deliveryTime = const Value.absent(),
    this.notes = const Value.absent(),
    this.openingBalancePaise = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VendorsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    required String milkType,
    required int defaultQtyMl,
    this.deliveryTime = const Value.absent(),
    this.notes = const Value.absent(),
    this.openingBalancePaise = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       milkType = Value(milkType),
       defaultQtyMl = Value(defaultQtyMl);
  static Insertable<Vendor> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? milkType,
    Expression<int>? defaultQtyMl,
    Expression<String>? deliveryTime,
    Expression<String>? notes,
    Expression<int>? openingBalancePaise,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (milkType != null) 'milk_type': milkType,
      if (defaultQtyMl != null) 'default_qty_ml': defaultQtyMl,
      if (deliveryTime != null) 'delivery_time': deliveryTime,
      if (notes != null) 'notes': notes,
      if (openingBalancePaise != null)
        'opening_balance_paise': openingBalancePaise,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VendorsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String>? milkType,
    Value<int>? defaultQtyMl,
    Value<String?>? deliveryTime,
    Value<String?>? notes,
    Value<int>? openingBalancePaise,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return VendorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      milkType: milkType ?? this.milkType,
      defaultQtyMl: defaultQtyMl ?? this.defaultQtyMl,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      notes: notes ?? this.notes,
      openingBalancePaise: openingBalancePaise ?? this.openingBalancePaise,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
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
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (milkType.present) {
      map['milk_type'] = Variable<String>(milkType.value);
    }
    if (defaultQtyMl.present) {
      map['default_qty_ml'] = Variable<int>(defaultQtyMl.value);
    }
    if (deliveryTime.present) {
      map['delivery_time'] = Variable<String>(deliveryTime.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (openingBalancePaise.present) {
      map['opening_balance_paise'] = Variable<int>(openingBalancePaise.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VendorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('milkType: $milkType, ')
          ..write('defaultQtyMl: $defaultQtyMl, ')
          ..write('deliveryTime: $deliveryTime, ')
          ..write('notes: $notes, ')
          ..write('openingBalancePaise: $openingBalancePaise, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RateHistoriesTable extends RateHistories
    with TableInfo<$RateHistoriesTable, RateHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RateHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _vendorIdMeta = const VerificationMeta(
    'vendorId',
  );
  @override
  late final GeneratedColumn<int> vendorId = GeneratedColumn<int>(
    'vendor_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vendors (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ratePerLitrePaiseMeta = const VerificationMeta(
    'ratePerLitrePaise',
  );
  @override
  late final GeneratedColumn<int> ratePerLitrePaise = GeneratedColumn<int>(
    'rate_per_litre_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveFrom =
      GeneratedColumn<DateTime>(
        'effective_from',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vendorId,
    ratePerLitrePaise,
    effectiveFrom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rate_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<RateHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vendor_id')) {
      context.handle(
        _vendorIdMeta,
        vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vendorIdMeta);
    }
    if (data.containsKey('rate_per_litre_paise')) {
      context.handle(
        _ratePerLitrePaiseMeta,
        ratePerLitrePaise.isAcceptableOrUnknown(
          data['rate_per_litre_paise']!,
          _ratePerLitrePaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ratePerLitrePaiseMeta);
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RateHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RateHistory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vendorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vendor_id'],
      )!,
      ratePerLitrePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_per_litre_paise'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_from'],
      )!,
    );
  }

  @override
  $RateHistoriesTable createAlias(String alias) {
    return $RateHistoriesTable(attachedDatabase, alias);
  }
}

class RateHistory extends DataClass implements Insertable<RateHistory> {
  final int id;
  final int vendorId;
  final int ratePerLitrePaise;
  final DateTime effectiveFrom;
  const RateHistory({
    required this.id,
    required this.vendorId,
    required this.ratePerLitrePaise,
    required this.effectiveFrom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vendor_id'] = Variable<int>(vendorId);
    map['rate_per_litre_paise'] = Variable<int>(ratePerLitrePaise);
    map['effective_from'] = Variable<DateTime>(effectiveFrom);
    return map;
  }

  RateHistoriesCompanion toCompanion(bool nullToAbsent) {
    return RateHistoriesCompanion(
      id: Value(id),
      vendorId: Value(vendorId),
      ratePerLitrePaise: Value(ratePerLitrePaise),
      effectiveFrom: Value(effectiveFrom),
    );
  }

  factory RateHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RateHistory(
      id: serializer.fromJson<int>(json['id']),
      vendorId: serializer.fromJson<int>(json['vendorId']),
      ratePerLitrePaise: serializer.fromJson<int>(json['ratePerLitrePaise']),
      effectiveFrom: serializer.fromJson<DateTime>(json['effectiveFrom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vendorId': serializer.toJson<int>(vendorId),
      'ratePerLitrePaise': serializer.toJson<int>(ratePerLitrePaise),
      'effectiveFrom': serializer.toJson<DateTime>(effectiveFrom),
    };
  }

  RateHistory copyWith({
    int? id,
    int? vendorId,
    int? ratePerLitrePaise,
    DateTime? effectiveFrom,
  }) => RateHistory(
    id: id ?? this.id,
    vendorId: vendorId ?? this.vendorId,
    ratePerLitrePaise: ratePerLitrePaise ?? this.ratePerLitrePaise,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
  );
  RateHistory copyWithCompanion(RateHistoriesCompanion data) {
    return RateHistory(
      id: data.id.present ? data.id.value : this.id,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      ratePerLitrePaise: data.ratePerLitrePaise.present
          ? data.ratePerLitrePaise.value
          : this.ratePerLitrePaise,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RateHistory(')
          ..write('id: $id, ')
          ..write('vendorId: $vendorId, ')
          ..write('ratePerLitrePaise: $ratePerLitrePaise, ')
          ..write('effectiveFrom: $effectiveFrom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vendorId, ratePerLitrePaise, effectiveFrom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RateHistory &&
          other.id == this.id &&
          other.vendorId == this.vendorId &&
          other.ratePerLitrePaise == this.ratePerLitrePaise &&
          other.effectiveFrom == this.effectiveFrom);
}

class RateHistoriesCompanion extends UpdateCompanion<RateHistory> {
  final Value<int> id;
  final Value<int> vendorId;
  final Value<int> ratePerLitrePaise;
  final Value<DateTime> effectiveFrom;
  const RateHistoriesCompanion({
    this.id = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.ratePerLitrePaise = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
  });
  RateHistoriesCompanion.insert({
    this.id = const Value.absent(),
    required int vendorId,
    required int ratePerLitrePaise,
    required DateTime effectiveFrom,
  }) : vendorId = Value(vendorId),
       ratePerLitrePaise = Value(ratePerLitrePaise),
       effectiveFrom = Value(effectiveFrom);
  static Insertable<RateHistory> custom({
    Expression<int>? id,
    Expression<int>? vendorId,
    Expression<int>? ratePerLitrePaise,
    Expression<DateTime>? effectiveFrom,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vendorId != null) 'vendor_id': vendorId,
      if (ratePerLitrePaise != null) 'rate_per_litre_paise': ratePerLitrePaise,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
    });
  }

  RateHistoriesCompanion copyWith({
    Value<int>? id,
    Value<int>? vendorId,
    Value<int>? ratePerLitrePaise,
    Value<DateTime>? effectiveFrom,
  }) {
    return RateHistoriesCompanion(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      ratePerLitrePaise: ratePerLitrePaise ?? this.ratePerLitrePaise,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vendorId.present) {
      map['vendor_id'] = Variable<int>(vendorId.value);
    }
    if (ratePerLitrePaise.present) {
      map['rate_per_litre_paise'] = Variable<int>(ratePerLitrePaise.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<DateTime>(effectiveFrom.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RateHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('vendorId: $vendorId, ')
          ..write('ratePerLitrePaise: $ratePerLitrePaise, ')
          ..write('effectiveFrom: $effectiveFrom')
          ..write(')'))
        .toString();
  }
}

class $DailyEntriesTable extends DailyEntries
    with TableInfo<$DailyEntriesTable, DailyEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _vendorIdMeta = const VerificationMeta(
    'vendorId',
  );
  @override
  late final GeneratedColumn<int> vendorId = GeneratedColumn<int>(
    'vendor_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vendors (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMlMeta = const VerificationMeta(
    'quantityMl',
  );
  @override
  late final GeneratedColumn<int> quantityMl = GeneratedColumn<int>(
    'quantity_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateUsedPaiseMeta = const VerificationMeta(
    'rateUsedPaise',
  );
  @override
  late final GeneratedColumn<int> rateUsedPaise = GeneratedColumn<int>(
    'rate_used_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DailyEntryStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DailyEntryStatus>($DailyEntriesTable.$converterstatus);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vendorId,
    date,
    quantityMl,
    rateUsedPaise,
    status,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vendor_id')) {
      context.handle(
        _vendorIdMeta,
        vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vendorIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('quantity_ml')) {
      context.handle(
        _quantityMlMeta,
        quantityMl.isAcceptableOrUnknown(data['quantity_ml']!, _quantityMlMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMlMeta);
    }
    if (data.containsKey('rate_used_paise')) {
      context.handle(
        _rateUsedPaiseMeta,
        rateUsedPaise.isAcceptableOrUnknown(
          data['rate_used_paise']!,
          _rateUsedPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rateUsedPaiseMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vendorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vendor_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      quantityMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_ml'],
      )!,
      rateUsedPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_used_paise'],
      )!,
      status: $DailyEntriesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $DailyEntriesTable createAlias(String alias) {
    return $DailyEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DailyEntryStatus, String, String> $converterstatus =
      const EnumNameConverter<DailyEntryStatus>(DailyEntryStatus.values);
}

class DailyEntry extends DataClass implements Insertable<DailyEntry> {
  final int id;
  final int vendorId;
  final DateTime date;
  final int quantityMl;
  final int rateUsedPaise;
  final DailyEntryStatus status;
  final String? note;
  const DailyEntry({
    required this.id,
    required this.vendorId,
    required this.date,
    required this.quantityMl,
    required this.rateUsedPaise,
    required this.status,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vendor_id'] = Variable<int>(vendorId);
    map['date'] = Variable<DateTime>(date);
    map['quantity_ml'] = Variable<int>(quantityMl);
    map['rate_used_paise'] = Variable<int>(rateUsedPaise);
    {
      map['status'] = Variable<String>(
        $DailyEntriesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  DailyEntriesCompanion toCompanion(bool nullToAbsent) {
    return DailyEntriesCompanion(
      id: Value(id),
      vendorId: Value(vendorId),
      date: Value(date),
      quantityMl: Value(quantityMl),
      rateUsedPaise: Value(rateUsedPaise),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory DailyEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyEntry(
      id: serializer.fromJson<int>(json['id']),
      vendorId: serializer.fromJson<int>(json['vendorId']),
      date: serializer.fromJson<DateTime>(json['date']),
      quantityMl: serializer.fromJson<int>(json['quantityMl']),
      rateUsedPaise: serializer.fromJson<int>(json['rateUsedPaise']),
      status: $DailyEntriesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vendorId': serializer.toJson<int>(vendorId),
      'date': serializer.toJson<DateTime>(date),
      'quantityMl': serializer.toJson<int>(quantityMl),
      'rateUsedPaise': serializer.toJson<int>(rateUsedPaise),
      'status': serializer.toJson<String>(
        $DailyEntriesTable.$converterstatus.toJson(status),
      ),
      'note': serializer.toJson<String?>(note),
    };
  }

  DailyEntry copyWith({
    int? id,
    int? vendorId,
    DateTime? date,
    int? quantityMl,
    int? rateUsedPaise,
    DailyEntryStatus? status,
    Value<String?> note = const Value.absent(),
  }) => DailyEntry(
    id: id ?? this.id,
    vendorId: vendorId ?? this.vendorId,
    date: date ?? this.date,
    quantityMl: quantityMl ?? this.quantityMl,
    rateUsedPaise: rateUsedPaise ?? this.rateUsedPaise,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
  );
  DailyEntry copyWithCompanion(DailyEntriesCompanion data) {
    return DailyEntry(
      id: data.id.present ? data.id.value : this.id,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      date: data.date.present ? data.date.value : this.date,
      quantityMl: data.quantityMl.present
          ? data.quantityMl.value
          : this.quantityMl,
      rateUsedPaise: data.rateUsedPaise.present
          ? data.rateUsedPaise.value
          : this.rateUsedPaise,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyEntry(')
          ..write('id: $id, ')
          ..write('vendorId: $vendorId, ')
          ..write('date: $date, ')
          ..write('quantityMl: $quantityMl, ')
          ..write('rateUsedPaise: $rateUsedPaise, ')
          ..write('status: $status, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vendorId, date, quantityMl, rateUsedPaise, status, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyEntry &&
          other.id == this.id &&
          other.vendorId == this.vendorId &&
          other.date == this.date &&
          other.quantityMl == this.quantityMl &&
          other.rateUsedPaise == this.rateUsedPaise &&
          other.status == this.status &&
          other.note == this.note);
}

class DailyEntriesCompanion extends UpdateCompanion<DailyEntry> {
  final Value<int> id;
  final Value<int> vendorId;
  final Value<DateTime> date;
  final Value<int> quantityMl;
  final Value<int> rateUsedPaise;
  final Value<DailyEntryStatus> status;
  final Value<String?> note;
  const DailyEntriesCompanion({
    this.id = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.date = const Value.absent(),
    this.quantityMl = const Value.absent(),
    this.rateUsedPaise = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
  });
  DailyEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int vendorId,
    required DateTime date,
    required int quantityMl,
    required int rateUsedPaise,
    required DailyEntryStatus status,
    this.note = const Value.absent(),
  }) : vendorId = Value(vendorId),
       date = Value(date),
       quantityMl = Value(quantityMl),
       rateUsedPaise = Value(rateUsedPaise),
       status = Value(status);
  static Insertable<DailyEntry> custom({
    Expression<int>? id,
    Expression<int>? vendorId,
    Expression<DateTime>? date,
    Expression<int>? quantityMl,
    Expression<int>? rateUsedPaise,
    Expression<String>? status,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vendorId != null) 'vendor_id': vendorId,
      if (date != null) 'date': date,
      if (quantityMl != null) 'quantity_ml': quantityMl,
      if (rateUsedPaise != null) 'rate_used_paise': rateUsedPaise,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
    });
  }

  DailyEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? vendorId,
    Value<DateTime>? date,
    Value<int>? quantityMl,
    Value<int>? rateUsedPaise,
    Value<DailyEntryStatus>? status,
    Value<String?>? note,
  }) {
    return DailyEntriesCompanion(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      date: date ?? this.date,
      quantityMl: quantityMl ?? this.quantityMl,
      rateUsedPaise: rateUsedPaise ?? this.rateUsedPaise,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vendorId.present) {
      map['vendor_id'] = Variable<int>(vendorId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (quantityMl.present) {
      map['quantity_ml'] = Variable<int>(quantityMl.value);
    }
    if (rateUsedPaise.present) {
      map['rate_used_paise'] = Variable<int>(rateUsedPaise.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $DailyEntriesTable.$converterstatus.toSql(status.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyEntriesCompanion(')
          ..write('id: $id, ')
          ..write('vendorId: $vendorId, ')
          ..write('date: $date, ')
          ..write('quantityMl: $quantityMl, ')
          ..write('rateUsedPaise: $rateUsedPaise, ')
          ..write('status: $status, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _vendorIdMeta = const VerificationMeta(
    'vendorId',
  );
  @override
  late final GeneratedColumn<int> vendorId = GeneratedColumn<int>(
    'vendor_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vendors (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMode, String> mode =
      GeneratedColumn<String>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PaymentMode>($PaymentsTable.$convertermode);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vendorId,
    date,
    amountPaise,
    mode,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vendor_id')) {
      context.handle(
        _vendorIdMeta,
        vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vendorIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vendorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vendor_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      mode: $PaymentsTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mode'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMode, String, String> $convertermode =
      const EnumNameConverter<PaymentMode>(PaymentMode.values);
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final int vendorId;
  final DateTime date;
  final int amountPaise;
  final PaymentMode mode;
  final String? note;
  const Payment({
    required this.id,
    required this.vendorId,
    required this.date,
    required this.amountPaise,
    required this.mode,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vendor_id'] = Variable<int>(vendorId);
    map['date'] = Variable<DateTime>(date);
    map['amount_paise'] = Variable<int>(amountPaise);
    {
      map['mode'] = Variable<String>($PaymentsTable.$convertermode.toSql(mode));
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      vendorId: Value(vendorId),
      date: Value(date),
      amountPaise: Value(amountPaise),
      mode: Value(mode),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      vendorId: serializer.fromJson<int>(json['vendorId']),
      date: serializer.fromJson<DateTime>(json['date']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      mode: $PaymentsTable.$convertermode.fromJson(
        serializer.fromJson<String>(json['mode']),
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vendorId': serializer.toJson<int>(vendorId),
      'date': serializer.toJson<DateTime>(date),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'mode': serializer.toJson<String>(
        $PaymentsTable.$convertermode.toJson(mode),
      ),
      'note': serializer.toJson<String?>(note),
    };
  }

  Payment copyWith({
    int? id,
    int? vendorId,
    DateTime? date,
    int? amountPaise,
    PaymentMode? mode,
    Value<String?> note = const Value.absent(),
  }) => Payment(
    id: id ?? this.id,
    vendorId: vendorId ?? this.vendorId,
    date: date ?? this.date,
    amountPaise: amountPaise ?? this.amountPaise,
    mode: mode ?? this.mode,
    note: note.present ? note.value : this.note,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      date: data.date.present ? data.date.value : this.date,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      mode: data.mode.present ? data.mode.value : this.mode,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('vendorId: $vendorId, ')
          ..write('date: $date, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('mode: $mode, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vendorId, date, amountPaise, mode, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.vendorId == this.vendorId &&
          other.date == this.date &&
          other.amountPaise == this.amountPaise &&
          other.mode == this.mode &&
          other.note == this.note);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<int> vendorId;
  final Value<DateTime> date;
  final Value<int> amountPaise;
  final Value<PaymentMode> mode;
  final Value<String?> note;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.date = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.mode = const Value.absent(),
    this.note = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int vendorId,
    required DateTime date,
    required int amountPaise,
    required PaymentMode mode,
    this.note = const Value.absent(),
  }) : vendorId = Value(vendorId),
       date = Value(date),
       amountPaise = Value(amountPaise),
       mode = Value(mode);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<int>? vendorId,
    Expression<DateTime>? date,
    Expression<int>? amountPaise,
    Expression<String>? mode,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vendorId != null) 'vendor_id': vendorId,
      if (date != null) 'date': date,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (mode != null) 'mode': mode,
      if (note != null) 'note': note,
    });
  }

  PaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? vendorId,
    Value<DateTime>? date,
    Value<int>? amountPaise,
    Value<PaymentMode>? mode,
    Value<String?>? note,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      date: date ?? this.date,
      amountPaise: amountPaise ?? this.amountPaise,
      mode: mode ?? this.mode,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vendorId.present) {
      map['vendor_id'] = Variable<int>(vendorId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(
        $PaymentsTable.$convertermode.toSql(mode.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('vendorId: $vendorId, ')
          ..write('date: $date, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('mode: $mode, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

abstract class _$MilkDatabase extends GeneratedDatabase {
  _$MilkDatabase(QueryExecutor e) : super(e);
  $MilkDatabaseManager get managers => $MilkDatabaseManager(this);
  late final $VendorsTable vendors = $VendorsTable(this);
  late final $RateHistoriesTable rateHistories = $RateHistoriesTable(this);
  late final $DailyEntriesTable dailyEntries = $DailyEntriesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final Index rateHistoriesVendorEffectiveFrom = Index(
    'rate_histories_vendor_effective_from',
    'CREATE UNIQUE INDEX rate_histories_vendor_effective_from ON rate_histories (vendor_id, effective_from)',
  );
  late final Index dailyEntriesVendorDate = Index(
    'daily_entries_vendor_date',
    'CREATE UNIQUE INDEX daily_entries_vendor_date ON daily_entries (vendor_id, date)',
  );
  late final LedgerDao ledgerDao = LedgerDao(this as MilkDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vendors,
    rateHistories,
    dailyEntries,
    payments,
    rateHistoriesVendorEffectiveFrom,
    dailyEntriesVendorDate,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vendors',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rate_histories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vendors',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('daily_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vendors',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$VendorsTableCreateCompanionBuilder = VendorsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> phone,
  required String milkType,
  required int defaultQtyMl,
  Value<String?> deliveryTime,
  Value<String?> notes,
  Value<int> openingBalancePaise,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});
typedef $$VendorsTableUpdateCompanionBuilder = VendorsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> phone,
  Value<String> milkType,
  Value<int> defaultQtyMl,
  Value<String?> deliveryTime,
  Value<String?> notes,
  Value<int> openingBalancePaise,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});

final class $$VendorsTableReferences
    extends BaseReferences<_$MilkDatabase, $VendorsTable, Vendor> {
  $$VendorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RateHistoriesTable, List<RateHistory>>
  _rateHistoriesRefsTable(_$MilkDatabase db) => MultiTypedResultKey.fromTable(
    db.rateHistories,
    aliasName: 'vendors__id__rate_histories__vendor_id',
  );

  $$RateHistoriesTableProcessedTableManager get rateHistoriesRefs {
    final manager = $$RateHistoriesTableTableManager(
      $_db,
      $_db.rateHistories,
    ).filter((f) => f.vendorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rateHistoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DailyEntriesTable, List<DailyEntry>>
  _dailyEntriesRefsTable(_$MilkDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyEntries,
    aliasName: 'vendors__id__daily_entries__vendor_id',
  );

  $$DailyEntriesTableProcessedTableManager get dailyEntriesRefs {
    final manager = $$DailyEntriesTableTableManager(
      $_db,
      $_db.dailyEntries,
    ).filter((f) => f.vendorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dailyEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$MilkDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'vendors__id__payments__vendor_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.vendorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VendorsTableFilterComposer
    extends Composer<_$MilkDatabase, $VendorsTable> {
  $$VendorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get milkType => $composableBuilder(
    column: $table.milkType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultQtyMl => $composableBuilder(
    column: $table.defaultQtyMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryTime => $composableBuilder(
    column: $table.deliveryTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalancePaise => $composableBuilder(
    column: $table.openingBalancePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> rateHistoriesRefs(
    Expression<bool> Function($$RateHistoriesTableFilterComposer f) f,
  ) {
    final $$RateHistoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rateHistories,
      getReferencedColumn: (t) => t.vendorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RateHistoriesTableFilterComposer(
            $db: $db,
            $table: $db.rateHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailyEntriesRefs(
    Expression<bool> Function($$DailyEntriesTableFilterComposer f) f,
  ) {
    final $$DailyEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyEntries,
      getReferencedColumn: (t) => t.vendorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyEntriesTableFilterComposer(
            $db: $db,
            $table: $db.dailyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.vendorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VendorsTableOrderingComposer
    extends Composer<_$MilkDatabase, $VendorsTable> {
  $$VendorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get milkType => $composableBuilder(
    column: $table.milkType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultQtyMl => $composableBuilder(
    column: $table.defaultQtyMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryTime => $composableBuilder(
    column: $table.deliveryTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalancePaise => $composableBuilder(
    column: $table.openingBalancePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VendorsTableAnnotationComposer
    extends Composer<_$MilkDatabase, $VendorsTable> {
  $$VendorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get milkType =>
      $composableBuilder(column: $table.milkType, builder: (column) => column);

  GeneratedColumn<int> get defaultQtyMl => $composableBuilder(
    column: $table.defaultQtyMl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryTime => $composableBuilder(
    column: $table.deliveryTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get openingBalancePaise => $composableBuilder(
    column: $table.openingBalancePaise,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> rateHistoriesRefs<T extends Object>(
    Expression<T> Function($$RateHistoriesTableAnnotationComposer a) f,
  ) {
    final $$RateHistoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rateHistories,
      getReferencedColumn: (t) => t.vendorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RateHistoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.rateHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dailyEntriesRefs<T extends Object>(
    Expression<T> Function($$DailyEntriesTableAnnotationComposer a) f,
  ) {
    final $$DailyEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyEntries,
      getReferencedColumn: (t) => t.vendorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.vendorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VendorsTableTableManager
    extends
        RootTableManager<
          _$MilkDatabase,
          $VendorsTable,
          Vendor,
          $$VendorsTableFilterComposer,
          $$VendorsTableOrderingComposer,
          $$VendorsTableAnnotationComposer,
          $$VendorsTableCreateCompanionBuilder,
          $$VendorsTableUpdateCompanionBuilder,
          (Vendor, $$VendorsTableReferences),
          Vendor,
          PrefetchHooks Function({
            bool rateHistoriesRefs,
            bool dailyEntriesRefs,
            bool paymentsRefs,
          })
        > {
  $$VendorsTableTableManager(_$MilkDatabase db, $VendorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VendorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VendorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VendorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> milkType = const Value.absent(),
                Value<int> defaultQtyMl = const Value.absent(),
                Value<String?> deliveryTime = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> openingBalancePaise = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VendorsCompanion(
                id: id,
                name: name,
                phone: phone,
                milkType: milkType,
                defaultQtyMl: defaultQtyMl,
                deliveryTime: deliveryTime,
                notes: notes,
                openingBalancePaise: openingBalancePaise,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> phone = const Value.absent(),
                required String milkType,
                required int defaultQtyMl,
                Value<String?> deliveryTime = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> openingBalancePaise = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VendorsCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                milkType: milkType,
                defaultQtyMl: defaultQtyMl,
                deliveryTime: deliveryTime,
                notes: notes,
                openingBalancePaise: openingBalancePaise,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VendorsTable, Vendor>(table),
                  $$VendorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                rateHistoriesRefs = false,
                dailyEntriesRefs = false,
                paymentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (rateHistoriesRefs) db.rateHistories,
                    if (dailyEntriesRefs) db.dailyEntries,
                    if (paymentsRefs) db.payments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (rateHistoriesRefs)
                        await $_getPrefetchedDataByColumns<
                          Vendor,
                          $VendorsTable,
                          RateHistory,
                          $RateHistoriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$VendorsTableReferences
                              ._rateHistoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VendorsTableReferences(
                                db,
                                table,
                                p0,
                              ).rateHistoriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'vendor_id',
                          typedResults: items,
                        ),
                      if (dailyEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          Vendor,
                          $VendorsTable,
                          DailyEntry,
                          $DailyEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$VendorsTableReferences
                              ._dailyEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VendorsTableReferences(
                                db,
                                table,
                                p0,
                              ).dailyEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'vendor_id',
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Vendor,
                          $VendorsTable,
                          Payment,
                          $PaymentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$VendorsTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VendorsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'vendor_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VendorsTableProcessedTableManager =
    ProcessedTableManager<
      _$MilkDatabase,
      $VendorsTable,
      Vendor,
      $$VendorsTableFilterComposer,
      $$VendorsTableOrderingComposer,
      $$VendorsTableAnnotationComposer,
      $$VendorsTableCreateCompanionBuilder,
      $$VendorsTableUpdateCompanionBuilder,
      (Vendor, $$VendorsTableReferences),
      Vendor,
      PrefetchHooks Function({
        bool rateHistoriesRefs,
        bool dailyEntriesRefs,
        bool paymentsRefs,
      })
    >;
typedef $$RateHistoriesTableCreateCompanionBuilder =
    RateHistoriesCompanion Function({
      Value<int> id,
      required int vendorId,
      required int ratePerLitrePaise,
      required DateTime effectiveFrom,
    });
typedef $$RateHistoriesTableUpdateCompanionBuilder =
    RateHistoriesCompanion Function({
      Value<int> id,
      Value<int> vendorId,
      Value<int> ratePerLitrePaise,
      Value<DateTime> effectiveFrom,
    });

final class $$RateHistoriesTableReferences
    extends BaseReferences<_$MilkDatabase, $RateHistoriesTable, RateHistory> {
  $$RateHistoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VendorsTable _vendorIdTable(_$MilkDatabase db) =>
      db.vendors.createAlias('rate_histories__vendor_id__vendors__id');

  $$VendorsTableProcessedTableManager get vendorId {
    final $_column = $_itemColumn<int>('vendor_id')!;

    final manager = $$VendorsTableTableManager(
      $_db,
      $_db.vendors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vendorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RateHistoriesTableFilterComposer
    extends Composer<_$MilkDatabase, $RateHistoriesTable> {
  $$RateHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratePerLitrePaise => $composableBuilder(
    column: $table.ratePerLitrePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  $$VendorsTableFilterComposer get vendorId {
    final $$VendorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorId,
      referencedTable: $db.vendors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorsTableFilterComposer(
            $db: $db,
            $table: $db.vendors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RateHistoriesTableOrderingComposer
    extends Composer<_$MilkDatabase, $RateHistoriesTable> {
  $$RateHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratePerLitrePaise => $composableBuilder(
    column: $table.ratePerLitrePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  $$VendorsTableOrderingComposer get vendorId {
    final $$VendorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorId,
      referencedTable: $db.vendors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorsTableOrderingComposer(
            $db: $db,
            $table: $db.vendors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RateHistoriesTableAnnotationComposer
    extends Composer<_$MilkDatabase, $RateHistoriesTable> {
  $$RateHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ratePerLitrePaise => $composableBuilder(
    column: $table.ratePerLitrePaise,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  $$VendorsTableAnnotationComposer get vendorId {
    final $$VendorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorId,
      referencedTable: $db.vendors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorsTableAnnotationComposer(
            $db: $db,
            $table: $db.vendors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RateHistoriesTableTableManager
    extends
        RootTableManager<
          _$MilkDatabase,
          $RateHistoriesTable,
          RateHistory,
          $$RateHistoriesTableFilterComposer,
          $$RateHistoriesTableOrderingComposer,
          $$RateHistoriesTableAnnotationComposer,
          $$RateHistoriesTableCreateCompanionBuilder,
          $$RateHistoriesTableUpdateCompanionBuilder,
          (RateHistory, $$RateHistoriesTableReferences),
          RateHistory,
          PrefetchHooks Function({bool vendorId})
        > {
  $$RateHistoriesTableTableManager(_$MilkDatabase db, $RateHistoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RateHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RateHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RateHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vendorId = const Value.absent(),
                Value<int> ratePerLitrePaise = const Value.absent(),
                Value<DateTime> effectiveFrom = const Value.absent(),
              }) => RateHistoriesCompanion(
                id: id,
                vendorId: vendorId,
                ratePerLitrePaise: ratePerLitrePaise,
                effectiveFrom: effectiveFrom,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vendorId,
                required int ratePerLitrePaise,
                required DateTime effectiveFrom,
              }) => RateHistoriesCompanion.insert(
                id: id,
                vendorId: vendorId,
                ratePerLitrePaise: ratePerLitrePaise,
                effectiveFrom: effectiveFrom,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RateHistoriesTable, RateHistory>(table),
                  $$RateHistoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vendorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vendorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vendorId,
                        referencedTable: $$RateHistoriesTableReferences
                            ._vendorIdTable(db),
                        referencedColumn: $$RateHistoriesTableReferences
                            ._vendorIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RateHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$MilkDatabase,
      $RateHistoriesTable,
      RateHistory,
      $$RateHistoriesTableFilterComposer,
      $$RateHistoriesTableOrderingComposer,
      $$RateHistoriesTableAnnotationComposer,
      $$RateHistoriesTableCreateCompanionBuilder,
      $$RateHistoriesTableUpdateCompanionBuilder,
      (RateHistory, $$RateHistoriesTableReferences),
      RateHistory,
      PrefetchHooks Function({bool vendorId})
    >;
typedef $$DailyEntriesTableCreateCompanionBuilder =
    DailyEntriesCompanion Function({
      Value<int> id,
      required int vendorId,
      required DateTime date,
      required int quantityMl,
      required int rateUsedPaise,
      required DailyEntryStatus status,
      Value<String?> note,
    });
typedef $$DailyEntriesTableUpdateCompanionBuilder =
    DailyEntriesCompanion Function({
      Value<int> id,
      Value<int> vendorId,
      Value<DateTime> date,
      Value<int> quantityMl,
      Value<int> rateUsedPaise,
      Value<DailyEntryStatus> status,
      Value<String?> note,
    });

final class $$DailyEntriesTableReferences
    extends BaseReferences<_$MilkDatabase, $DailyEntriesTable, DailyEntry> {
  $$DailyEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VendorsTable _vendorIdTable(_$MilkDatabase db) =>
      db.vendors.createAlias('daily_entries__vendor_id__vendors__id');

  $$VendorsTableProcessedTableManager get vendorId {
    final $_column = $_itemColumn<int>('vendor_id')!;

    final manager = $$VendorsTableTableManager(
      $_db,
      $_db.vendors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vendorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DailyEntriesTableFilterComposer
    extends Composer<_$MilkDatabase, $DailyEntriesTable> {
  $$DailyEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityMl => $composableBuilder(
    column: $table.quantityMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rateUsedPaise => $composableBuilder(
    column: $table.rateUsedPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DailyEntryStatus, DailyEntryStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$VendorsTableFilterComposer get vendorId {
    final $$VendorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorId,
      referencedTable: $db.vendors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorsTableFilterComposer(
            $db: $db,
            $table: $db.vendors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyEntriesTableOrderingComposer
    extends Composer<_$MilkDatabase, $DailyEntriesTable> {
  $$DailyEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityMl => $composableBuilder(
    column: $table.quantityMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateUsedPaise => $composableBuilder(
    column: $table.rateUsedPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$VendorsTableOrderingComposer get vendorId {
    final $$VendorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorId,
      referencedTable: $db.vendors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorsTableOrderingComposer(
            $db: $db,
            $table: $db.vendors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyEntriesTableAnnotationComposer
    extends Composer<_$MilkDatabase, $DailyEntriesTable> {
  $$DailyEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get quantityMl => $composableBuilder(
    column: $table.quantityMl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rateUsedPaise => $composableBuilder(
    column: $table.rateUsedPaise,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DailyEntryStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$VendorsTableAnnotationComposer get vendorId {
    final $$VendorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorId,
      referencedTable: $db.vendors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorsTableAnnotationComposer(
            $db: $db,
            $table: $db.vendors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyEntriesTableTableManager
    extends
        RootTableManager<
          _$MilkDatabase,
          $DailyEntriesTable,
          DailyEntry,
          $$DailyEntriesTableFilterComposer,
          $$DailyEntriesTableOrderingComposer,
          $$DailyEntriesTableAnnotationComposer,
          $$DailyEntriesTableCreateCompanionBuilder,
          $$DailyEntriesTableUpdateCompanionBuilder,
          (DailyEntry, $$DailyEntriesTableReferences),
          DailyEntry,
          PrefetchHooks Function({bool vendorId})
        > {
  $$DailyEntriesTableTableManager(_$MilkDatabase db, $DailyEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vendorId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> quantityMl = const Value.absent(),
                Value<int> rateUsedPaise = const Value.absent(),
                Value<DailyEntryStatus> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => DailyEntriesCompanion(
                id: id,
                vendorId: vendorId,
                date: date,
                quantityMl: quantityMl,
                rateUsedPaise: rateUsedPaise,
                status: status,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vendorId,
                required DateTime date,
                required int quantityMl,
                required int rateUsedPaise,
                required DailyEntryStatus status,
                Value<String?> note = const Value.absent(),
              }) => DailyEntriesCompanion.insert(
                id: id,
                vendorId: vendorId,
                date: date,
                quantityMl: quantityMl,
                rateUsedPaise: rateUsedPaise,
                status: status,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyEntriesTable, DailyEntry>(table),
                  $$DailyEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vendorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vendorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vendorId,
                        referencedTable: $$DailyEntriesTableReferences
                            ._vendorIdTable(db),
                        referencedColumn: $$DailyEntriesTableReferences
                            ._vendorIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DailyEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$MilkDatabase,
      $DailyEntriesTable,
      DailyEntry,
      $$DailyEntriesTableFilterComposer,
      $$DailyEntriesTableOrderingComposer,
      $$DailyEntriesTableAnnotationComposer,
      $$DailyEntriesTableCreateCompanionBuilder,
      $$DailyEntriesTableUpdateCompanionBuilder,
      (DailyEntry, $$DailyEntriesTableReferences),
      DailyEntry,
      PrefetchHooks Function({bool vendorId})
    >;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  required int vendorId,
  required DateTime date,
  required int amountPaise,
  required PaymentMode mode,
  Value<String?> note,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  Value<int> vendorId,
  Value<DateTime> date,
  Value<int> amountPaise,
  Value<PaymentMode> mode,
  Value<String?> note,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$MilkDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VendorsTable _vendorIdTable(_$MilkDatabase db) =>
      db.vendors.createAlias('payments__vendor_id__vendors__id');

  $$VendorsTableProcessedTableManager get vendorId {
    final $_column = $_itemColumn<int>('vendor_id')!;

    final manager = $$VendorsTableTableManager(
      $_db,
      $_db.vendors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vendorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$MilkDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMode, PaymentMode, String> get mode =>
      $composableBuilder(
        column: $table.mode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$VendorsTableFilterComposer get vendorId {
    final $$VendorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorId,
      referencedTable: $db.vendors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorsTableFilterComposer(
            $db: $db,
            $table: $db.vendors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$MilkDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$VendorsTableOrderingComposer get vendorId {
    final $$VendorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorId,
      referencedTable: $db.vendors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorsTableOrderingComposer(
            $db: $db,
            $table: $db.vendors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$MilkDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PaymentMode, String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$VendorsTableAnnotationComposer get vendorId {
    final $$VendorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorId,
      referencedTable: $db.vendors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorsTableAnnotationComposer(
            $db: $db,
            $table: $db.vendors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$MilkDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableReferences),
          Payment,
          PrefetchHooks Function({bool vendorId})
        > {
  $$PaymentsTableTableManager(_$MilkDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vendorId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<PaymentMode> mode = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                vendorId: vendorId,
                date: date,
                amountPaise: amountPaise,
                mode: mode,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vendorId,
                required DateTime date,
                required int amountPaise,
                required PaymentMode mode,
                Value<String?> note = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                vendorId: vendorId,
                date: date,
                amountPaise: amountPaise,
                mode: mode,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentsTable, Payment>(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vendorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vendorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vendorId,
                        referencedTable: $$PaymentsTableReferences
                            ._vendorIdTable(db),
                        referencedColumn: $$PaymentsTableReferences
                            ._vendorIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$MilkDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableReferences),
      Payment,
      PrefetchHooks Function({bool vendorId})
    >;

class $MilkDatabaseManager {
  final _$MilkDatabase _db;
  $MilkDatabaseManager(this._db);
  $$VendorsTableTableManager get vendors =>
      $$VendorsTableTableManager(_db, _db.vendors);
  $$RateHistoriesTableTableManager get rateHistories =>
      $$RateHistoriesTableTableManager(_db, _db.rateHistories);
  $$DailyEntriesTableTableManager get dailyEntries =>
      $$DailyEntriesTableTableManager(_db, _db.dailyEntries);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
}
