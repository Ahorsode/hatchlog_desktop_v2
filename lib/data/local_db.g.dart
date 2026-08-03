// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstnameMeta = const VerificationMeta(
    'firstname',
  );
  @override
  late final GeneratedColumn<String> firstname = GeneratedColumn<String>(
    'firstname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _surnameMeta = const VerificationMeta(
    'surname',
  );
  @override
  late final GeneratedColumn<String> surname = GeneratedColumn<String>(
    'surname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _middleNameMeta = const VerificationMeta(
    'middleName',
  );
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
    'middle_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mustChangePasswordMeta =
      const VerificationMeta('mustChangePassword');
  @override
  late final GeneratedColumn<bool> mustChangePassword = GeneratedColumn<bool>(
    'must_change_password',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("must_change_password" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('OWNER'),
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
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firstname,
    surname,
    middleName,
    name,
    email,
    image,
    password,
    phoneNumber,
    mustChangePassword,
    role,
    createdAt,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('firstname')) {
      context.handle(
        _firstnameMeta,
        firstname.isAcceptableOrUnknown(data['firstname']!, _firstnameMeta),
      );
    }
    if (data.containsKey('surname')) {
      context.handle(
        _surnameMeta,
        surname.isAcceptableOrUnknown(data['surname']!, _surnameMeta),
      );
    }
    if (data.containsKey('middle_name')) {
      context.handle(
        _middleNameMeta,
        middleName.isAcceptableOrUnknown(data['middle_name']!, _middleNameMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('must_change_password')) {
      context.handle(
        _mustChangePasswordMeta,
        mustChangePassword.isAcceptableOrUnknown(
          data['must_change_password']!,
          _mustChangePasswordMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firstname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firstname'],
      ),
      surname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surname'],
      ),
      middleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}middle_name'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      ),
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      mustChangePassword: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}must_change_password'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String? firstname;
  final String? surname;
  final String? middleName;
  final String? name;
  final String? email;
  final String? image;
  final String? password;
  final String? phoneNumber;
  final bool mustChangePassword;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const User({
    required this.id,
    this.firstname,
    this.surname,
    this.middleName,
    this.name,
    this.email,
    this.image,
    this.password,
    this.phoneNumber,
    required this.mustChangePassword,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || firstname != null) {
      map['firstname'] = Variable<String>(firstname);
    }
    if (!nullToAbsent || surname != null) {
      map['surname'] = Variable<String>(surname);
    }
    if (!nullToAbsent || middleName != null) {
      map['middle_name'] = Variable<String>(middleName);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<String>(image);
    }
    if (!nullToAbsent || password != null) {
      map['password'] = Variable<String>(password);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    map['must_change_password'] = Variable<bool>(mustChangePassword);
    map['role'] = Variable<String>(role);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      firstname: firstname == null && nullToAbsent
          ? const Value.absent()
          : Value(firstname),
      surname: surname == null && nullToAbsent
          ? const Value.absent()
          : Value(surname),
      middleName: middleName == null && nullToAbsent
          ? const Value.absent()
          : Value(middleName),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      image: image == null && nullToAbsent
          ? const Value.absent()
          : Value(image),
      password: password == null && nullToAbsent
          ? const Value.absent()
          : Value(password),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      mustChangePassword: Value(mustChangePassword),
      role: Value(role),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      firstname: serializer.fromJson<String?>(json['firstname']),
      surname: serializer.fromJson<String?>(json['surname']),
      middleName: serializer.fromJson<String?>(json['middleName']),
      name: serializer.fromJson<String?>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      image: serializer.fromJson<String?>(json['image']),
      password: serializer.fromJson<String?>(json['password']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      mustChangePassword: serializer.fromJson<bool>(json['mustChangePassword']),
      role: serializer.fromJson<String>(json['role']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firstname': serializer.toJson<String?>(firstname),
      'surname': serializer.toJson<String?>(surname),
      'middleName': serializer.toJson<String?>(middleName),
      'name': serializer.toJson<String?>(name),
      'email': serializer.toJson<String?>(email),
      'image': serializer.toJson<String?>(image),
      'password': serializer.toJson<String?>(password),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'mustChangePassword': serializer.toJson<bool>(mustChangePassword),
      'role': serializer.toJson<String>(role),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  User copyWith({
    String? id,
    Value<String?> firstname = const Value.absent(),
    Value<String?> surname = const Value.absent(),
    Value<String?> middleName = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> image = const Value.absent(),
    Value<String?> password = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
    bool? mustChangePassword,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) => User(
    id: id ?? this.id,
    firstname: firstname.present ? firstname.value : this.firstname,
    surname: surname.present ? surname.value : this.surname,
    middleName: middleName.present ? middleName.value : this.middleName,
    name: name.present ? name.value : this.name,
    email: email.present ? email.value : this.email,
    image: image.present ? image.value : this.image,
    password: password.present ? password.value : this.password,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      firstname: data.firstname.present ? data.firstname.value : this.firstname,
      surname: data.surname.present ? data.surname.value : this.surname,
      middleName: data.middleName.present
          ? data.middleName.value
          : this.middleName,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      image: data.image.present ? data.image.value : this.image,
      password: data.password.present ? data.password.value : this.password,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      mustChangePassword: data.mustChangePassword.present
          ? data.mustChangePassword.value
          : this.mustChangePassword,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('firstname: $firstname, ')
          ..write('surname: $surname, ')
          ..write('middleName: $middleName, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('image: $image, ')
          ..write('password: $password, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('mustChangePassword: $mustChangePassword, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firstname,
    surname,
    middleName,
    name,
    email,
    image,
    password,
    phoneNumber,
    mustChangePassword,
    role,
    createdAt,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.firstname == this.firstname &&
          other.surname == this.surname &&
          other.middleName == this.middleName &&
          other.name == this.name &&
          other.email == this.email &&
          other.image == this.image &&
          other.password == this.password &&
          other.phoneNumber == this.phoneNumber &&
          other.mustChangePassword == this.mustChangePassword &&
          other.role == this.role &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String?> firstname;
  final Value<String?> surname;
  final Value<String?> middleName;
  final Value<String?> name;
  final Value<String?> email;
  final Value<String?> image;
  final Value<String?> password;
  final Value<String?> phoneNumber;
  final Value<bool> mustChangePassword;
  final Value<String> role;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.firstname = const Value.absent(),
    this.surname = const Value.absent(),
    this.middleName = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.image = const Value.absent(),
    this.password = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.mustChangePassword = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    this.firstname = const Value.absent(),
    this.surname = const Value.absent(),
    this.middleName = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.image = const Value.absent(),
    this.password = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.mustChangePassword = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? firstname,
    Expression<String>? surname,
    Expression<String>? middleName,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? image,
    Expression<String>? password,
    Expression<String>? phoneNumber,
    Expression<bool>? mustChangePassword,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstname != null) 'firstname': firstname,
      if (surname != null) 'surname': surname,
      if (middleName != null) 'middle_name': middleName,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (image != null) 'image': image,
      if (password != null) 'password': password,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (mustChangePassword != null)
        'must_change_password': mustChangePassword,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String?>? firstname,
    Value<String?>? surname,
    Value<String?>? middleName,
    Value<String?>? name,
    Value<String?>? email,
    Value<String?>? image,
    Value<String?>? password,
    Value<String?>? phoneNumber,
    Value<bool>? mustChangePassword,
    Value<String>? role,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      surname: surname ?? this.surname,
      middleName: middleName ?? this.middleName,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firstname.present) {
      map['firstname'] = Variable<String>(firstname.value);
    }
    if (surname.present) {
      map['surname'] = Variable<String>(surname.value);
    }
    if (middleName.present) {
      map['middle_name'] = Variable<String>(middleName.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (mustChangePassword.present) {
      map['must_change_password'] = Variable<bool>(mustChangePassword.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('firstname: $firstname, ')
          ..write('surname: $surname, ')
          ..write('middleName: $middleName, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('image: $image, ')
          ..write('password: $password, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('mustChangePassword: $mustChangePassword, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmsTable extends Farms with TableInfo<$FarmsTable, Farm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subscriptionTierMeta = const VerificationMeta(
    'subscriptionTier',
  );
  @override
  late final GeneratedColumn<String> subscriptionTier = GeneratedColumn<String>(
    'subscription_tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('FREE'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CLOUD_SYNCED'),
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
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    location,
    capacity,
    userId,
    subscriptionTier,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Farm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    } else if (isInserting) {
      context.missing(_capacityMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('subscription_tier')) {
      context.handle(
        _subscriptionTierMeta,
        subscriptionTier.isAcceptableOrUnknown(
          data['subscription_tier']!,
          _subscriptionTierMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Farm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Farm(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      subscriptionTier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscription_tier'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FarmsTable createAlias(String alias) {
    return $FarmsTable(attachedDatabase, alias);
  }
}

class Farm extends DataClass implements Insertable<Farm> {
  final String id;
  final String name;
  final String? location;
  final int capacity;
  final String userId;
  final String subscriptionTier;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Farm({
    required this.id,
    required this.name,
    this.location,
    required this.capacity,
    required this.userId,
    required this.subscriptionTier,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['capacity'] = Variable<int>(capacity);
    map['user_id'] = Variable<String>(userId);
    map['subscription_tier'] = Variable<String>(subscriptionTier);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FarmsCompanion toCompanion(bool nullToAbsent) {
    return FarmsCompanion(
      id: Value(id),
      name: Value(name),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      capacity: Value(capacity),
      userId: Value(userId),
      subscriptionTier: Value(subscriptionTier),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Farm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Farm(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String?>(json['location']),
      capacity: serializer.fromJson<int>(json['capacity']),
      userId: serializer.fromJson<String>(json['userId']),
      subscriptionTier: serializer.fromJson<String>(json['subscriptionTier']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String?>(location),
      'capacity': serializer.toJson<int>(capacity),
      'userId': serializer.toJson<String>(userId),
      'subscriptionTier': serializer.toJson<String>(subscriptionTier),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Farm copyWith({
    String? id,
    String? name,
    Value<String?> location = const Value.absent(),
    int? capacity,
    String? userId,
    String? subscriptionTier,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Farm(
    id: id ?? this.id,
    name: name ?? this.name,
    location: location.present ? location.value : this.location,
    capacity: capacity ?? this.capacity,
    userId: userId ?? this.userId,
    subscriptionTier: subscriptionTier ?? this.subscriptionTier,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Farm copyWithCompanion(FarmsCompanion data) {
    return Farm(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      userId: data.userId.present ? data.userId.value : this.userId,
      subscriptionTier: data.subscriptionTier.present
          ? data.subscriptionTier.value
          : this.subscriptionTier,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Farm(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('capacity: $capacity, ')
          ..write('userId: $userId, ')
          ..write('subscriptionTier: $subscriptionTier, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    location,
    capacity,
    userId,
    subscriptionTier,
    syncStatus,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Farm &&
          other.id == this.id &&
          other.name == this.name &&
          other.location == this.location &&
          other.capacity == this.capacity &&
          other.userId == this.userId &&
          other.subscriptionTier == this.subscriptionTier &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FarmsCompanion extends UpdateCompanion<Farm> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> location;
  final Value<int> capacity;
  final Value<String> userId;
  final Value<String> subscriptionTier;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FarmsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.capacity = const Value.absent(),
    this.userId = const Value.absent(),
    this.subscriptionTier = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmsCompanion.insert({
    required String id,
    required String name,
    this.location = const Value.absent(),
    required int capacity,
    required String userId,
    this.subscriptionTier = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       capacity = Value(capacity),
       userId = Value(userId);
  static Insertable<Farm> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? location,
    Expression<int>? capacity,
    Expression<String>? userId,
    Expression<String>? subscriptionTier,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (capacity != null) 'capacity': capacity,
      if (userId != null) 'user_id': userId,
      if (subscriptionTier != null) 'subscription_tier': subscriptionTier,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? location,
    Value<int>? capacity,
    Value<String>? userId,
    Value<String>? subscriptionTier,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FarmsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      userId: userId ?? this.userId,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (subscriptionTier.present) {
      map['subscription_tier'] = Variable<String>(subscriptionTier.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('capacity: $capacity, ')
          ..write('userId: $userId, ')
          ..write('subscriptionTier: $subscriptionTier, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BatchesTable extends Batches with TableInfo<$BatchesTable, Batch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchNameMeta = const VerificationMeta(
    'batchName',
  );
  @override
  late final GeneratedColumn<String> batchName = GeneratedColumn<String>(
    'batch_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('New Batch'),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('POULTRY_BROILER'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _breedTypeMeta = const VerificationMeta(
    'breedType',
  );
  @override
  late final GeneratedColumn<String> breedType = GeneratedColumn<String>(
    'breed_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arrivalDateMeta = const VerificationMeta(
    'arrivalDate',
  );
  @override
  late final GeneratedColumn<DateTime> arrivalDate = GeneratedColumn<DateTime>(
    'arrival_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentCountMeta = const VerificationMeta(
    'currentCount',
  );
  @override
  late final GeneratedColumn<int> currentCount = GeneratedColumn<int>(
    'current_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialCountMeta = const VerificationMeta(
    'initialCount',
  );
  @override
  late final GeneratedColumn<int> initialCount = GeneratedColumn<int>(
    'initial_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isolationCountMeta = const VerificationMeta(
    'isolationCount',
  );
  @override
  late final GeneratedColumn<int> isolationCount = GeneratedColumn<int>(
    'isolation_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _initialActualCostMeta = const VerificationMeta(
    'initialActualCost',
  );
  @override
  late final GeneratedColumn<double> initialActualCost =
      GeneratedColumn<double>(
        'initial_actual_cost',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _growthTargetMeta = const VerificationMeta(
    'growthTarget',
  );
  @override
  late final GeneratedColumn<String> growthTarget = GeneratedColumn<String>(
    'growth_target',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    houseId,
    userId,
    batchName,
    type,
    status,
    breedType,
    arrivalDate,
    currentCount,
    initialCount,
    isolationCount,
    initialActualCost,
    growthTarget,
    createdAt,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Batch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('batch_name')) {
      context.handle(
        _batchNameMeta,
        batchName.isAcceptableOrUnknown(data['batch_name']!, _batchNameMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('breed_type')) {
      context.handle(
        _breedTypeMeta,
        breedType.isAcceptableOrUnknown(data['breed_type']!, _breedTypeMeta),
      );
    }
    if (data.containsKey('arrival_date')) {
      context.handle(
        _arrivalDateMeta,
        arrivalDate.isAcceptableOrUnknown(
          data['arrival_date']!,
          _arrivalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalDateMeta);
    }
    if (data.containsKey('current_count')) {
      context.handle(
        _currentCountMeta,
        currentCount.isAcceptableOrUnknown(
          data['current_count']!,
          _currentCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentCountMeta);
    }
    if (data.containsKey('initial_count')) {
      context.handle(
        _initialCountMeta,
        initialCount.isAcceptableOrUnknown(
          data['initial_count']!,
          _initialCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialCountMeta);
    }
    if (data.containsKey('isolation_count')) {
      context.handle(
        _isolationCountMeta,
        isolationCount.isAcceptableOrUnknown(
          data['isolation_count']!,
          _isolationCountMeta,
        ),
      );
    }
    if (data.containsKey('initial_actual_cost')) {
      context.handle(
        _initialActualCostMeta,
        initialActualCost.isAcceptableOrUnknown(
          data['initial_actual_cost']!,
          _initialActualCostMeta,
        ),
      );
    }
    if (data.containsKey('growth_target')) {
      context.handle(
        _growthTargetMeta,
        growthTarget.isAcceptableOrUnknown(
          data['growth_target']!,
          _growthTargetMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Batch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Batch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      batchName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      breedType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed_type'],
      ),
      arrivalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arrival_date'],
      )!,
      currentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_count'],
      )!,
      initialCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_count'],
      )!,
      isolationCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}isolation_count'],
      )!,
      initialActualCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_actual_cost'],
      ),
      growthTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}growth_target'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $BatchesTable createAlias(String alias) {
    return $BatchesTable(attachedDatabase, alias);
  }
}

class Batch extends DataClass implements Insertable<Batch> {
  final String id;
  final String farmId;
  final String? houseId;
  final String? userId;
  final String batchName;
  final String type;
  final String status;
  final String? breedType;
  final DateTime arrivalDate;
  final int currentCount;
  final int initialCount;
  final int isolationCount;
  final double? initialActualCost;
  final String? growthTarget;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const Batch({
    required this.id,
    required this.farmId,
    this.houseId,
    this.userId,
    required this.batchName,
    required this.type,
    required this.status,
    this.breedType,
    required this.arrivalDate,
    required this.currentCount,
    required this.initialCount,
    required this.isolationCount,
    this.initialActualCost,
    this.growthTarget,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    if (!nullToAbsent || houseId != null) {
      map['house_id'] = Variable<String>(houseId);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['batch_name'] = Variable<String>(batchName);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || breedType != null) {
      map['breed_type'] = Variable<String>(breedType);
    }
    map['arrival_date'] = Variable<DateTime>(arrivalDate);
    map['current_count'] = Variable<int>(currentCount);
    map['initial_count'] = Variable<int>(initialCount);
    map['isolation_count'] = Variable<int>(isolationCount);
    if (!nullToAbsent || initialActualCost != null) {
      map['initial_actual_cost'] = Variable<double>(initialActualCost);
    }
    if (!nullToAbsent || growthTarget != null) {
      map['growth_target'] = Variable<String>(growthTarget);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  BatchesCompanion toCompanion(bool nullToAbsent) {
    return BatchesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      houseId: houseId == null && nullToAbsent
          ? const Value.absent()
          : Value(houseId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      batchName: Value(batchName),
      type: Value(type),
      status: Value(status),
      breedType: breedType == null && nullToAbsent
          ? const Value.absent()
          : Value(breedType),
      arrivalDate: Value(arrivalDate),
      currentCount: Value(currentCount),
      initialCount: Value(initialCount),
      isolationCount: Value(isolationCount),
      initialActualCost: initialActualCost == null && nullToAbsent
          ? const Value.absent()
          : Value(initialActualCost),
      growthTarget: growthTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(growthTarget),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory Batch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Batch(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      houseId: serializer.fromJson<String?>(json['houseId']),
      userId: serializer.fromJson<String?>(json['userId']),
      batchName: serializer.fromJson<String>(json['batchName']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      breedType: serializer.fromJson<String?>(json['breedType']),
      arrivalDate: serializer.fromJson<DateTime>(json['arrivalDate']),
      currentCount: serializer.fromJson<int>(json['currentCount']),
      initialCount: serializer.fromJson<int>(json['initialCount']),
      isolationCount: serializer.fromJson<int>(json['isolationCount']),
      initialActualCost: serializer.fromJson<double?>(
        json['initialActualCost'],
      ),
      growthTarget: serializer.fromJson<String?>(json['growthTarget']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'houseId': serializer.toJson<String?>(houseId),
      'userId': serializer.toJson<String?>(userId),
      'batchName': serializer.toJson<String>(batchName),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'breedType': serializer.toJson<String?>(breedType),
      'arrivalDate': serializer.toJson<DateTime>(arrivalDate),
      'currentCount': serializer.toJson<int>(currentCount),
      'initialCount': serializer.toJson<int>(initialCount),
      'isolationCount': serializer.toJson<int>(isolationCount),
      'initialActualCost': serializer.toJson<double?>(initialActualCost),
      'growthTarget': serializer.toJson<String?>(growthTarget),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Batch copyWith({
    String? id,
    String? farmId,
    Value<String?> houseId = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    String? batchName,
    String? type,
    String? status,
    Value<String?> breedType = const Value.absent(),
    DateTime? arrivalDate,
    int? currentCount,
    int? initialCount,
    int? isolationCount,
    Value<double?> initialActualCost = const Value.absent(),
    Value<String?> growthTarget = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) => Batch(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    houseId: houseId.present ? houseId.value : this.houseId,
    userId: userId.present ? userId.value : this.userId,
    batchName: batchName ?? this.batchName,
    type: type ?? this.type,
    status: status ?? this.status,
    breedType: breedType.present ? breedType.value : this.breedType,
    arrivalDate: arrivalDate ?? this.arrivalDate,
    currentCount: currentCount ?? this.currentCount,
    initialCount: initialCount ?? this.initialCount,
    isolationCount: isolationCount ?? this.isolationCount,
    initialActualCost: initialActualCost.present
        ? initialActualCost.value
        : this.initialActualCost,
    growthTarget: growthTarget.present ? growthTarget.value : this.growthTarget,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  Batch copyWithCompanion(BatchesCompanion data) {
    return Batch(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      userId: data.userId.present ? data.userId.value : this.userId,
      batchName: data.batchName.present ? data.batchName.value : this.batchName,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      breedType: data.breedType.present ? data.breedType.value : this.breedType,
      arrivalDate: data.arrivalDate.present
          ? data.arrivalDate.value
          : this.arrivalDate,
      currentCount: data.currentCount.present
          ? data.currentCount.value
          : this.currentCount,
      initialCount: data.initialCount.present
          ? data.initialCount.value
          : this.initialCount,
      isolationCount: data.isolationCount.present
          ? data.isolationCount.value
          : this.isolationCount,
      initialActualCost: data.initialActualCost.present
          ? data.initialActualCost.value
          : this.initialActualCost,
      growthTarget: data.growthTarget.present
          ? data.growthTarget.value
          : this.growthTarget,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Batch(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('houseId: $houseId, ')
          ..write('userId: $userId, ')
          ..write('batchName: $batchName, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('breedType: $breedType, ')
          ..write('arrivalDate: $arrivalDate, ')
          ..write('currentCount: $currentCount, ')
          ..write('initialCount: $initialCount, ')
          ..write('isolationCount: $isolationCount, ')
          ..write('initialActualCost: $initialActualCost, ')
          ..write('growthTarget: $growthTarget, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    houseId,
    userId,
    batchName,
    type,
    status,
    breedType,
    arrivalDate,
    currentCount,
    initialCount,
    isolationCount,
    initialActualCost,
    growthTarget,
    createdAt,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Batch &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.houseId == this.houseId &&
          other.userId == this.userId &&
          other.batchName == this.batchName &&
          other.type == this.type &&
          other.status == this.status &&
          other.breedType == this.breedType &&
          other.arrivalDate == this.arrivalDate &&
          other.currentCount == this.currentCount &&
          other.initialCount == this.initialCount &&
          other.isolationCount == this.isolationCount &&
          other.initialActualCost == this.initialActualCost &&
          other.growthTarget == this.growthTarget &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class BatchesCompanion extends UpdateCompanion<Batch> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String?> houseId;
  final Value<String?> userId;
  final Value<String> batchName;
  final Value<String> type;
  final Value<String> status;
  final Value<String?> breedType;
  final Value<DateTime> arrivalDate;
  final Value<int> currentCount;
  final Value<int> initialCount;
  final Value<int> isolationCount;
  final Value<double?> initialActualCost;
  final Value<String?> growthTarget;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const BatchesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.houseId = const Value.absent(),
    this.userId = const Value.absent(),
    this.batchName = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.breedType = const Value.absent(),
    this.arrivalDate = const Value.absent(),
    this.currentCount = const Value.absent(),
    this.initialCount = const Value.absent(),
    this.isolationCount = const Value.absent(),
    this.initialActualCost = const Value.absent(),
    this.growthTarget = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchesCompanion.insert({
    required String id,
    required String farmId,
    this.houseId = const Value.absent(),
    this.userId = const Value.absent(),
    this.batchName = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.breedType = const Value.absent(),
    required DateTime arrivalDate,
    required int currentCount,
    required int initialCount,
    this.isolationCount = const Value.absent(),
    this.initialActualCost = const Value.absent(),
    this.growthTarget = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       arrivalDate = Value(arrivalDate),
       currentCount = Value(currentCount),
       initialCount = Value(initialCount);
  static Insertable<Batch> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? houseId,
    Expression<String>? userId,
    Expression<String>? batchName,
    Expression<String>? type,
    Expression<String>? status,
    Expression<String>? breedType,
    Expression<DateTime>? arrivalDate,
    Expression<int>? currentCount,
    Expression<int>? initialCount,
    Expression<int>? isolationCount,
    Expression<double>? initialActualCost,
    Expression<String>? growthTarget,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (houseId != null) 'house_id': houseId,
      if (userId != null) 'user_id': userId,
      if (batchName != null) 'batch_name': batchName,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (breedType != null) 'breed_type': breedType,
      if (arrivalDate != null) 'arrival_date': arrivalDate,
      if (currentCount != null) 'current_count': currentCount,
      if (initialCount != null) 'initial_count': initialCount,
      if (isolationCount != null) 'isolation_count': isolationCount,
      if (initialActualCost != null) 'initial_actual_cost': initialActualCost,
      if (growthTarget != null) 'growth_target': growthTarget,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String?>? houseId,
    Value<String?>? userId,
    Value<String>? batchName,
    Value<String>? type,
    Value<String>? status,
    Value<String?>? breedType,
    Value<DateTime>? arrivalDate,
    Value<int>? currentCount,
    Value<int>? initialCount,
    Value<int>? isolationCount,
    Value<double?>? initialActualCost,
    Value<String?>? growthTarget,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return BatchesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      houseId: houseId ?? this.houseId,
      userId: userId ?? this.userId,
      batchName: batchName ?? this.batchName,
      type: type ?? this.type,
      status: status ?? this.status,
      breedType: breedType ?? this.breedType,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      currentCount: currentCount ?? this.currentCount,
      initialCount: initialCount ?? this.initialCount,
      isolationCount: isolationCount ?? this.isolationCount,
      initialActualCost: initialActualCost ?? this.initialActualCost,
      growthTarget: growthTarget ?? this.growthTarget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (batchName.present) {
      map['batch_name'] = Variable<String>(batchName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (breedType.present) {
      map['breed_type'] = Variable<String>(breedType.value);
    }
    if (arrivalDate.present) {
      map['arrival_date'] = Variable<DateTime>(arrivalDate.value);
    }
    if (currentCount.present) {
      map['current_count'] = Variable<int>(currentCount.value);
    }
    if (initialCount.present) {
      map['initial_count'] = Variable<int>(initialCount.value);
    }
    if (isolationCount.present) {
      map['isolation_count'] = Variable<int>(isolationCount.value);
    }
    if (initialActualCost.present) {
      map['initial_actual_cost'] = Variable<double>(initialActualCost.value);
    }
    if (growthTarget.present) {
      map['growth_target'] = Variable<String>(growthTarget.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('houseId: $houseId, ')
          ..write('userId: $userId, ')
          ..write('batchName: $batchName, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('breedType: $breedType, ')
          ..write('arrivalDate: $arrivalDate, ')
          ..write('currentCount: $currentCount, ')
          ..write('initialCount: $initialCount, ')
          ..write('isolationCount: $isolationCount, ')
          ..write('initialActualCost: $initialActualCost, ')
          ..write('growthTarget: $growthTarget, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryTable extends Inventory
    with TableInfo<$InventoryTable, InventoryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemNameMeta = const VerificationMeta(
    'itemName',
  );
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
    'item_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockLevelMeta = const VerificationMeta(
    'stockLevel',
  );
  @override
  late final GeneratedColumn<double> stockLevel = GeneratedColumn<double>(
    'stock_level',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reorderLevelMeta = const VerificationMeta(
    'reorderLevel',
  );
  @override
  late final GeneratedColumn<double> reorderLevel = GeneratedColumn<double>(
    'reorder_level',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costPerUnitMeta = const VerificationMeta(
    'costPerUnit',
  );
  @override
  late final GeneratedColumn<double> costPerUnit = GeneratedColumn<double>(
    'cost_per_unit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eggCategoryIdMeta = const VerificationMeta(
    'eggCategoryId',
  );
  @override
  late final GeneratedColumn<String> eggCategoryId = GeneratedColumn<String>(
    'egg_category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usageTypeMeta = const VerificationMeta(
    'usageType',
  );
  @override
  late final GeneratedColumn<String> usageType = GeneratedColumn<String>(
    'usage_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    userId,
    itemName,
    stockLevel,
    reorderLevel,
    unit,
    category,
    costPerUnit,
    eggCategoryId,
    usageType,
    supplierId,
    createdAt,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('item_name')) {
      context.handle(
        _itemNameMeta,
        itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta),
      );
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('stock_level')) {
      context.handle(
        _stockLevelMeta,
        stockLevel.isAcceptableOrUnknown(data['stock_level']!, _stockLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_stockLevelMeta);
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
        _reorderLevelMeta,
        reorderLevel.isAcceptableOrUnknown(
          data['reorder_level']!,
          _reorderLevelMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('cost_per_unit')) {
      context.handle(
        _costPerUnitMeta,
        costPerUnit.isAcceptableOrUnknown(
          data['cost_per_unit']!,
          _costPerUnitMeta,
        ),
      );
    }
    if (data.containsKey('egg_category_id')) {
      context.handle(
        _eggCategoryIdMeta,
        eggCategoryId.isAcceptableOrUnknown(
          data['egg_category_id']!,
          _eggCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('usage_type')) {
      context.handle(
        _usageTypeMeta,
        usageType.isAcceptableOrUnknown(data['usage_type']!, _usageTypeMeta),
      );
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      itemName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_name'],
      )!,
      stockLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_level'],
      )!,
      reorderLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reorder_level'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      costPerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_per_unit'],
      ),
      eggCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}egg_category_id'],
      ),
      usageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage_type'],
      ),
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $InventoryTable createAlias(String alias) {
    return $InventoryTable(attachedDatabase, alias);
  }
}

class InventoryItem extends DataClass implements Insertable<InventoryItem> {
  final String id;
  final String farmId;
  final String? userId;
  final String itemName;
  final double stockLevel;
  final double? reorderLevel;
  final String unit;
  final String? category;
  final double? costPerUnit;
  final String? eggCategoryId;
  final String? usageType;
  final String? supplierId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const InventoryItem({
    required this.id,
    required this.farmId,
    this.userId,
    required this.itemName,
    required this.stockLevel,
    this.reorderLevel,
    required this.unit,
    this.category,
    this.costPerUnit,
    this.eggCategoryId,
    this.usageType,
    this.supplierId,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['item_name'] = Variable<String>(itemName);
    map['stock_level'] = Variable<double>(stockLevel);
    if (!nullToAbsent || reorderLevel != null) {
      map['reorder_level'] = Variable<double>(reorderLevel);
    }
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || costPerUnit != null) {
      map['cost_per_unit'] = Variable<double>(costPerUnit);
    }
    if (!nullToAbsent || eggCategoryId != null) {
      map['egg_category_id'] = Variable<String>(eggCategoryId);
    }
    if (!nullToAbsent || usageType != null) {
      map['usage_type'] = Variable<String>(usageType);
    }
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  InventoryCompanion toCompanion(bool nullToAbsent) {
    return InventoryCompanion(
      id: Value(id),
      farmId: Value(farmId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      itemName: Value(itemName),
      stockLevel: Value(stockLevel),
      reorderLevel: reorderLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(reorderLevel),
      unit: Value(unit),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      costPerUnit: costPerUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(costPerUnit),
      eggCategoryId: eggCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(eggCategoryId),
      usageType: usageType == null && nullToAbsent
          ? const Value.absent()
          : Value(usageType),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory InventoryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryItem(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      userId: serializer.fromJson<String?>(json['userId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      stockLevel: serializer.fromJson<double>(json['stockLevel']),
      reorderLevel: serializer.fromJson<double?>(json['reorderLevel']),
      unit: serializer.fromJson<String>(json['unit']),
      category: serializer.fromJson<String?>(json['category']),
      costPerUnit: serializer.fromJson<double?>(json['costPerUnit']),
      eggCategoryId: serializer.fromJson<String?>(json['eggCategoryId']),
      usageType: serializer.fromJson<String?>(json['usageType']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'userId': serializer.toJson<String?>(userId),
      'itemName': serializer.toJson<String>(itemName),
      'stockLevel': serializer.toJson<double>(stockLevel),
      'reorderLevel': serializer.toJson<double?>(reorderLevel),
      'unit': serializer.toJson<String>(unit),
      'category': serializer.toJson<String?>(category),
      'costPerUnit': serializer.toJson<double?>(costPerUnit),
      'eggCategoryId': serializer.toJson<String?>(eggCategoryId),
      'usageType': serializer.toJson<String?>(usageType),
      'supplierId': serializer.toJson<String?>(supplierId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  InventoryItem copyWith({
    String? id,
    String? farmId,
    Value<String?> userId = const Value.absent(),
    String? itemName,
    double? stockLevel,
    Value<double?> reorderLevel = const Value.absent(),
    String? unit,
    Value<String?> category = const Value.absent(),
    Value<double?> costPerUnit = const Value.absent(),
    Value<String?> eggCategoryId = const Value.absent(),
    Value<String?> usageType = const Value.absent(),
    Value<String?> supplierId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) => InventoryItem(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    userId: userId.present ? userId.value : this.userId,
    itemName: itemName ?? this.itemName,
    stockLevel: stockLevel ?? this.stockLevel,
    reorderLevel: reorderLevel.present ? reorderLevel.value : this.reorderLevel,
    unit: unit ?? this.unit,
    category: category.present ? category.value : this.category,
    costPerUnit: costPerUnit.present ? costPerUnit.value : this.costPerUnit,
    eggCategoryId: eggCategoryId.present
        ? eggCategoryId.value
        : this.eggCategoryId,
    usageType: usageType.present ? usageType.value : this.usageType,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  InventoryItem copyWithCompanion(InventoryCompanion data) {
    return InventoryItem(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      userId: data.userId.present ? data.userId.value : this.userId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      stockLevel: data.stockLevel.present
          ? data.stockLevel.value
          : this.stockLevel,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
      unit: data.unit.present ? data.unit.value : this.unit,
      category: data.category.present ? data.category.value : this.category,
      costPerUnit: data.costPerUnit.present
          ? data.costPerUnit.value
          : this.costPerUnit,
      eggCategoryId: data.eggCategoryId.present
          ? data.eggCategoryId.value
          : this.eggCategoryId,
      usageType: data.usageType.present ? data.usageType.value : this.usageType,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItem(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('itemName: $itemName, ')
          ..write('stockLevel: $stockLevel, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('eggCategoryId: $eggCategoryId, ')
          ..write('usageType: $usageType, ')
          ..write('supplierId: $supplierId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    userId,
    itemName,
    stockLevel,
    reorderLevel,
    unit,
    category,
    costPerUnit,
    eggCategoryId,
    usageType,
    supplierId,
    createdAt,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryItem &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.userId == this.userId &&
          other.itemName == this.itemName &&
          other.stockLevel == this.stockLevel &&
          other.reorderLevel == this.reorderLevel &&
          other.unit == this.unit &&
          other.category == this.category &&
          other.costPerUnit == this.costPerUnit &&
          other.eggCategoryId == this.eggCategoryId &&
          other.usageType == this.usageType &&
          other.supplierId == this.supplierId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class InventoryCompanion extends UpdateCompanion<InventoryItem> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String?> userId;
  final Value<String> itemName;
  final Value<double> stockLevel;
  final Value<double?> reorderLevel;
  final Value<String> unit;
  final Value<String?> category;
  final Value<double?> costPerUnit;
  final Value<String?> eggCategoryId;
  final Value<String?> usageType;
  final Value<String?> supplierId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const InventoryCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.userId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.stockLevel = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.eggCategoryId = const Value.absent(),
    this.usageType = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryCompanion.insert({
    required String id,
    required String farmId,
    this.userId = const Value.absent(),
    required String itemName,
    required double stockLevel,
    this.reorderLevel = const Value.absent(),
    required String unit,
    this.category = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.eggCategoryId = const Value.absent(),
    this.usageType = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       itemName = Value(itemName),
       stockLevel = Value(stockLevel),
       unit = Value(unit);
  static Insertable<InventoryItem> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? userId,
    Expression<String>? itemName,
    Expression<double>? stockLevel,
    Expression<double>? reorderLevel,
    Expression<String>? unit,
    Expression<String>? category,
    Expression<double>? costPerUnit,
    Expression<String>? eggCategoryId,
    Expression<String>? usageType,
    Expression<String>? supplierId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (itemName != null) 'item_name': itemName,
      if (stockLevel != null) 'stock_level': stockLevel,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (unit != null) 'unit': unit,
      if (category != null) 'category': category,
      if (costPerUnit != null) 'cost_per_unit': costPerUnit,
      if (eggCategoryId != null) 'egg_category_id': eggCategoryId,
      if (usageType != null) 'usage_type': usageType,
      if (supplierId != null) 'supplier_id': supplierId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String?>? userId,
    Value<String>? itemName,
    Value<double>? stockLevel,
    Value<double?>? reorderLevel,
    Value<String>? unit,
    Value<String?>? category,
    Value<double?>? costPerUnit,
    Value<String?>? eggCategoryId,
    Value<String?>? usageType,
    Value<String?>? supplierId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return InventoryCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      userId: userId ?? this.userId,
      itemName: itemName ?? this.itemName,
      stockLevel: stockLevel ?? this.stockLevel,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      eggCategoryId: eggCategoryId ?? this.eggCategoryId,
      usageType: usageType ?? this.usageType,
      supplierId: supplierId ?? this.supplierId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (stockLevel.present) {
      map['stock_level'] = Variable<double>(stockLevel.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<double>(reorderLevel.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (costPerUnit.present) {
      map['cost_per_unit'] = Variable<double>(costPerUnit.value);
    }
    if (eggCategoryId.present) {
      map['egg_category_id'] = Variable<String>(eggCategoryId.value);
    }
    if (usageType.present) {
      map['usage_type'] = Variable<String>(usageType.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('itemName: $itemName, ')
          ..write('stockLevel: $stockLevel, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('eggCategoryId: $eggCategoryId, ')
          ..write('usageType: $usageType, ')
          ..write('supplierId: $supplierId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedingLogsTable extends FeedingLogs
    with TableInfo<$FeedingLogsTable, FeedingLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedingLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feedTypeIdMeta = const VerificationMeta(
    'feedTypeId',
  );
  @override
  late final GeneratedColumn<String> feedTypeId = GeneratedColumn<String>(
    'feed_type_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formulationIdMeta = const VerificationMeta(
    'formulationId',
  );
  @override
  late final GeneratedColumn<String> formulationId = GeneratedColumn<String>(
    'formulation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountConsumedMeta = const VerificationMeta(
    'amountConsumed',
  );
  @override
  late final GeneratedColumn<double> amountConsumed = GeneratedColumn<double>(
    'amount_consumed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    batchId,
    feedTypeId,
    formulationId,
    amountConsumed,
    logDate,
    userId,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_feeding_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedingLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('feed_type_id')) {
      context.handle(
        _feedTypeIdMeta,
        feedTypeId.isAcceptableOrUnknown(
          data['feed_type_id']!,
          _feedTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('formulation_id')) {
      context.handle(
        _formulationIdMeta,
        formulationId.isAcceptableOrUnknown(
          data['formulation_id']!,
          _formulationIdMeta,
        ),
      );
    }
    if (data.containsKey('amount_consumed')) {
      context.handle(
        _amountConsumedMeta,
        amountConsumed.isAcceptableOrUnknown(
          data['amount_consumed']!,
          _amountConsumedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountConsumedMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedingLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedingLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      feedTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_type_id'],
      ),
      formulationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formulation_id'],
      ),
      amountConsumed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_consumed'],
      )!,
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}log_date'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $FeedingLogsTable createAlias(String alias) {
    return $FeedingLogsTable(attachedDatabase, alias);
  }
}

class FeedingLog extends DataClass implements Insertable<FeedingLog> {
  final String id;
  final String farmId;
  final String? batchId;
  final String? feedTypeId;
  final String? formulationId;
  final double amountConsumed;
  final DateTime logDate;
  final String? userId;
  final bool synced;
  const FeedingLog({
    required this.id,
    required this.farmId,
    this.batchId,
    this.feedTypeId,
    this.formulationId,
    required this.amountConsumed,
    required this.logDate,
    this.userId,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    if (!nullToAbsent || feedTypeId != null) {
      map['feed_type_id'] = Variable<String>(feedTypeId);
    }
    if (!nullToAbsent || formulationId != null) {
      map['formulation_id'] = Variable<String>(formulationId);
    }
    map['amount_consumed'] = Variable<double>(amountConsumed);
    map['log_date'] = Variable<DateTime>(logDate);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  FeedingLogsCompanion toCompanion(bool nullToAbsent) {
    return FeedingLogsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      feedTypeId: feedTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(feedTypeId),
      formulationId: formulationId == null && nullToAbsent
          ? const Value.absent()
          : Value(formulationId),
      amountConsumed: Value(amountConsumed),
      logDate: Value(logDate),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      synced: Value(synced),
    );
  }

  factory FeedingLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedingLog(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      feedTypeId: serializer.fromJson<String?>(json['feedTypeId']),
      formulationId: serializer.fromJson<String?>(json['formulationId']),
      amountConsumed: serializer.fromJson<double>(json['amountConsumed']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      userId: serializer.fromJson<String?>(json['userId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'batchId': serializer.toJson<String?>(batchId),
      'feedTypeId': serializer.toJson<String?>(feedTypeId),
      'formulationId': serializer.toJson<String?>(formulationId),
      'amountConsumed': serializer.toJson<double>(amountConsumed),
      'logDate': serializer.toJson<DateTime>(logDate),
      'userId': serializer.toJson<String?>(userId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  FeedingLog copyWith({
    String? id,
    String? farmId,
    Value<String?> batchId = const Value.absent(),
    Value<String?> feedTypeId = const Value.absent(),
    Value<String?> formulationId = const Value.absent(),
    double? amountConsumed,
    DateTime? logDate,
    Value<String?> userId = const Value.absent(),
    bool? synced,
  }) => FeedingLog(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    batchId: batchId.present ? batchId.value : this.batchId,
    feedTypeId: feedTypeId.present ? feedTypeId.value : this.feedTypeId,
    formulationId: formulationId.present
        ? formulationId.value
        : this.formulationId,
    amountConsumed: amountConsumed ?? this.amountConsumed,
    logDate: logDate ?? this.logDate,
    userId: userId.present ? userId.value : this.userId,
    synced: synced ?? this.synced,
  );
  FeedingLog copyWithCompanion(FeedingLogsCompanion data) {
    return FeedingLog(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      feedTypeId: data.feedTypeId.present
          ? data.feedTypeId.value
          : this.feedTypeId,
      formulationId: data.formulationId.present
          ? data.formulationId.value
          : this.formulationId,
      amountConsumed: data.amountConsumed.present
          ? data.amountConsumed.value
          : this.amountConsumed,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedingLog(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('feedTypeId: $feedTypeId, ')
          ..write('formulationId: $formulationId, ')
          ..write('amountConsumed: $amountConsumed, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    batchId,
    feedTypeId,
    formulationId,
    amountConsumed,
    logDate,
    userId,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedingLog &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.batchId == this.batchId &&
          other.feedTypeId == this.feedTypeId &&
          other.formulationId == this.formulationId &&
          other.amountConsumed == this.amountConsumed &&
          other.logDate == this.logDate &&
          other.userId == this.userId &&
          other.synced == this.synced);
}

class FeedingLogsCompanion extends UpdateCompanion<FeedingLog> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String?> batchId;
  final Value<String?> feedTypeId;
  final Value<String?> formulationId;
  final Value<double> amountConsumed;
  final Value<DateTime> logDate;
  final Value<String?> userId;
  final Value<bool> synced;
  final Value<int> rowid;
  const FeedingLogsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.feedTypeId = const Value.absent(),
    this.formulationId = const Value.absent(),
    this.amountConsumed = const Value.absent(),
    this.logDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedingLogsCompanion.insert({
    required String id,
    required String farmId,
    this.batchId = const Value.absent(),
    this.feedTypeId = const Value.absent(),
    this.formulationId = const Value.absent(),
    required double amountConsumed,
    required DateTime logDate,
    this.userId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       amountConsumed = Value(amountConsumed),
       logDate = Value(logDate);
  static Insertable<FeedingLog> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? batchId,
    Expression<String>? feedTypeId,
    Expression<String>? formulationId,
    Expression<double>? amountConsumed,
    Expression<DateTime>? logDate,
    Expression<String>? userId,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (batchId != null) 'batch_id': batchId,
      if (feedTypeId != null) 'feed_type_id': feedTypeId,
      if (formulationId != null) 'formulation_id': formulationId,
      if (amountConsumed != null) 'amount_consumed': amountConsumed,
      if (logDate != null) 'log_date': logDate,
      if (userId != null) 'user_id': userId,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedingLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String?>? batchId,
    Value<String?>? feedTypeId,
    Value<String?>? formulationId,
    Value<double>? amountConsumed,
    Value<DateTime>? logDate,
    Value<String?>? userId,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return FeedingLogsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      batchId: batchId ?? this.batchId,
      feedTypeId: feedTypeId ?? this.feedTypeId,
      formulationId: formulationId ?? this.formulationId,
      amountConsumed: amountConsumed ?? this.amountConsumed,
      logDate: logDate ?? this.logDate,
      userId: userId ?? this.userId,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (feedTypeId.present) {
      map['feed_type_id'] = Variable<String>(feedTypeId.value);
    }
    if (formulationId.present) {
      map['formulation_id'] = Variable<String>(formulationId.value);
    }
    if (amountConsumed.present) {
      map['amount_consumed'] = Variable<double>(amountConsumed.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedingLogsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('feedTypeId: $feedTypeId, ')
          ..write('formulationId: $formulationId, ')
          ..write('amountConsumed: $amountConsumed, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EggProductionsTable extends EggProductions
    with TableInfo<$EggProductionsTable, EggProduction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EggProductionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eggsCollectedMeta = const VerificationMeta(
    'eggsCollected',
  );
  @override
  late final GeneratedColumn<int> eggsCollected = GeneratedColumn<int>(
    'eggs_collected',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unusableCountMeta = const VerificationMeta(
    'unusableCount',
  );
  @override
  late final GeneratedColumn<int> unusableCount = GeneratedColumn<int>(
    'unusable_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _eggsRemainingMeta = const VerificationMeta(
    'eggsRemaining',
  );
  @override
  late final GeneratedColumn<int> eggsRemaining = GeneratedColumn<int>(
    'eggs_remaining',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cratesCollectedMeta = const VerificationMeta(
    'cratesCollected',
  );
  @override
  late final GeneratedColumn<double> cratesCollected = GeneratedColumn<double>(
    'crates_collected',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityGradeMeta = const VerificationMeta(
    'qualityGrade',
  );
  @override
  late final GeneratedColumn<String> qualityGrade = GeneratedColumn<String>(
    'quality_grade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSortedMeta = const VerificationMeta(
    'isSorted',
  );
  @override
  late final GeneratedColumn<bool> isSorted = GeneratedColumn<bool>(
    'is_sorted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_sorted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _smallCountMeta = const VerificationMeta(
    'smallCount',
  );
  @override
  late final GeneratedColumn<int> smallCount = GeneratedColumn<int>(
    'small_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mediumCountMeta = const VerificationMeta(
    'mediumCount',
  );
  @override
  late final GeneratedColumn<int> mediumCount = GeneratedColumn<int>(
    'medium_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _largeCountMeta = const VerificationMeta(
    'largeCount',
  );
  @override
  late final GeneratedColumn<int> largeCount = GeneratedColumn<int>(
    'large_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    batchId,
    categoryId,
    eggsCollected,
    unusableCount,
    eggsRemaining,
    cratesCollected,
    qualityGrade,
    isSorted,
    smallCount,
    mediumCount,
    largeCount,
    logDate,
    userId,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'egg_production';
  @override
  VerificationContext validateIntegrity(
    Insertable<EggProduction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('eggs_collected')) {
      context.handle(
        _eggsCollectedMeta,
        eggsCollected.isAcceptableOrUnknown(
          data['eggs_collected']!,
          _eggsCollectedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eggsCollectedMeta);
    }
    if (data.containsKey('unusable_count')) {
      context.handle(
        _unusableCountMeta,
        unusableCount.isAcceptableOrUnknown(
          data['unusable_count']!,
          _unusableCountMeta,
        ),
      );
    }
    if (data.containsKey('eggs_remaining')) {
      context.handle(
        _eggsRemainingMeta,
        eggsRemaining.isAcceptableOrUnknown(
          data['eggs_remaining']!,
          _eggsRemainingMeta,
        ),
      );
    }
    if (data.containsKey('crates_collected')) {
      context.handle(
        _cratesCollectedMeta,
        cratesCollected.isAcceptableOrUnknown(
          data['crates_collected']!,
          _cratesCollectedMeta,
        ),
      );
    }
    if (data.containsKey('quality_grade')) {
      context.handle(
        _qualityGradeMeta,
        qualityGrade.isAcceptableOrUnknown(
          data['quality_grade']!,
          _qualityGradeMeta,
        ),
      );
    }
    if (data.containsKey('is_sorted')) {
      context.handle(
        _isSortedMeta,
        isSorted.isAcceptableOrUnknown(data['is_sorted']!, _isSortedMeta),
      );
    }
    if (data.containsKey('small_count')) {
      context.handle(
        _smallCountMeta,
        smallCount.isAcceptableOrUnknown(data['small_count']!, _smallCountMeta),
      );
    }
    if (data.containsKey('medium_count')) {
      context.handle(
        _mediumCountMeta,
        mediumCount.isAcceptableOrUnknown(
          data['medium_count']!,
          _mediumCountMeta,
        ),
      );
    }
    if (data.containsKey('large_count')) {
      context.handle(
        _largeCountMeta,
        largeCount.isAcceptableOrUnknown(data['large_count']!, _largeCountMeta),
      );
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EggProduction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EggProduction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      eggsCollected: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eggs_collected'],
      )!,
      unusableCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unusable_count'],
      )!,
      eggsRemaining: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eggs_remaining'],
      )!,
      cratesCollected: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}crates_collected'],
      ),
      qualityGrade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality_grade'],
      ),
      isSorted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_sorted'],
      )!,
      smallCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}small_count'],
      )!,
      mediumCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medium_count'],
      )!,
      largeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}large_count'],
      )!,
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}log_date'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $EggProductionsTable createAlias(String alias) {
    return $EggProductionsTable(attachedDatabase, alias);
  }
}

class EggProduction extends DataClass implements Insertable<EggProduction> {
  final String id;
  final String farmId;
  final String batchId;
  final String? categoryId;
  final int eggsCollected;
  final int unusableCount;
  final int eggsRemaining;
  final double? cratesCollected;
  final String? qualityGrade;
  final bool isSorted;
  final int smallCount;
  final int mediumCount;
  final int largeCount;
  final DateTime logDate;
  final String? userId;
  final DateTime createdAt;
  final bool synced;
  const EggProduction({
    required this.id,
    required this.farmId,
    required this.batchId,
    this.categoryId,
    required this.eggsCollected,
    required this.unusableCount,
    required this.eggsRemaining,
    this.cratesCollected,
    this.qualityGrade,
    required this.isSorted,
    required this.smallCount,
    required this.mediumCount,
    required this.largeCount,
    required this.logDate,
    this.userId,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['batch_id'] = Variable<String>(batchId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['eggs_collected'] = Variable<int>(eggsCollected);
    map['unusable_count'] = Variable<int>(unusableCount);
    map['eggs_remaining'] = Variable<int>(eggsRemaining);
    if (!nullToAbsent || cratesCollected != null) {
      map['crates_collected'] = Variable<double>(cratesCollected);
    }
    if (!nullToAbsent || qualityGrade != null) {
      map['quality_grade'] = Variable<String>(qualityGrade);
    }
    map['is_sorted'] = Variable<bool>(isSorted);
    map['small_count'] = Variable<int>(smallCount);
    map['medium_count'] = Variable<int>(mediumCount);
    map['large_count'] = Variable<int>(largeCount);
    map['log_date'] = Variable<DateTime>(logDate);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  EggProductionsCompanion toCompanion(bool nullToAbsent) {
    return EggProductionsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      batchId: Value(batchId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      eggsCollected: Value(eggsCollected),
      unusableCount: Value(unusableCount),
      eggsRemaining: Value(eggsRemaining),
      cratesCollected: cratesCollected == null && nullToAbsent
          ? const Value.absent()
          : Value(cratesCollected),
      qualityGrade: qualityGrade == null && nullToAbsent
          ? const Value.absent()
          : Value(qualityGrade),
      isSorted: Value(isSorted),
      smallCount: Value(smallCount),
      mediumCount: Value(mediumCount),
      largeCount: Value(largeCount),
      logDate: Value(logDate),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory EggProduction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EggProduction(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      eggsCollected: serializer.fromJson<int>(json['eggsCollected']),
      unusableCount: serializer.fromJson<int>(json['unusableCount']),
      eggsRemaining: serializer.fromJson<int>(json['eggsRemaining']),
      cratesCollected: serializer.fromJson<double?>(json['cratesCollected']),
      qualityGrade: serializer.fromJson<String?>(json['qualityGrade']),
      isSorted: serializer.fromJson<bool>(json['isSorted']),
      smallCount: serializer.fromJson<int>(json['smallCount']),
      mediumCount: serializer.fromJson<int>(json['mediumCount']),
      largeCount: serializer.fromJson<int>(json['largeCount']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      userId: serializer.fromJson<String?>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'batchId': serializer.toJson<String>(batchId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'eggsCollected': serializer.toJson<int>(eggsCollected),
      'unusableCount': serializer.toJson<int>(unusableCount),
      'eggsRemaining': serializer.toJson<int>(eggsRemaining),
      'cratesCollected': serializer.toJson<double?>(cratesCollected),
      'qualityGrade': serializer.toJson<String?>(qualityGrade),
      'isSorted': serializer.toJson<bool>(isSorted),
      'smallCount': serializer.toJson<int>(smallCount),
      'mediumCount': serializer.toJson<int>(mediumCount),
      'largeCount': serializer.toJson<int>(largeCount),
      'logDate': serializer.toJson<DateTime>(logDate),
      'userId': serializer.toJson<String?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  EggProduction copyWith({
    String? id,
    String? farmId,
    String? batchId,
    Value<String?> categoryId = const Value.absent(),
    int? eggsCollected,
    int? unusableCount,
    int? eggsRemaining,
    Value<double?> cratesCollected = const Value.absent(),
    Value<String?> qualityGrade = const Value.absent(),
    bool? isSorted,
    int? smallCount,
    int? mediumCount,
    int? largeCount,
    DateTime? logDate,
    Value<String?> userId = const Value.absent(),
    DateTime? createdAt,
    bool? synced,
  }) => EggProduction(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    batchId: batchId ?? this.batchId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    eggsCollected: eggsCollected ?? this.eggsCollected,
    unusableCount: unusableCount ?? this.unusableCount,
    eggsRemaining: eggsRemaining ?? this.eggsRemaining,
    cratesCollected: cratesCollected.present
        ? cratesCollected.value
        : this.cratesCollected,
    qualityGrade: qualityGrade.present ? qualityGrade.value : this.qualityGrade,
    isSorted: isSorted ?? this.isSorted,
    smallCount: smallCount ?? this.smallCount,
    mediumCount: mediumCount ?? this.mediumCount,
    largeCount: largeCount ?? this.largeCount,
    logDate: logDate ?? this.logDate,
    userId: userId.present ? userId.value : this.userId,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  EggProduction copyWithCompanion(EggProductionsCompanion data) {
    return EggProduction(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      eggsCollected: data.eggsCollected.present
          ? data.eggsCollected.value
          : this.eggsCollected,
      unusableCount: data.unusableCount.present
          ? data.unusableCount.value
          : this.unusableCount,
      eggsRemaining: data.eggsRemaining.present
          ? data.eggsRemaining.value
          : this.eggsRemaining,
      cratesCollected: data.cratesCollected.present
          ? data.cratesCollected.value
          : this.cratesCollected,
      qualityGrade: data.qualityGrade.present
          ? data.qualityGrade.value
          : this.qualityGrade,
      isSorted: data.isSorted.present ? data.isSorted.value : this.isSorted,
      smallCount: data.smallCount.present
          ? data.smallCount.value
          : this.smallCount,
      mediumCount: data.mediumCount.present
          ? data.mediumCount.value
          : this.mediumCount,
      largeCount: data.largeCount.present
          ? data.largeCount.value
          : this.largeCount,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EggProduction(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('categoryId: $categoryId, ')
          ..write('eggsCollected: $eggsCollected, ')
          ..write('unusableCount: $unusableCount, ')
          ..write('eggsRemaining: $eggsRemaining, ')
          ..write('cratesCollected: $cratesCollected, ')
          ..write('qualityGrade: $qualityGrade, ')
          ..write('isSorted: $isSorted, ')
          ..write('smallCount: $smallCount, ')
          ..write('mediumCount: $mediumCount, ')
          ..write('largeCount: $largeCount, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    batchId,
    categoryId,
    eggsCollected,
    unusableCount,
    eggsRemaining,
    cratesCollected,
    qualityGrade,
    isSorted,
    smallCount,
    mediumCount,
    largeCount,
    logDate,
    userId,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EggProduction &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.batchId == this.batchId &&
          other.categoryId == this.categoryId &&
          other.eggsCollected == this.eggsCollected &&
          other.unusableCount == this.unusableCount &&
          other.eggsRemaining == this.eggsRemaining &&
          other.cratesCollected == this.cratesCollected &&
          other.qualityGrade == this.qualityGrade &&
          other.isSorted == this.isSorted &&
          other.smallCount == this.smallCount &&
          other.mediumCount == this.mediumCount &&
          other.largeCount == this.largeCount &&
          other.logDate == this.logDate &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class EggProductionsCompanion extends UpdateCompanion<EggProduction> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> batchId;
  final Value<String?> categoryId;
  final Value<int> eggsCollected;
  final Value<int> unusableCount;
  final Value<int> eggsRemaining;
  final Value<double?> cratesCollected;
  final Value<String?> qualityGrade;
  final Value<bool> isSorted;
  final Value<int> smallCount;
  final Value<int> mediumCount;
  final Value<int> largeCount;
  final Value<DateTime> logDate;
  final Value<String?> userId;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const EggProductionsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.eggsCollected = const Value.absent(),
    this.unusableCount = const Value.absent(),
    this.eggsRemaining = const Value.absent(),
    this.cratesCollected = const Value.absent(),
    this.qualityGrade = const Value.absent(),
    this.isSorted = const Value.absent(),
    this.smallCount = const Value.absent(),
    this.mediumCount = const Value.absent(),
    this.largeCount = const Value.absent(),
    this.logDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EggProductionsCompanion.insert({
    required String id,
    required String farmId,
    required String batchId,
    this.categoryId = const Value.absent(),
    required int eggsCollected,
    this.unusableCount = const Value.absent(),
    this.eggsRemaining = const Value.absent(),
    this.cratesCollected = const Value.absent(),
    this.qualityGrade = const Value.absent(),
    this.isSorted = const Value.absent(),
    this.smallCount = const Value.absent(),
    this.mediumCount = const Value.absent(),
    this.largeCount = const Value.absent(),
    required DateTime logDate,
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       batchId = Value(batchId),
       eggsCollected = Value(eggsCollected),
       logDate = Value(logDate);
  static Insertable<EggProduction> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? batchId,
    Expression<String>? categoryId,
    Expression<int>? eggsCollected,
    Expression<int>? unusableCount,
    Expression<int>? eggsRemaining,
    Expression<double>? cratesCollected,
    Expression<String>? qualityGrade,
    Expression<bool>? isSorted,
    Expression<int>? smallCount,
    Expression<int>? mediumCount,
    Expression<int>? largeCount,
    Expression<DateTime>? logDate,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (batchId != null) 'batch_id': batchId,
      if (categoryId != null) 'category_id': categoryId,
      if (eggsCollected != null) 'eggs_collected': eggsCollected,
      if (unusableCount != null) 'unusable_count': unusableCount,
      if (eggsRemaining != null) 'eggs_remaining': eggsRemaining,
      if (cratesCollected != null) 'crates_collected': cratesCollected,
      if (qualityGrade != null) 'quality_grade': qualityGrade,
      if (isSorted != null) 'is_sorted': isSorted,
      if (smallCount != null) 'small_count': smallCount,
      if (mediumCount != null) 'medium_count': mediumCount,
      if (largeCount != null) 'large_count': largeCount,
      if (logDate != null) 'log_date': logDate,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EggProductionsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? batchId,
    Value<String?>? categoryId,
    Value<int>? eggsCollected,
    Value<int>? unusableCount,
    Value<int>? eggsRemaining,
    Value<double?>? cratesCollected,
    Value<String?>? qualityGrade,
    Value<bool>? isSorted,
    Value<int>? smallCount,
    Value<int>? mediumCount,
    Value<int>? largeCount,
    Value<DateTime>? logDate,
    Value<String?>? userId,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return EggProductionsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      batchId: batchId ?? this.batchId,
      categoryId: categoryId ?? this.categoryId,
      eggsCollected: eggsCollected ?? this.eggsCollected,
      unusableCount: unusableCount ?? this.unusableCount,
      eggsRemaining: eggsRemaining ?? this.eggsRemaining,
      cratesCollected: cratesCollected ?? this.cratesCollected,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      isSorted: isSorted ?? this.isSorted,
      smallCount: smallCount ?? this.smallCount,
      mediumCount: mediumCount ?? this.mediumCount,
      largeCount: largeCount ?? this.largeCount,
      logDate: logDate ?? this.logDate,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (eggsCollected.present) {
      map['eggs_collected'] = Variable<int>(eggsCollected.value);
    }
    if (unusableCount.present) {
      map['unusable_count'] = Variable<int>(unusableCount.value);
    }
    if (eggsRemaining.present) {
      map['eggs_remaining'] = Variable<int>(eggsRemaining.value);
    }
    if (cratesCollected.present) {
      map['crates_collected'] = Variable<double>(cratesCollected.value);
    }
    if (qualityGrade.present) {
      map['quality_grade'] = Variable<String>(qualityGrade.value);
    }
    if (isSorted.present) {
      map['is_sorted'] = Variable<bool>(isSorted.value);
    }
    if (smallCount.present) {
      map['small_count'] = Variable<int>(smallCount.value);
    }
    if (mediumCount.present) {
      map['medium_count'] = Variable<int>(mediumCount.value);
    }
    if (largeCount.present) {
      map['large_count'] = Variable<int>(largeCount.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EggProductionsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('categoryId: $categoryId, ')
          ..write('eggsCollected: $eggsCollected, ')
          ..write('unusableCount: $unusableCount, ')
          ..write('eggsRemaining: $eggsRemaining, ')
          ..write('cratesCollected: $cratesCollected, ')
          ..write('qualityGrade: $qualityGrade, ')
          ..write('isSorted: $isSorted, ')
          ..write('smallCount: $smallCount, ')
          ..write('mediumCount: $mediumCount, ')
          ..write('largeCount: $largeCount, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MortalitiesTable extends Mortalities
    with TableInfo<$MortalitiesTable, Mortality> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MortalitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subCategoryMeta = const VerificationMeta(
    'subCategory',
  );
  @override
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
    'sub_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _healthTypeMeta = const VerificationMeta(
    'healthType',
  );
  @override
  late final GeneratedColumn<String> healthType = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DEAD'),
  );
  static const VerificationMeta _isolationRoomIdMeta = const VerificationMeta(
    'isolationRoomId',
  );
  @override
  late final GeneratedColumn<String> isolationRoomId = GeneratedColumn<String>(
    'isolation_room_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    batchId,
    count,
    reason,
    category,
    subCategory,
    healthType,
    isolationRoomId,
    logDate,
    userId,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mortality';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mortality> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('sub_category')) {
      context.handle(
        _subCategoryMeta,
        subCategory.isAcceptableOrUnknown(
          data['sub_category']!,
          _subCategoryMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _healthTypeMeta,
        healthType.isAcceptableOrUnknown(data['type']!, _healthTypeMeta),
      );
    }
    if (data.containsKey('isolation_room_id')) {
      context.handle(
        _isolationRoomIdMeta,
        isolationRoomId.isAcceptableOrUnknown(
          data['isolation_room_id']!,
          _isolationRoomIdMeta,
        ),
      );
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mortality map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mortality(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      subCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_category'],
      ),
      healthType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      isolationRoomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isolation_room_id'],
      ),
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}log_date'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $MortalitiesTable createAlias(String alias) {
    return $MortalitiesTable(attachedDatabase, alias);
  }
}

class Mortality extends DataClass implements Insertable<Mortality> {
  final String id;
  final String farmId;
  final String batchId;
  final int count;
  final String? reason;
  final String? category;
  final String? subCategory;
  final String healthType;
  final String? isolationRoomId;
  final DateTime logDate;
  final String? userId;
  final DateTime createdAt;
  final bool synced;
  const Mortality({
    required this.id,
    required this.farmId,
    required this.batchId,
    required this.count,
    this.reason,
    this.category,
    this.subCategory,
    required this.healthType,
    this.isolationRoomId,
    required this.logDate,
    this.userId,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['batch_id'] = Variable<String>(batchId);
    map['count'] = Variable<int>(count);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || subCategory != null) {
      map['sub_category'] = Variable<String>(subCategory);
    }
    map['type'] = Variable<String>(healthType);
    if (!nullToAbsent || isolationRoomId != null) {
      map['isolation_room_id'] = Variable<String>(isolationRoomId);
    }
    map['log_date'] = Variable<DateTime>(logDate);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  MortalitiesCompanion toCompanion(bool nullToAbsent) {
    return MortalitiesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      batchId: Value(batchId),
      count: Value(count),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      subCategory: subCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subCategory),
      healthType: Value(healthType),
      isolationRoomId: isolationRoomId == null && nullToAbsent
          ? const Value.absent()
          : Value(isolationRoomId),
      logDate: Value(logDate),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory Mortality.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mortality(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      count: serializer.fromJson<int>(json['count']),
      reason: serializer.fromJson<String?>(json['reason']),
      category: serializer.fromJson<String?>(json['category']),
      subCategory: serializer.fromJson<String?>(json['subCategory']),
      healthType: serializer.fromJson<String>(json['healthType']),
      isolationRoomId: serializer.fromJson<String?>(json['isolationRoomId']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      userId: serializer.fromJson<String?>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'batchId': serializer.toJson<String>(batchId),
      'count': serializer.toJson<int>(count),
      'reason': serializer.toJson<String?>(reason),
      'category': serializer.toJson<String?>(category),
      'subCategory': serializer.toJson<String?>(subCategory),
      'healthType': serializer.toJson<String>(healthType),
      'isolationRoomId': serializer.toJson<String?>(isolationRoomId),
      'logDate': serializer.toJson<DateTime>(logDate),
      'userId': serializer.toJson<String?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Mortality copyWith({
    String? id,
    String? farmId,
    String? batchId,
    int? count,
    Value<String?> reason = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> subCategory = const Value.absent(),
    String? healthType,
    Value<String?> isolationRoomId = const Value.absent(),
    DateTime? logDate,
    Value<String?> userId = const Value.absent(),
    DateTime? createdAt,
    bool? synced,
  }) => Mortality(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    batchId: batchId ?? this.batchId,
    count: count ?? this.count,
    reason: reason.present ? reason.value : this.reason,
    category: category.present ? category.value : this.category,
    subCategory: subCategory.present ? subCategory.value : this.subCategory,
    healthType: healthType ?? this.healthType,
    isolationRoomId: isolationRoomId.present
        ? isolationRoomId.value
        : this.isolationRoomId,
    logDate: logDate ?? this.logDate,
    userId: userId.present ? userId.value : this.userId,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  Mortality copyWithCompanion(MortalitiesCompanion data) {
    return Mortality(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      count: data.count.present ? data.count.value : this.count,
      reason: data.reason.present ? data.reason.value : this.reason,
      category: data.category.present ? data.category.value : this.category,
      subCategory: data.subCategory.present
          ? data.subCategory.value
          : this.subCategory,
      healthType: data.healthType.present
          ? data.healthType.value
          : this.healthType,
      isolationRoomId: data.isolationRoomId.present
          ? data.isolationRoomId.value
          : this.isolationRoomId,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mortality(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('count: $count, ')
          ..write('reason: $reason, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('healthType: $healthType, ')
          ..write('isolationRoomId: $isolationRoomId, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    batchId,
    count,
    reason,
    category,
    subCategory,
    healthType,
    isolationRoomId,
    logDate,
    userId,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mortality &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.batchId == this.batchId &&
          other.count == this.count &&
          other.reason == this.reason &&
          other.category == this.category &&
          other.subCategory == this.subCategory &&
          other.healthType == this.healthType &&
          other.isolationRoomId == this.isolationRoomId &&
          other.logDate == this.logDate &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class MortalitiesCompanion extends UpdateCompanion<Mortality> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> batchId;
  final Value<int> count;
  final Value<String?> reason;
  final Value<String?> category;
  final Value<String?> subCategory;
  final Value<String> healthType;
  final Value<String?> isolationRoomId;
  final Value<DateTime> logDate;
  final Value<String?> userId;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const MortalitiesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.count = const Value.absent(),
    this.reason = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.healthType = const Value.absent(),
    this.isolationRoomId = const Value.absent(),
    this.logDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MortalitiesCompanion.insert({
    required String id,
    required String farmId,
    required String batchId,
    required int count,
    this.reason = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.healthType = const Value.absent(),
    this.isolationRoomId = const Value.absent(),
    required DateTime logDate,
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       batchId = Value(batchId),
       count = Value(count),
       logDate = Value(logDate);
  static Insertable<Mortality> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? batchId,
    Expression<int>? count,
    Expression<String>? reason,
    Expression<String>? category,
    Expression<String>? subCategory,
    Expression<String>? healthType,
    Expression<String>? isolationRoomId,
    Expression<DateTime>? logDate,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (batchId != null) 'batch_id': batchId,
      if (count != null) 'count': count,
      if (reason != null) 'reason': reason,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (healthType != null) 'type': healthType,
      if (isolationRoomId != null) 'isolation_room_id': isolationRoomId,
      if (logDate != null) 'log_date': logDate,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MortalitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? batchId,
    Value<int>? count,
    Value<String?>? reason,
    Value<String?>? category,
    Value<String?>? subCategory,
    Value<String>? healthType,
    Value<String?>? isolationRoomId,
    Value<DateTime>? logDate,
    Value<String?>? userId,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return MortalitiesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      batchId: batchId ?? this.batchId,
      count: count ?? this.count,
      reason: reason ?? this.reason,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      healthType: healthType ?? this.healthType,
      isolationRoomId: isolationRoomId ?? this.isolationRoomId,
      logDate: logDate ?? this.logDate,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subCategory.present) {
      map['sub_category'] = Variable<String>(subCategory.value);
    }
    if (healthType.present) {
      map['type'] = Variable<String>(healthType.value);
    }
    if (isolationRoomId.present) {
      map['isolation_room_id'] = Variable<String>(isolationRoomId.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MortalitiesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('count: $count, ')
          ..write('reason: $reason, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('healthType: $healthType, ')
          ..write('isolationRoomId: $isolationRoomId, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HousesTable extends Houses with TableInfo<$HousesTable, House> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HousesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentTemperatureMeta =
      const VerificationMeta('currentTemperature');
  @override
  late final GeneratedColumn<double> currentTemperature =
      GeneratedColumn<double>(
        'current_temperature',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currentHumidityMeta = const VerificationMeta(
    'currentHumidity',
  );
  @override
  late final GeneratedColumn<double> currentHumidity = GeneratedColumn<double>(
    'current_humidity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isIsolationMeta = const VerificationMeta(
    'isIsolation',
  );
  @override
  late final GeneratedColumn<bool> isIsolation = GeneratedColumn<bool>(
    'is_isolation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_isolation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    userId,
    name,
    capacity,
    currentTemperature,
    currentHumidity,
    isIsolation,
    createdAt,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'houses';
  @override
  VerificationContext validateIntegrity(
    Insertable<House> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    } else if (isInserting) {
      context.missing(_capacityMeta);
    }
    if (data.containsKey('current_temperature')) {
      context.handle(
        _currentTemperatureMeta,
        currentTemperature.isAcceptableOrUnknown(
          data['current_temperature']!,
          _currentTemperatureMeta,
        ),
      );
    }
    if (data.containsKey('current_humidity')) {
      context.handle(
        _currentHumidityMeta,
        currentHumidity.isAcceptableOrUnknown(
          data['current_humidity']!,
          _currentHumidityMeta,
        ),
      );
    }
    if (data.containsKey('is_isolation')) {
      context.handle(
        _isIsolationMeta,
        isIsolation.isAcceptableOrUnknown(
          data['is_isolation']!,
          _isIsolationMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  House map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return House(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      )!,
      currentTemperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_temperature'],
      ),
      currentHumidity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_humidity'],
      ),
      isIsolation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_isolation'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $HousesTable createAlias(String alias) {
    return $HousesTable(attachedDatabase, alias);
  }
}

class House extends DataClass implements Insertable<House> {
  final String id;
  final String farmId;
  final String? userId;
  final String name;
  final int capacity;
  final double? currentTemperature;
  final double? currentHumidity;
  final bool isIsolation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const House({
    required this.id,
    required this.farmId,
    this.userId,
    required this.name,
    required this.capacity,
    this.currentTemperature,
    this.currentHumidity,
    required this.isIsolation,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['name'] = Variable<String>(name);
    map['capacity'] = Variable<int>(capacity);
    if (!nullToAbsent || currentTemperature != null) {
      map['current_temperature'] = Variable<double>(currentTemperature);
    }
    if (!nullToAbsent || currentHumidity != null) {
      map['current_humidity'] = Variable<double>(currentHumidity);
    }
    map['is_isolation'] = Variable<bool>(isIsolation);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  HousesCompanion toCompanion(bool nullToAbsent) {
    return HousesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      name: Value(name),
      capacity: Value(capacity),
      currentTemperature: currentTemperature == null && nullToAbsent
          ? const Value.absent()
          : Value(currentTemperature),
      currentHumidity: currentHumidity == null && nullToAbsent
          ? const Value.absent()
          : Value(currentHumidity),
      isIsolation: Value(isIsolation),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory House.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return House(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      userId: serializer.fromJson<String?>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      capacity: serializer.fromJson<int>(json['capacity']),
      currentTemperature: serializer.fromJson<double?>(
        json['currentTemperature'],
      ),
      currentHumidity: serializer.fromJson<double?>(json['currentHumidity']),
      isIsolation: serializer.fromJson<bool>(json['isIsolation']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'userId': serializer.toJson<String?>(userId),
      'name': serializer.toJson<String>(name),
      'capacity': serializer.toJson<int>(capacity),
      'currentTemperature': serializer.toJson<double?>(currentTemperature),
      'currentHumidity': serializer.toJson<double?>(currentHumidity),
      'isIsolation': serializer.toJson<bool>(isIsolation),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  House copyWith({
    String? id,
    String? farmId,
    Value<String?> userId = const Value.absent(),
    String? name,
    int? capacity,
    Value<double?> currentTemperature = const Value.absent(),
    Value<double?> currentHumidity = const Value.absent(),
    bool? isIsolation,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) => House(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    userId: userId.present ? userId.value : this.userId,
    name: name ?? this.name,
    capacity: capacity ?? this.capacity,
    currentTemperature: currentTemperature.present
        ? currentTemperature.value
        : this.currentTemperature,
    currentHumidity: currentHumidity.present
        ? currentHumidity.value
        : this.currentHumidity,
    isIsolation: isIsolation ?? this.isIsolation,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  House copyWithCompanion(HousesCompanion data) {
    return House(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      currentTemperature: data.currentTemperature.present
          ? data.currentTemperature.value
          : this.currentTemperature,
      currentHumidity: data.currentHumidity.present
          ? data.currentHumidity.value
          : this.currentHumidity,
      isIsolation: data.isIsolation.present
          ? data.isIsolation.value
          : this.isIsolation,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('House(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('currentTemperature: $currentTemperature, ')
          ..write('currentHumidity: $currentHumidity, ')
          ..write('isIsolation: $isIsolation, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    userId,
    name,
    capacity,
    currentTemperature,
    currentHumidity,
    isIsolation,
    createdAt,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is House &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.capacity == this.capacity &&
          other.currentTemperature == this.currentTemperature &&
          other.currentHumidity == this.currentHumidity &&
          other.isIsolation == this.isIsolation &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class HousesCompanion extends UpdateCompanion<House> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String?> userId;
  final Value<String> name;
  final Value<int> capacity;
  final Value<double?> currentTemperature;
  final Value<double?> currentHumidity;
  final Value<bool> isIsolation;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const HousesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.capacity = const Value.absent(),
    this.currentTemperature = const Value.absent(),
    this.currentHumidity = const Value.absent(),
    this.isIsolation = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HousesCompanion.insert({
    required String id,
    required String farmId,
    this.userId = const Value.absent(),
    required String name,
    required int capacity,
    this.currentTemperature = const Value.absent(),
    this.currentHumidity = const Value.absent(),
    this.isIsolation = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       name = Value(name),
       capacity = Value(capacity);
  static Insertable<House> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<int>? capacity,
    Expression<double>? currentTemperature,
    Expression<double>? currentHumidity,
    Expression<bool>? isIsolation,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (capacity != null) 'capacity': capacity,
      if (currentTemperature != null) 'current_temperature': currentTemperature,
      if (currentHumidity != null) 'current_humidity': currentHumidity,
      if (isIsolation != null) 'is_isolation': isIsolation,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HousesCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String?>? userId,
    Value<String>? name,
    Value<int>? capacity,
    Value<double?>? currentTemperature,
    Value<double?>? currentHumidity,
    Value<bool>? isIsolation,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return HousesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      currentHumidity: currentHumidity ?? this.currentHumidity,
      isIsolation: isIsolation ?? this.isIsolation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (currentTemperature.present) {
      map['current_temperature'] = Variable<double>(currentTemperature.value);
    }
    if (currentHumidity.present) {
      map['current_humidity'] = Variable<double>(currentHumidity.value);
    }
    if (isIsolation.present) {
      map['is_isolation'] = Variable<bool>(isIsolation.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HousesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('currentTemperature: $currentTemperature, ')
          ..write('currentHumidity: $currentHumidity, ')
          ..write('isIsolation: $isIsolation, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceOwedMeta = const VerificationMeta(
    'balanceOwed',
  );
  @override
  late final GeneratedColumn<double> balanceOwed = GeneratedColumn<double>(
    'balance_owed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
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
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _customerTypeMeta = const VerificationMeta(
    'customerType',
  );
  @override
  late final GeneratedColumn<String> customerType = GeneratedColumn<String>(
    'customer_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CUSTOMER'),
  );
  static const VerificationMeta _supplyItemsMeta = const VerificationMeta(
    'supplyItems',
  );
  @override
  late final GeneratedColumn<String> supplyItems = GeneratedColumn<String>(
    'supply_items',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactPersonMeta = const VerificationMeta(
    'contactPerson',
  );
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
    'contact_person',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    name,
    phone,
    email,
    address,
    balanceOwed,
    createdAt,
    updatedAt,
    customerType,
    supplyItems,
    contactPerson,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
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
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('balance_owed')) {
      context.handle(
        _balanceOwedMeta,
        balanceOwed.isAcceptableOrUnknown(
          data['balance_owed']!,
          _balanceOwedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('customer_type')) {
      context.handle(
        _customerTypeMeta,
        customerType.isAcceptableOrUnknown(
          data['customer_type']!,
          _customerTypeMeta,
        ),
      );
    }
    if (data.containsKey('supply_items')) {
      context.handle(
        _supplyItemsMeta,
        supplyItems.isAcceptableOrUnknown(
          data['supply_items']!,
          _supplyItemsMeta,
        ),
      );
    }
    if (data.containsKey('contact_person')) {
      context.handle(
        _contactPersonMeta,
        contactPerson.isAcceptableOrUnknown(
          data['contact_person']!,
          _contactPersonMeta,
        ),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      balanceOwed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance_owed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      customerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_type'],
      )!,
      supplyItems: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supply_items'],
      ),
      contactPerson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_person'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String farmId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double balanceOwed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String customerType;
  final String? supplyItems;
  final String? contactPerson;
  final bool synced;
  const Customer({
    required this.id,
    required this.farmId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.balanceOwed,
    required this.createdAt,
    required this.updatedAt,
    required this.customerType,
    this.supplyItems,
    this.contactPerson,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['balance_owed'] = Variable<double>(balanceOwed);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['customer_type'] = Variable<String>(customerType);
    if (!nullToAbsent || supplyItems != null) {
      map['supply_items'] = Variable<String>(supplyItems);
    }
    if (!nullToAbsent || contactPerson != null) {
      map['contact_person'] = Variable<String>(contactPerson);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      farmId: Value(farmId),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      balanceOwed: Value(balanceOwed),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      customerType: Value(customerType),
      supplyItems: supplyItems == null && nullToAbsent
          ? const Value.absent()
          : Value(supplyItems),
      contactPerson: contactPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPerson),
      synced: Value(synced),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      balanceOwed: serializer.fromJson<double>(json['balanceOwed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      customerType: serializer.fromJson<String>(json['customerType']),
      supplyItems: serializer.fromJson<String?>(json['supplyItems']),
      contactPerson: serializer.fromJson<String?>(json['contactPerson']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'balanceOwed': serializer.toJson<double>(balanceOwed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'customerType': serializer.toJson<String>(customerType),
      'supplyItems': serializer.toJson<String?>(supplyItems),
      'contactPerson': serializer.toJson<String?>(contactPerson),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Customer copyWith({
    String? id,
    String? farmId,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    double? balanceOwed,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerType,
    Value<String?> supplyItems = const Value.absent(),
    Value<String?> contactPerson = const Value.absent(),
    bool? synced,
  }) => Customer(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    balanceOwed: balanceOwed ?? this.balanceOwed,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    customerType: customerType ?? this.customerType,
    supplyItems: supplyItems.present ? supplyItems.value : this.supplyItems,
    contactPerson: contactPerson.present
        ? contactPerson.value
        : this.contactPerson,
    synced: synced ?? this.synced,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      balanceOwed: data.balanceOwed.present
          ? data.balanceOwed.value
          : this.balanceOwed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      customerType: data.customerType.present
          ? data.customerType.value
          : this.customerType,
      supplyItems: data.supplyItems.present
          ? data.supplyItems.value
          : this.supplyItems,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('balanceOwed: $balanceOwed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('customerType: $customerType, ')
          ..write('supplyItems: $supplyItems, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    name,
    phone,
    email,
    address,
    balanceOwed,
    createdAt,
    updatedAt,
    customerType,
    supplyItems,
    contactPerson,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.balanceOwed == this.balanceOwed &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.customerType == this.customerType &&
          other.supplyItems == this.supplyItems &&
          other.contactPerson == this.contactPerson &&
          other.synced == this.synced);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<double> balanceOwed;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> customerType;
  final Value<String?> supplyItems;
  final Value<String?> contactPerson;
  final Value<bool> synced;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.balanceOwed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.customerType = const Value.absent(),
    this.supplyItems = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String farmId,
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.balanceOwed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.customerType = const Value.absent(),
    this.supplyItems = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       name = Value(name);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<double>? balanceOwed,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? customerType,
    Expression<String>? supplyItems,
    Expression<String>? contactPerson,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (balanceOwed != null) 'balance_owed': balanceOwed,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (customerType != null) 'customer_type': customerType,
      if (supplyItems != null) 'supply_items': supplyItems,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? address,
    Value<double>? balanceOwed,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? customerType,
    Value<String?>? supplyItems,
    Value<String?>? contactPerson,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      balanceOwed: balanceOwed ?? this.balanceOwed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerType: customerType ?? this.customerType,
      supplyItems: supplyItems ?? this.supplyItems,
      contactPerson: contactPerson ?? this.contactPerson,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (balanceOwed.present) {
      map['balance_owed'] = Variable<double>(balanceOwed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (customerType.present) {
      map['customer_type'] = Variable<String>(customerType.value);
    }
    if (supplyItems.present) {
      map['supply_items'] = Variable<String>(supplyItems.value);
    }
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('balanceOwed: $balanceOwed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('customerType: $customerType, ')
          ..write('supplyItems: $supplyItems, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmSettingsTable extends FarmSettings
    with TableInfo<$FarmSettingsTable, FarmSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GHS'),
  );
  static const VerificationMeta _eggRecordReminderTimeMeta =
      const VerificationMeta('eggRecordReminderTime');
  @override
  late final GeneratedColumn<String> eggRecordReminderTime =
      GeneratedColumn<String>(
        'egg_record_reminder_time',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _feedRecordReminderTimeMeta =
      const VerificationMeta('feedRecordReminderTime');
  @override
  late final GeneratedColumn<String> feedRecordReminderTime =
      GeneratedColumn<String>(
        'feed_record_reminder_time',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _growthTargetStandardMeta =
      const VerificationMeta('growthTargetStandard');
  @override
  late final GeneratedColumn<int> growthTargetStandard = GeneratedColumn<int>(
    'growth_target_standard',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eggsPerCrateMeta = const VerificationMeta(
    'eggsPerCrate',
  );
  @override
  late final GeneratedColumn<int> eggsPerCrate = GeneratedColumn<int>(
    'eggs_per_crate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    currency,
    eggRecordReminderTime,
    feedRecordReminderTime,
    growthTargetStandard,
    eggsPerCrate,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<FarmSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('egg_record_reminder_time')) {
      context.handle(
        _eggRecordReminderTimeMeta,
        eggRecordReminderTime.isAcceptableOrUnknown(
          data['egg_record_reminder_time']!,
          _eggRecordReminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('feed_record_reminder_time')) {
      context.handle(
        _feedRecordReminderTimeMeta,
        feedRecordReminderTime.isAcceptableOrUnknown(
          data['feed_record_reminder_time']!,
          _feedRecordReminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('growth_target_standard')) {
      context.handle(
        _growthTargetStandardMeta,
        growthTargetStandard.isAcceptableOrUnknown(
          data['growth_target_standard']!,
          _growthTargetStandardMeta,
        ),
      );
    }
    if (data.containsKey('eggs_per_crate')) {
      context.handle(
        _eggsPerCrateMeta,
        eggsPerCrate.isAcceptableOrUnknown(
          data['eggs_per_crate']!,
          _eggsPerCrateMeta,
        ),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      eggRecordReminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}egg_record_reminder_time'],
      ),
      feedRecordReminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_record_reminder_time'],
      ),
      growthTargetStandard: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}growth_target_standard'],
      ),
      eggsPerCrate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eggs_per_crate'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $FarmSettingsTable createAlias(String alias) {
    return $FarmSettingsTable(attachedDatabase, alias);
  }
}

class FarmSetting extends DataClass implements Insertable<FarmSetting> {
  final String id;
  final String farmId;
  final String currency;
  final String? eggRecordReminderTime;
  final String? feedRecordReminderTime;
  final int? growthTargetStandard;
  final int eggsPerCrate;
  final bool synced;
  const FarmSetting({
    required this.id,
    required this.farmId,
    required this.currency,
    this.eggRecordReminderTime,
    this.feedRecordReminderTime,
    this.growthTargetStandard,
    required this.eggsPerCrate,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || eggRecordReminderTime != null) {
      map['egg_record_reminder_time'] = Variable<String>(eggRecordReminderTime);
    }
    if (!nullToAbsent || feedRecordReminderTime != null) {
      map['feed_record_reminder_time'] = Variable<String>(
        feedRecordReminderTime,
      );
    }
    if (!nullToAbsent || growthTargetStandard != null) {
      map['growth_target_standard'] = Variable<int>(growthTargetStandard);
    }
    map['eggs_per_crate'] = Variable<int>(eggsPerCrate);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  FarmSettingsCompanion toCompanion(bool nullToAbsent) {
    return FarmSettingsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      currency: Value(currency),
      eggRecordReminderTime: eggRecordReminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(eggRecordReminderTime),
      feedRecordReminderTime: feedRecordReminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(feedRecordReminderTime),
      growthTargetStandard: growthTargetStandard == null && nullToAbsent
          ? const Value.absent()
          : Value(growthTargetStandard),
      eggsPerCrate: Value(eggsPerCrate),
      synced: Value(synced),
    );
  }

  factory FarmSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmSetting(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      currency: serializer.fromJson<String>(json['currency']),
      eggRecordReminderTime: serializer.fromJson<String?>(
        json['eggRecordReminderTime'],
      ),
      feedRecordReminderTime: serializer.fromJson<String?>(
        json['feedRecordReminderTime'],
      ),
      growthTargetStandard: serializer.fromJson<int?>(
        json['growthTargetStandard'],
      ),
      eggsPerCrate: serializer.fromJson<int>(json['eggsPerCrate']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'currency': serializer.toJson<String>(currency),
      'eggRecordReminderTime': serializer.toJson<String?>(
        eggRecordReminderTime,
      ),
      'feedRecordReminderTime': serializer.toJson<String?>(
        feedRecordReminderTime,
      ),
      'growthTargetStandard': serializer.toJson<int?>(growthTargetStandard),
      'eggsPerCrate': serializer.toJson<int>(eggsPerCrate),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  FarmSetting copyWith({
    String? id,
    String? farmId,
    String? currency,
    Value<String?> eggRecordReminderTime = const Value.absent(),
    Value<String?> feedRecordReminderTime = const Value.absent(),
    Value<int?> growthTargetStandard = const Value.absent(),
    int? eggsPerCrate,
    bool? synced,
  }) => FarmSetting(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    currency: currency ?? this.currency,
    eggRecordReminderTime: eggRecordReminderTime.present
        ? eggRecordReminderTime.value
        : this.eggRecordReminderTime,
    feedRecordReminderTime: feedRecordReminderTime.present
        ? feedRecordReminderTime.value
        : this.feedRecordReminderTime,
    growthTargetStandard: growthTargetStandard.present
        ? growthTargetStandard.value
        : this.growthTargetStandard,
    eggsPerCrate: eggsPerCrate ?? this.eggsPerCrate,
    synced: synced ?? this.synced,
  );
  FarmSetting copyWithCompanion(FarmSettingsCompanion data) {
    return FarmSetting(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      currency: data.currency.present ? data.currency.value : this.currency,
      eggRecordReminderTime: data.eggRecordReminderTime.present
          ? data.eggRecordReminderTime.value
          : this.eggRecordReminderTime,
      feedRecordReminderTime: data.feedRecordReminderTime.present
          ? data.feedRecordReminderTime.value
          : this.feedRecordReminderTime,
      growthTargetStandard: data.growthTargetStandard.present
          ? data.growthTargetStandard.value
          : this.growthTargetStandard,
      eggsPerCrate: data.eggsPerCrate.present
          ? data.eggsPerCrate.value
          : this.eggsPerCrate,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmSetting(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('currency: $currency, ')
          ..write('eggRecordReminderTime: $eggRecordReminderTime, ')
          ..write('feedRecordReminderTime: $feedRecordReminderTime, ')
          ..write('growthTargetStandard: $growthTargetStandard, ')
          ..write('eggsPerCrate: $eggsPerCrate, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    currency,
    eggRecordReminderTime,
    feedRecordReminderTime,
    growthTargetStandard,
    eggsPerCrate,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmSetting &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.currency == this.currency &&
          other.eggRecordReminderTime == this.eggRecordReminderTime &&
          other.feedRecordReminderTime == this.feedRecordReminderTime &&
          other.growthTargetStandard == this.growthTargetStandard &&
          other.eggsPerCrate == this.eggsPerCrate &&
          other.synced == this.synced);
}

class FarmSettingsCompanion extends UpdateCompanion<FarmSetting> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> currency;
  final Value<String?> eggRecordReminderTime;
  final Value<String?> feedRecordReminderTime;
  final Value<int?> growthTargetStandard;
  final Value<int> eggsPerCrate;
  final Value<bool> synced;
  final Value<int> rowid;
  const FarmSettingsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.currency = const Value.absent(),
    this.eggRecordReminderTime = const Value.absent(),
    this.feedRecordReminderTime = const Value.absent(),
    this.growthTargetStandard = const Value.absent(),
    this.eggsPerCrate = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmSettingsCompanion.insert({
    required String id,
    required String farmId,
    this.currency = const Value.absent(),
    this.eggRecordReminderTime = const Value.absent(),
    this.feedRecordReminderTime = const Value.absent(),
    this.growthTargetStandard = const Value.absent(),
    this.eggsPerCrate = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId);
  static Insertable<FarmSetting> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? currency,
    Expression<String>? eggRecordReminderTime,
    Expression<String>? feedRecordReminderTime,
    Expression<int>? growthTargetStandard,
    Expression<int>? eggsPerCrate,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (currency != null) 'currency': currency,
      if (eggRecordReminderTime != null)
        'egg_record_reminder_time': eggRecordReminderTime,
      if (feedRecordReminderTime != null)
        'feed_record_reminder_time': feedRecordReminderTime,
      if (growthTargetStandard != null)
        'growth_target_standard': growthTargetStandard,
      if (eggsPerCrate != null) 'eggs_per_crate': eggsPerCrate,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? currency,
    Value<String?>? eggRecordReminderTime,
    Value<String?>? feedRecordReminderTime,
    Value<int?>? growthTargetStandard,
    Value<int>? eggsPerCrate,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return FarmSettingsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      currency: currency ?? this.currency,
      eggRecordReminderTime:
          eggRecordReminderTime ?? this.eggRecordReminderTime,
      feedRecordReminderTime:
          feedRecordReminderTime ?? this.feedRecordReminderTime,
      growthTargetStandard: growthTargetStandard ?? this.growthTargetStandard,
      eggsPerCrate: eggsPerCrate ?? this.eggsPerCrate,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (eggRecordReminderTime.present) {
      map['egg_record_reminder_time'] = Variable<String>(
        eggRecordReminderTime.value,
      );
    }
    if (feedRecordReminderTime.present) {
      map['feed_record_reminder_time'] = Variable<String>(
        feedRecordReminderTime.value,
      );
    }
    if (growthTargetStandard.present) {
      map['growth_target_standard'] = Variable<int>(growthTargetStandard.value);
    }
    if (eggsPerCrate.present) {
      map['eggs_per_crate'] = Variable<int>(eggsPerCrate.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmSettingsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('currency: $currency, ')
          ..write('eggRecordReminderTime: $eggRecordReminderTime, ')
          ..write('feedRecordReminderTime: $feedRecordReminderTime, ')
          ..write('growthTargetStandard: $growthTargetStandard, ')
          ..write('eggsPerCrate: $eggsPerCrate, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightRecordsTable extends WeightRecords
    with TableInfo<$WeightRecordsTable, WeightRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageWeightMeta = const VerificationMeta(
    'averageWeight',
  );
  @override
  late final GeneratedColumn<double> averageWeight = GeneratedColumn<double>(
    'average_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    batchId,
    averageWeight,
    logDate,
    userId,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('average_weight')) {
      context.handle(
        _averageWeightMeta,
        averageWeight.isAcceptableOrUnknown(
          data['average_weight']!,
          _averageWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageWeightMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      averageWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_weight'],
      )!,
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}log_date'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $WeightRecordsTable createAlias(String alias) {
    return $WeightRecordsTable(attachedDatabase, alias);
  }
}

class WeightRecord extends DataClass implements Insertable<WeightRecord> {
  final String id;
  final String farmId;
  final String batchId;
  final double averageWeight;
  final DateTime logDate;
  final String? userId;
  final DateTime createdAt;
  final bool synced;
  const WeightRecord({
    required this.id,
    required this.farmId,
    required this.batchId,
    required this.averageWeight,
    required this.logDate,
    this.userId,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['batch_id'] = Variable<String>(batchId);
    map['average_weight'] = Variable<double>(averageWeight);
    map['log_date'] = Variable<DateTime>(logDate);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  WeightRecordsCompanion toCompanion(bool nullToAbsent) {
    return WeightRecordsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      batchId: Value(batchId),
      averageWeight: Value(averageWeight),
      logDate: Value(logDate),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory WeightRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightRecord(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      averageWeight: serializer.fromJson<double>(json['averageWeight']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      userId: serializer.fromJson<String?>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'batchId': serializer.toJson<String>(batchId),
      'averageWeight': serializer.toJson<double>(averageWeight),
      'logDate': serializer.toJson<DateTime>(logDate),
      'userId': serializer.toJson<String?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  WeightRecord copyWith({
    String? id,
    String? farmId,
    String? batchId,
    double? averageWeight,
    DateTime? logDate,
    Value<String?> userId = const Value.absent(),
    DateTime? createdAt,
    bool? synced,
  }) => WeightRecord(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    batchId: batchId ?? this.batchId,
    averageWeight: averageWeight ?? this.averageWeight,
    logDate: logDate ?? this.logDate,
    userId: userId.present ? userId.value : this.userId,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  WeightRecord copyWithCompanion(WeightRecordsCompanion data) {
    return WeightRecord(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      averageWeight: data.averageWeight.present
          ? data.averageWeight.value
          : this.averageWeight,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightRecord(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('averageWeight: $averageWeight, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    batchId,
    averageWeight,
    logDate,
    userId,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightRecord &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.batchId == this.batchId &&
          other.averageWeight == this.averageWeight &&
          other.logDate == this.logDate &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class WeightRecordsCompanion extends UpdateCompanion<WeightRecord> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> batchId;
  final Value<double> averageWeight;
  final Value<DateTime> logDate;
  final Value<String?> userId;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const WeightRecordsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.averageWeight = const Value.absent(),
    this.logDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightRecordsCompanion.insert({
    required String id,
    required String farmId,
    required String batchId,
    required double averageWeight,
    required DateTime logDate,
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       batchId = Value(batchId),
       averageWeight = Value(averageWeight),
       logDate = Value(logDate);
  static Insertable<WeightRecord> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? batchId,
    Expression<double>? averageWeight,
    Expression<DateTime>? logDate,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (batchId != null) 'batch_id': batchId,
      if (averageWeight != null) 'average_weight': averageWeight,
      if (logDate != null) 'log_date': logDate,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? batchId,
    Value<double>? averageWeight,
    Value<DateTime>? logDate,
    Value<String?>? userId,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return WeightRecordsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      batchId: batchId ?? this.batchId,
      averageWeight: averageWeight ?? this.averageWeight,
      logDate: logDate ?? this.logDate,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (averageWeight.present) {
      map['average_weight'] = Variable<double>(averageWeight.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightRecordsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('averageWeight: $averageWeight, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceRegistrationsTable extends DeviceRegistrations
    with TableInfo<$DeviceRegistrationsTable, DeviceRegistration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceRegistrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdentifierMeta = const VerificationMeta(
    'deviceIdentifier',
  );
  @override
  late final GeneratedColumn<String> deviceIdentifier = GeneratedColumn<String>(
    'device_identifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registeredAtMeta = const VerificationMeta(
    'registeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> registeredAt = GeneratedColumn<DateTime>(
    'registered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    userId,
    deviceIdentifier,
    deviceName,
    registeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_registrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceRegistration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('device_identifier')) {
      context.handle(
        _deviceIdentifierMeta,
        deviceIdentifier.isAcceptableOrUnknown(
          data['device_identifier']!,
          _deviceIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceIdentifierMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    }
    if (data.containsKey('registered_at')) {
      context.handle(
        _registeredAtMeta,
        registeredAt.isAcceptableOrUnknown(
          data['registered_at']!,
          _registeredAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceRegistration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceRegistration(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      deviceIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_identifier'],
      )!,
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      ),
      registeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}registered_at'],
      )!,
    );
  }

  @override
  $DeviceRegistrationsTable createAlias(String alias) {
    return $DeviceRegistrationsTable(attachedDatabase, alias);
  }
}

class DeviceRegistration extends DataClass
    implements Insertable<DeviceRegistration> {
  final String id;
  final String farmId;
  final String userId;
  final String deviceIdentifier;
  final String? deviceName;
  final DateTime registeredAt;
  const DeviceRegistration({
    required this.id,
    required this.farmId,
    required this.userId,
    required this.deviceIdentifier,
    this.deviceName,
    required this.registeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['user_id'] = Variable<String>(userId);
    map['device_identifier'] = Variable<String>(deviceIdentifier);
    if (!nullToAbsent || deviceName != null) {
      map['device_name'] = Variable<String>(deviceName);
    }
    map['registered_at'] = Variable<DateTime>(registeredAt);
    return map;
  }

  DeviceRegistrationsCompanion toCompanion(bool nullToAbsent) {
    return DeviceRegistrationsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      userId: Value(userId),
      deviceIdentifier: Value(deviceIdentifier),
      deviceName: deviceName == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceName),
      registeredAt: Value(registeredAt),
    );
  }

  factory DeviceRegistration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceRegistration(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      userId: serializer.fromJson<String>(json['userId']),
      deviceIdentifier: serializer.fromJson<String>(json['deviceIdentifier']),
      deviceName: serializer.fromJson<String?>(json['deviceName']),
      registeredAt: serializer.fromJson<DateTime>(json['registeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'userId': serializer.toJson<String>(userId),
      'deviceIdentifier': serializer.toJson<String>(deviceIdentifier),
      'deviceName': serializer.toJson<String?>(deviceName),
      'registeredAt': serializer.toJson<DateTime>(registeredAt),
    };
  }

  DeviceRegistration copyWith({
    String? id,
    String? farmId,
    String? userId,
    String? deviceIdentifier,
    Value<String?> deviceName = const Value.absent(),
    DateTime? registeredAt,
  }) => DeviceRegistration(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    userId: userId ?? this.userId,
    deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
    deviceName: deviceName.present ? deviceName.value : this.deviceName,
    registeredAt: registeredAt ?? this.registeredAt,
  );
  DeviceRegistration copyWithCompanion(DeviceRegistrationsCompanion data) {
    return DeviceRegistration(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceIdentifier: data.deviceIdentifier.present
          ? data.deviceIdentifier.value
          : this.deviceIdentifier,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      registeredAt: data.registeredAt.present
          ? data.registeredAt.value
          : this.registeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceRegistration(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('deviceIdentifier: $deviceIdentifier, ')
          ..write('deviceName: $deviceName, ')
          ..write('registeredAt: $registeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    userId,
    deviceIdentifier,
    deviceName,
    registeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceRegistration &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.userId == this.userId &&
          other.deviceIdentifier == this.deviceIdentifier &&
          other.deviceName == this.deviceName &&
          other.registeredAt == this.registeredAt);
}

class DeviceRegistrationsCompanion extends UpdateCompanion<DeviceRegistration> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> userId;
  final Value<String> deviceIdentifier;
  final Value<String?> deviceName;
  final Value<DateTime> registeredAt;
  final Value<int> rowid;
  const DeviceRegistrationsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceIdentifier = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.registeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceRegistrationsCompanion.insert({
    required String id,
    required String farmId,
    required String userId,
    required String deviceIdentifier,
    this.deviceName = const Value.absent(),
    this.registeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       userId = Value(userId),
       deviceIdentifier = Value(deviceIdentifier);
  static Insertable<DeviceRegistration> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? userId,
    Expression<String>? deviceIdentifier,
    Expression<String>? deviceName,
    Expression<DateTime>? registeredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (deviceIdentifier != null) 'device_identifier': deviceIdentifier,
      if (deviceName != null) 'device_name': deviceName,
      if (registeredAt != null) 'registered_at': registeredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceRegistrationsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? userId,
    Value<String>? deviceIdentifier,
    Value<String?>? deviceName,
    Value<DateTime>? registeredAt,
    Value<int>? rowid,
  }) {
    return DeviceRegistrationsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      userId: userId ?? this.userId,
      deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
      deviceName: deviceName ?? this.deviceName,
      registeredAt: registeredAt ?? this.registeredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceIdentifier.present) {
      map['device_identifier'] = Variable<String>(deviceIdentifier.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (registeredAt.present) {
      map['registered_at'] = Variable<DateTime>(registeredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceRegistrationsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('deviceIdentifier: $deviceIdentifier, ')
          ..write('deviceName: $deviceName, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmMembersTable extends FarmMembers
    with TableInfo<$FarmMembersTable, FarmMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('WORKER'),
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    userId,
    role,
    joinedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<FarmMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $FarmMembersTable createAlias(String alias) {
    return $FarmMembersTable(attachedDatabase, alias);
  }
}

class FarmMember extends DataClass implements Insertable<FarmMember> {
  final String id;
  final String farmId;
  final String userId;
  final String role;
  final DateTime joinedAt;
  final bool synced;
  const FarmMember({
    required this.id,
    required this.farmId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  FarmMembersCompanion toCompanion(bool nullToAbsent) {
    return FarmMembersCompanion(
      id: Value(id),
      farmId: Value(farmId),
      userId: Value(userId),
      role: Value(role),
      joinedAt: Value(joinedAt),
      synced: Value(synced),
    );
  }

  factory FarmMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmMember(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  FarmMember copyWith({
    String? id,
    String? farmId,
    String? userId,
    String? role,
    DateTime? joinedAt,
    bool? synced,
  }) => FarmMember(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    joinedAt: joinedAt ?? this.joinedAt,
    synced: synced ?? this.synced,
  );
  FarmMember copyWithCompanion(FarmMembersCompanion data) {
    return FarmMember(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmMember(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, farmId, userId, role, joinedAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmMember &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.joinedAt == this.joinedAt &&
          other.synced == this.synced);
}

class FarmMembersCompanion extends UpdateCompanion<FarmMember> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> userId;
  final Value<String> role;
  final Value<DateTime> joinedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const FarmMembersCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmMembersCompanion.insert({
    required String id,
    required String farmId,
    required String userId,
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       userId = Value(userId);
  static Insertable<FarmMember> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<DateTime>? joinedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? userId,
    Value<String>? role,
    Value<DateTime>? joinedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return FarmMembersCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmMembersCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CloudUserIdMappingsTable extends CloudUserIdMappings
    with TableInfo<$CloudUserIdMappingsTable, CloudUserIdMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CloudUserIdMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localUserIdMeta = const VerificationMeta(
    'localUserId',
  );
  @override
  late final GeneratedColumn<String> localUserId = GeneratedColumn<String>(
    'local_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cloudUserIdMeta = const VerificationMeta(
    'cloudUserId',
  );
  @override
  late final GeneratedColumn<String> cloudUserId = GeneratedColumn<String>(
    'cloud_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchKeyMeta = const VerificationMeta(
    'matchKey',
  );
  @override
  late final GeneratedColumn<String> matchKey = GeneratedColumn<String>(
    'match_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localUserId,
    cloudUserId,
    farmId,
    matchKey,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cloud_user_id_mappings';
  @override
  VerificationContext validateIntegrity(
    Insertable<CloudUserIdMapping> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_user_id')) {
      context.handle(
        _localUserIdMeta,
        localUserId.isAcceptableOrUnknown(
          data['local_user_id']!,
          _localUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUserIdMeta);
    }
    if (data.containsKey('cloud_user_id')) {
      context.handle(
        _cloudUserIdMeta,
        cloudUserId.isAcceptableOrUnknown(
          data['cloud_user_id']!,
          _cloudUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cloudUserIdMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('match_key')) {
      context.handle(
        _matchKeyMeta,
        matchKey.isAcceptableOrUnknown(data['match_key']!, _matchKeyMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localUserId};
  @override
  CloudUserIdMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CloudUserIdMapping(
      localUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_user_id'],
      )!,
      cloudUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_user_id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      matchKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_key'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CloudUserIdMappingsTable createAlias(String alias) {
    return $CloudUserIdMappingsTable(attachedDatabase, alias);
  }
}

class CloudUserIdMapping extends DataClass
    implements Insertable<CloudUserIdMapping> {
  /// Local owner id (offline onboarding / genesis farm)
  final String localUserId;

  /// Cloud owner `users.id` from pulled farm_members
  final String cloudUserId;
  final String farmId;

  /// Email or username used to link local ↔ cloud (audit / debug)
  final String? matchKey;
  final DateTime updatedAt;
  const CloudUserIdMapping({
    required this.localUserId,
    required this.cloudUserId,
    required this.farmId,
    this.matchKey,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_user_id'] = Variable<String>(localUserId);
    map['cloud_user_id'] = Variable<String>(cloudUserId);
    map['farm_id'] = Variable<String>(farmId);
    if (!nullToAbsent || matchKey != null) {
      map['match_key'] = Variable<String>(matchKey);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CloudUserIdMappingsCompanion toCompanion(bool nullToAbsent) {
    return CloudUserIdMappingsCompanion(
      localUserId: Value(localUserId),
      cloudUserId: Value(cloudUserId),
      farmId: Value(farmId),
      matchKey: matchKey == null && nullToAbsent
          ? const Value.absent()
          : Value(matchKey),
      updatedAt: Value(updatedAt),
    );
  }

  factory CloudUserIdMapping.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CloudUserIdMapping(
      localUserId: serializer.fromJson<String>(json['localUserId']),
      cloudUserId: serializer.fromJson<String>(json['cloudUserId']),
      farmId: serializer.fromJson<String>(json['farmId']),
      matchKey: serializer.fromJson<String?>(json['matchKey']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localUserId': serializer.toJson<String>(localUserId),
      'cloudUserId': serializer.toJson<String>(cloudUserId),
      'farmId': serializer.toJson<String>(farmId),
      'matchKey': serializer.toJson<String?>(matchKey),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CloudUserIdMapping copyWith({
    String? localUserId,
    String? cloudUserId,
    String? farmId,
    Value<String?> matchKey = const Value.absent(),
    DateTime? updatedAt,
  }) => CloudUserIdMapping(
    localUserId: localUserId ?? this.localUserId,
    cloudUserId: cloudUserId ?? this.cloudUserId,
    farmId: farmId ?? this.farmId,
    matchKey: matchKey.present ? matchKey.value : this.matchKey,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CloudUserIdMapping copyWithCompanion(CloudUserIdMappingsCompanion data) {
    return CloudUserIdMapping(
      localUserId: data.localUserId.present
          ? data.localUserId.value
          : this.localUserId,
      cloudUserId: data.cloudUserId.present
          ? data.cloudUserId.value
          : this.cloudUserId,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      matchKey: data.matchKey.present ? data.matchKey.value : this.matchKey,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CloudUserIdMapping(')
          ..write('localUserId: $localUserId, ')
          ..write('cloudUserId: $cloudUserId, ')
          ..write('farmId: $farmId, ')
          ..write('matchKey: $matchKey, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(localUserId, cloudUserId, farmId, matchKey, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CloudUserIdMapping &&
          other.localUserId == this.localUserId &&
          other.cloudUserId == this.cloudUserId &&
          other.farmId == this.farmId &&
          other.matchKey == this.matchKey &&
          other.updatedAt == this.updatedAt);
}

class CloudUserIdMappingsCompanion extends UpdateCompanion<CloudUserIdMapping> {
  final Value<String> localUserId;
  final Value<String> cloudUserId;
  final Value<String> farmId;
  final Value<String?> matchKey;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CloudUserIdMappingsCompanion({
    this.localUserId = const Value.absent(),
    this.cloudUserId = const Value.absent(),
    this.farmId = const Value.absent(),
    this.matchKey = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CloudUserIdMappingsCompanion.insert({
    required String localUserId,
    required String cloudUserId,
    required String farmId,
    this.matchKey = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localUserId = Value(localUserId),
       cloudUserId = Value(cloudUserId),
       farmId = Value(farmId);
  static Insertable<CloudUserIdMapping> custom({
    Expression<String>? localUserId,
    Expression<String>? cloudUserId,
    Expression<String>? farmId,
    Expression<String>? matchKey,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localUserId != null) 'local_user_id': localUserId,
      if (cloudUserId != null) 'cloud_user_id': cloudUserId,
      if (farmId != null) 'farm_id': farmId,
      if (matchKey != null) 'match_key': matchKey,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CloudUserIdMappingsCompanion copyWith({
    Value<String>? localUserId,
    Value<String>? cloudUserId,
    Value<String>? farmId,
    Value<String?>? matchKey,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CloudUserIdMappingsCompanion(
      localUserId: localUserId ?? this.localUserId,
      cloudUserId: cloudUserId ?? this.cloudUserId,
      farmId: farmId ?? this.farmId,
      matchKey: matchKey ?? this.matchKey,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localUserId.present) {
      map['local_user_id'] = Variable<String>(localUserId.value);
    }
    if (cloudUserId.present) {
      map['cloud_user_id'] = Variable<String>(cloudUserId.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (matchKey.present) {
      map['match_key'] = Variable<String>(matchKey.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CloudUserIdMappingsCompanion(')
          ..write('localUserId: $localUserId, ')
          ..write('cloudUserId: $cloudUserId, ')
          ..write('farmId: $farmId, ')
          ..write('matchKey: $matchKey, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedFormulationsTable extends FeedFormulations
    with TableInfo<$FeedFormulationsTable, FeedFormulation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedFormulationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CUSTOM'),
  );
  static const VerificationMeta _targetLivestockMeta = const VerificationMeta(
    'targetLivestock',
  );
  @override
  late final GeneratedColumn<String> targetLivestock = GeneratedColumn<String>(
    'target_livestock',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockLevelMeta = const VerificationMeta(
    'stockLevel',
  );
  @override
  late final GeneratedColumn<double> stockLevel = GeneratedColumn<double>(
    'stock_level',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    name,
    notes,
    type,
    targetLivestock,
    stockLevel,
    createdAt,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_formulations';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedFormulation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('target_livestock')) {
      context.handle(
        _targetLivestockMeta,
        targetLivestock.isAcceptableOrUnknown(
          data['target_livestock']!,
          _targetLivestockMeta,
        ),
      );
    }
    if (data.containsKey('stock_level')) {
      context.handle(
        _stockLevelMeta,
        stockLevel.isAcceptableOrUnknown(data['stock_level']!, _stockLevelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedFormulation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedFormulation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      targetLivestock: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_livestock'],
      ),
      stockLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_level'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $FeedFormulationsTable createAlias(String alias) {
    return $FeedFormulationsTable(attachedDatabase, alias);
  }
}

class FeedFormulation extends DataClass implements Insertable<FeedFormulation> {
  final String id;
  final String farmId;
  final String name;
  final String? notes;
  final String type;
  final String? targetLivestock;
  final double stockLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const FeedFormulation({
    required this.id,
    required this.farmId,
    required this.name,
    this.notes,
    required this.type,
    this.targetLivestock,
    required this.stockLevel,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || targetLivestock != null) {
      map['target_livestock'] = Variable<String>(targetLivestock);
    }
    map['stock_level'] = Variable<double>(stockLevel);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  FeedFormulationsCompanion toCompanion(bool nullToAbsent) {
    return FeedFormulationsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      type: Value(type),
      targetLivestock: targetLivestock == null && nullToAbsent
          ? const Value.absent()
          : Value(targetLivestock),
      stockLevel: Value(stockLevel),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory FeedFormulation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedFormulation(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      type: serializer.fromJson<String>(json['type']),
      targetLivestock: serializer.fromJson<String?>(json['targetLivestock']),
      stockLevel: serializer.fromJson<double>(json['stockLevel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'type': serializer.toJson<String>(type),
      'targetLivestock': serializer.toJson<String?>(targetLivestock),
      'stockLevel': serializer.toJson<double>(stockLevel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  FeedFormulation copyWith({
    String? id,
    String? farmId,
    String? name,
    Value<String?> notes = const Value.absent(),
    String? type,
    Value<String?> targetLivestock = const Value.absent(),
    double? stockLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) => FeedFormulation(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
    type: type ?? this.type,
    targetLivestock: targetLivestock.present
        ? targetLivestock.value
        : this.targetLivestock,
    stockLevel: stockLevel ?? this.stockLevel,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  FeedFormulation copyWithCompanion(FeedFormulationsCompanion data) {
    return FeedFormulation(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      type: data.type.present ? data.type.value : this.type,
      targetLivestock: data.targetLivestock.present
          ? data.targetLivestock.value
          : this.targetLivestock,
      stockLevel: data.stockLevel.present
          ? data.stockLevel.value
          : this.stockLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedFormulation(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('type: $type, ')
          ..write('targetLivestock: $targetLivestock, ')
          ..write('stockLevel: $stockLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    name,
    notes,
    type,
    targetLivestock,
    stockLevel,
    createdAt,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedFormulation &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.type == this.type &&
          other.targetLivestock == this.targetLivestock &&
          other.stockLevel == this.stockLevel &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class FeedFormulationsCompanion extends UpdateCompanion<FeedFormulation> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> name;
  final Value<String?> notes;
  final Value<String> type;
  final Value<String?> targetLivestock;
  final Value<double> stockLevel;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const FeedFormulationsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.type = const Value.absent(),
    this.targetLivestock = const Value.absent(),
    this.stockLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedFormulationsCompanion.insert({
    required String id,
    required String farmId,
    required String name,
    this.notes = const Value.absent(),
    this.type = const Value.absent(),
    this.targetLivestock = const Value.absent(),
    this.stockLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       name = Value(name);
  static Insertable<FeedFormulation> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<String>? type,
    Expression<String>? targetLivestock,
    Expression<double>? stockLevel,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (type != null) 'type': type,
      if (targetLivestock != null) 'target_livestock': targetLivestock,
      if (stockLevel != null) 'stock_level': stockLevel,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedFormulationsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? name,
    Value<String?>? notes,
    Value<String>? type,
    Value<String?>? targetLivestock,
    Value<double>? stockLevel,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return FeedFormulationsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      targetLivestock: targetLivestock ?? this.targetLivestock,
      stockLevel: stockLevel ?? this.stockLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (targetLivestock.present) {
      map['target_livestock'] = Variable<String>(targetLivestock.value);
    }
    if (stockLevel.present) {
      map['stock_level'] = Variable<double>(stockLevel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedFormulationsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('type: $type, ')
          ..write('targetLivestock: $targetLivestock, ')
          ..write('stockLevel: $stockLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedFormulationIngredientsTable extends FeedFormulationIngredients
    with
        TableInfo<$FeedFormulationIngredientsTable, FeedFormulationIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedFormulationIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formulationIdMeta = const VerificationMeta(
    'formulationId',
  );
  @override
  late final GeneratedColumn<String> formulationId = GeneratedColumn<String>(
    'formulation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inventoryIdMeta = const VerificationMeta(
    'inventoryId',
  );
  @override
  late final GeneratedColumn<String> inventoryId = GeneratedColumn<String>(
    'inventory_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bag'),
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    formulationId,
    inventoryId,
    quantity,
    unit,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_formulation_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedFormulationIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('formulation_id')) {
      context.handle(
        _formulationIdMeta,
        formulationId.isAcceptableOrUnknown(
          data['formulation_id']!,
          _formulationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_formulationIdMeta);
    }
    if (data.containsKey('inventory_id')) {
      context.handle(
        _inventoryIdMeta,
        inventoryId.isAcceptableOrUnknown(
          data['inventory_id']!,
          _inventoryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inventoryIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedFormulationIngredient map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedFormulationIngredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      formulationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formulation_id'],
      )!,
      inventoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inventory_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $FeedFormulationIngredientsTable createAlias(String alias) {
    return $FeedFormulationIngredientsTable(attachedDatabase, alias);
  }
}

class FeedFormulationIngredient extends DataClass
    implements Insertable<FeedFormulationIngredient> {
  final String id;
  final String formulationId;
  final String inventoryId;
  final double quantity;
  final String unit;
  final bool synced;
  const FeedFormulationIngredient({
    required this.id,
    required this.formulationId,
    required this.inventoryId,
    required this.quantity,
    required this.unit,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['formulation_id'] = Variable<String>(formulationId);
    map['inventory_id'] = Variable<String>(inventoryId);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  FeedFormulationIngredientsCompanion toCompanion(bool nullToAbsent) {
    return FeedFormulationIngredientsCompanion(
      id: Value(id),
      formulationId: Value(formulationId),
      inventoryId: Value(inventoryId),
      quantity: Value(quantity),
      unit: Value(unit),
      synced: Value(synced),
    );
  }

  factory FeedFormulationIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedFormulationIngredient(
      id: serializer.fromJson<String>(json['id']),
      formulationId: serializer.fromJson<String>(json['formulationId']),
      inventoryId: serializer.fromJson<String>(json['inventoryId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'formulationId': serializer.toJson<String>(formulationId),
      'inventoryId': serializer.toJson<String>(inventoryId),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  FeedFormulationIngredient copyWith({
    String? id,
    String? formulationId,
    String? inventoryId,
    double? quantity,
    String? unit,
    bool? synced,
  }) => FeedFormulationIngredient(
    id: id ?? this.id,
    formulationId: formulationId ?? this.formulationId,
    inventoryId: inventoryId ?? this.inventoryId,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    synced: synced ?? this.synced,
  );
  FeedFormulationIngredient copyWithCompanion(
    FeedFormulationIngredientsCompanion data,
  ) {
    return FeedFormulationIngredient(
      id: data.id.present ? data.id.value : this.id,
      formulationId: data.formulationId.present
          ? data.formulationId.value
          : this.formulationId,
      inventoryId: data.inventoryId.present
          ? data.inventoryId.value
          : this.inventoryId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedFormulationIngredient(')
          ..write('id: $id, ')
          ..write('formulationId: $formulationId, ')
          ..write('inventoryId: $inventoryId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, formulationId, inventoryId, quantity, unit, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedFormulationIngredient &&
          other.id == this.id &&
          other.formulationId == this.formulationId &&
          other.inventoryId == this.inventoryId &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.synced == this.synced);
}

class FeedFormulationIngredientsCompanion
    extends UpdateCompanion<FeedFormulationIngredient> {
  final Value<String> id;
  final Value<String> formulationId;
  final Value<String> inventoryId;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<bool> synced;
  final Value<int> rowid;
  const FeedFormulationIngredientsCompanion({
    this.id = const Value.absent(),
    this.formulationId = const Value.absent(),
    this.inventoryId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedFormulationIngredientsCompanion.insert({
    required String id,
    required String formulationId,
    required String inventoryId,
    required double quantity,
    this.unit = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       formulationId = Value(formulationId),
       inventoryId = Value(inventoryId),
       quantity = Value(quantity);
  static Insertable<FeedFormulationIngredient> custom({
    Expression<String>? id,
    Expression<String>? formulationId,
    Expression<String>? inventoryId,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (formulationId != null) 'formulation_id': formulationId,
      if (inventoryId != null) 'inventory_id': inventoryId,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedFormulationIngredientsCompanion copyWith({
    Value<String>? id,
    Value<String>? formulationId,
    Value<String>? inventoryId,
    Value<double>? quantity,
    Value<String>? unit,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return FeedFormulationIngredientsCompanion(
      id: id ?? this.id,
      formulationId: formulationId ?? this.formulationId,
      inventoryId: inventoryId ?? this.inventoryId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (formulationId.present) {
      map['formulation_id'] = Variable<String>(formulationId.value);
    }
    if (inventoryId.present) {
      map['inventory_id'] = Variable<String>(inventoryId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedFormulationIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('formulationId: $formulationId, ')
          ..write('inventoryId: $inventoryId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaccinationSchedulesTable extends VaccinationSchedules
    with TableInfo<$VaccinationSchedulesTable, VaccinationSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaccinationSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vaccineNameMeta = const VerificationMeta(
    'vaccineName',
  );
  @override
  late final GeneratedColumn<String> vaccineName = GeneratedColumn<String>(
    'vaccine_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
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
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _usageTypeMeta = const VerificationMeta(
    'usageType',
  );
  @override
  late final GeneratedColumn<String> usageType = GeneratedColumn<String>(
    'usage_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    vaccineName,
    scheduledDate,
    status,
    notes,
    quantity,
    usageType,
    unit,
    farmId,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaccination_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaccinationSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('vaccine_name')) {
      context.handle(
        _vaccineNameMeta,
        vaccineName.isAcceptableOrUnknown(
          data['vaccine_name']!,
          _vaccineNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vaccineNameMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('usage_type')) {
      context.handle(
        _usageTypeMeta,
        usageType.isAcceptableOrUnknown(data['usage_type']!, _usageTypeMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaccinationSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaccinationSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      vaccineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vaccine_name'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      usageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage_type'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $VaccinationSchedulesTable createAlias(String alias) {
    return $VaccinationSchedulesTable(attachedDatabase, alias);
  }
}

class VaccinationSchedule extends DataClass
    implements Insertable<VaccinationSchedule> {
  final String id;
  final String batchId;
  final String vaccineName;
  final DateTime scheduledDate;
  final String status;
  final String? notes;
  final double quantity;
  final String? usageType;
  final String? unit;
  final String farmId;
  final bool synced;
  const VaccinationSchedule({
    required this.id,
    required this.batchId,
    required this.vaccineName,
    required this.scheduledDate,
    required this.status,
    this.notes,
    required this.quantity,
    this.usageType,
    this.unit,
    required this.farmId,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['batch_id'] = Variable<String>(batchId);
    map['vaccine_name'] = Variable<String>(vaccineName);
    map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || usageType != null) {
      map['usage_type'] = Variable<String>(usageType);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['farm_id'] = Variable<String>(farmId);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  VaccinationSchedulesCompanion toCompanion(bool nullToAbsent) {
    return VaccinationSchedulesCompanion(
      id: Value(id),
      batchId: Value(batchId),
      vaccineName: Value(vaccineName),
      scheduledDate: Value(scheduledDate),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      quantity: Value(quantity),
      usageType: usageType == null && nullToAbsent
          ? const Value.absent()
          : Value(usageType),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      farmId: Value(farmId),
      synced: Value(synced),
    );
  }

  factory VaccinationSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaccinationSchedule(
      id: serializer.fromJson<String>(json['id']),
      batchId: serializer.fromJson<String>(json['batchId']),
      vaccineName: serializer.fromJson<String>(json['vaccineName']),
      scheduledDate: serializer.fromJson<DateTime>(json['scheduledDate']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      quantity: serializer.fromJson<double>(json['quantity']),
      usageType: serializer.fromJson<String?>(json['usageType']),
      unit: serializer.fromJson<String?>(json['unit']),
      farmId: serializer.fromJson<String>(json['farmId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'batchId': serializer.toJson<String>(batchId),
      'vaccineName': serializer.toJson<String>(vaccineName),
      'scheduledDate': serializer.toJson<DateTime>(scheduledDate),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'quantity': serializer.toJson<double>(quantity),
      'usageType': serializer.toJson<String?>(usageType),
      'unit': serializer.toJson<String?>(unit),
      'farmId': serializer.toJson<String>(farmId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  VaccinationSchedule copyWith({
    String? id,
    String? batchId,
    String? vaccineName,
    DateTime? scheduledDate,
    String? status,
    Value<String?> notes = const Value.absent(),
    double? quantity,
    Value<String?> usageType = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    String? farmId,
    bool? synced,
  }) => VaccinationSchedule(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    vaccineName: vaccineName ?? this.vaccineName,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    quantity: quantity ?? this.quantity,
    usageType: usageType.present ? usageType.value : this.usageType,
    unit: unit.present ? unit.value : this.unit,
    farmId: farmId ?? this.farmId,
    synced: synced ?? this.synced,
  );
  VaccinationSchedule copyWithCompanion(VaccinationSchedulesCompanion data) {
    return VaccinationSchedule(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      vaccineName: data.vaccineName.present
          ? data.vaccineName.value
          : this.vaccineName,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      usageType: data.usageType.present ? data.usageType.value : this.usageType,
      unit: data.unit.present ? data.unit.value : this.unit,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationSchedule(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('quantity: $quantity, ')
          ..write('usageType: $usageType, ')
          ..write('unit: $unit, ')
          ..write('farmId: $farmId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchId,
    vaccineName,
    scheduledDate,
    status,
    notes,
    quantity,
    usageType,
    unit,
    farmId,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaccinationSchedule &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.vaccineName == this.vaccineName &&
          other.scheduledDate == this.scheduledDate &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.quantity == this.quantity &&
          other.usageType == this.usageType &&
          other.unit == this.unit &&
          other.farmId == this.farmId &&
          other.synced == this.synced);
}

class VaccinationSchedulesCompanion
    extends UpdateCompanion<VaccinationSchedule> {
  final Value<String> id;
  final Value<String> batchId;
  final Value<String> vaccineName;
  final Value<DateTime> scheduledDate;
  final Value<String> status;
  final Value<String?> notes;
  final Value<double> quantity;
  final Value<String?> usageType;
  final Value<String?> unit;
  final Value<String> farmId;
  final Value<bool> synced;
  final Value<int> rowid;
  const VaccinationSchedulesCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.vaccineName = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.quantity = const Value.absent(),
    this.usageType = const Value.absent(),
    this.unit = const Value.absent(),
    this.farmId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaccinationSchedulesCompanion.insert({
    required String id,
    required String batchId,
    required String vaccineName,
    required DateTime scheduledDate,
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.quantity = const Value.absent(),
    this.usageType = const Value.absent(),
    this.unit = const Value.absent(),
    required String farmId,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       batchId = Value(batchId),
       vaccineName = Value(vaccineName),
       scheduledDate = Value(scheduledDate),
       farmId = Value(farmId);
  static Insertable<VaccinationSchedule> custom({
    Expression<String>? id,
    Expression<String>? batchId,
    Expression<String>? vaccineName,
    Expression<DateTime>? scheduledDate,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<double>? quantity,
    Expression<String>? usageType,
    Expression<String>? unit,
    Expression<String>? farmId,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (vaccineName != null) 'vaccine_name': vaccineName,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (quantity != null) 'quantity': quantity,
      if (usageType != null) 'usage_type': usageType,
      if (unit != null) 'unit': unit,
      if (farmId != null) 'farm_id': farmId,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaccinationSchedulesCompanion copyWith({
    Value<String>? id,
    Value<String>? batchId,
    Value<String>? vaccineName,
    Value<DateTime>? scheduledDate,
    Value<String>? status,
    Value<String?>? notes,
    Value<double>? quantity,
    Value<String?>? usageType,
    Value<String?>? unit,
    Value<String>? farmId,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return VaccinationSchedulesCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      vaccineName: vaccineName ?? this.vaccineName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      quantity: quantity ?? this.quantity,
      usageType: usageType ?? this.usageType,
      unit: unit ?? this.unit,
      farmId: farmId ?? this.farmId,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (vaccineName.present) {
      map['vaccine_name'] = Variable<String>(vaccineName.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (usageType.present) {
      map['usage_type'] = Variable<String>(usageType.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('quantity: $quantity, ')
          ..write('usageType: $usageType, ')
          ..write('unit: $unit, ')
          ..write('farmId: $farmId, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationSchedulesTable extends MedicationSchedules
    with TableInfo<$MedicationSchedulesTable, MedicationSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicationNameMeta = const VerificationMeta(
    'medicationName',
  );
  @override
  late final GeneratedColumn<String> medicationName = GeneratedColumn<String>(
    'medication_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
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
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _usageTypeMeta = const VerificationMeta(
    'usageType',
  );
  @override
  late final GeneratedColumn<String> usageType = GeneratedColumn<String>(
    'usage_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    medicationName,
    scheduledDate,
    status,
    notes,
    quantity,
    usageType,
    unit,
    farmId,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('medication_name')) {
      context.handle(
        _medicationNameMeta,
        medicationName.isAcceptableOrUnknown(
          data['medication_name']!,
          _medicationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationNameMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('usage_type')) {
      context.handle(
        _usageTypeMeta,
        usageType.isAcceptableOrUnknown(data['usage_type']!, _usageTypeMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      medicationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_name'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      usageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage_type'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $MedicationSchedulesTable createAlias(String alias) {
    return $MedicationSchedulesTable(attachedDatabase, alias);
  }
}

class MedicationSchedule extends DataClass
    implements Insertable<MedicationSchedule> {
  final String id;
  final String batchId;
  final String medicationName;
  final DateTime scheduledDate;
  final String status;
  final String? notes;
  final double quantity;
  final String? usageType;
  final String? unit;
  final String farmId;
  final bool synced;
  const MedicationSchedule({
    required this.id,
    required this.batchId,
    required this.medicationName,
    required this.scheduledDate,
    required this.status,
    this.notes,
    required this.quantity,
    this.usageType,
    this.unit,
    required this.farmId,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['batch_id'] = Variable<String>(batchId);
    map['medication_name'] = Variable<String>(medicationName);
    map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || usageType != null) {
      map['usage_type'] = Variable<String>(usageType);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['farm_id'] = Variable<String>(farmId);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  MedicationSchedulesCompanion toCompanion(bool nullToAbsent) {
    return MedicationSchedulesCompanion(
      id: Value(id),
      batchId: Value(batchId),
      medicationName: Value(medicationName),
      scheduledDate: Value(scheduledDate),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      quantity: Value(quantity),
      usageType: usageType == null && nullToAbsent
          ? const Value.absent()
          : Value(usageType),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      farmId: Value(farmId),
      synced: Value(synced),
    );
  }

  factory MedicationSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationSchedule(
      id: serializer.fromJson<String>(json['id']),
      batchId: serializer.fromJson<String>(json['batchId']),
      medicationName: serializer.fromJson<String>(json['medicationName']),
      scheduledDate: serializer.fromJson<DateTime>(json['scheduledDate']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      quantity: serializer.fromJson<double>(json['quantity']),
      usageType: serializer.fromJson<String?>(json['usageType']),
      unit: serializer.fromJson<String?>(json['unit']),
      farmId: serializer.fromJson<String>(json['farmId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'batchId': serializer.toJson<String>(batchId),
      'medicationName': serializer.toJson<String>(medicationName),
      'scheduledDate': serializer.toJson<DateTime>(scheduledDate),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'quantity': serializer.toJson<double>(quantity),
      'usageType': serializer.toJson<String?>(usageType),
      'unit': serializer.toJson<String?>(unit),
      'farmId': serializer.toJson<String>(farmId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  MedicationSchedule copyWith({
    String? id,
    String? batchId,
    String? medicationName,
    DateTime? scheduledDate,
    String? status,
    Value<String?> notes = const Value.absent(),
    double? quantity,
    Value<String?> usageType = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    String? farmId,
    bool? synced,
  }) => MedicationSchedule(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    medicationName: medicationName ?? this.medicationName,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    quantity: quantity ?? this.quantity,
    usageType: usageType.present ? usageType.value : this.usageType,
    unit: unit.present ? unit.value : this.unit,
    farmId: farmId ?? this.farmId,
    synced: synced ?? this.synced,
  );
  MedicationSchedule copyWithCompanion(MedicationSchedulesCompanion data) {
    return MedicationSchedule(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      medicationName: data.medicationName.present
          ? data.medicationName.value
          : this.medicationName,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      usageType: data.usageType.present ? data.usageType.value : this.usageType,
      unit: data.unit.present ? data.unit.value : this.unit,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationSchedule(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('medicationName: $medicationName, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('quantity: $quantity, ')
          ..write('usageType: $usageType, ')
          ..write('unit: $unit, ')
          ..write('farmId: $farmId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchId,
    medicationName,
    scheduledDate,
    status,
    notes,
    quantity,
    usageType,
    unit,
    farmId,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationSchedule &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.medicationName == this.medicationName &&
          other.scheduledDate == this.scheduledDate &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.quantity == this.quantity &&
          other.usageType == this.usageType &&
          other.unit == this.unit &&
          other.farmId == this.farmId &&
          other.synced == this.synced);
}

class MedicationSchedulesCompanion extends UpdateCompanion<MedicationSchedule> {
  final Value<String> id;
  final Value<String> batchId;
  final Value<String> medicationName;
  final Value<DateTime> scheduledDate;
  final Value<String> status;
  final Value<String?> notes;
  final Value<double> quantity;
  final Value<String?> usageType;
  final Value<String?> unit;
  final Value<String> farmId;
  final Value<bool> synced;
  final Value<int> rowid;
  const MedicationSchedulesCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.medicationName = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.quantity = const Value.absent(),
    this.usageType = const Value.absent(),
    this.unit = const Value.absent(),
    this.farmId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationSchedulesCompanion.insert({
    required String id,
    required String batchId,
    required String medicationName,
    required DateTime scheduledDate,
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.quantity = const Value.absent(),
    this.usageType = const Value.absent(),
    this.unit = const Value.absent(),
    required String farmId,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       batchId = Value(batchId),
       medicationName = Value(medicationName),
       scheduledDate = Value(scheduledDate),
       farmId = Value(farmId);
  static Insertable<MedicationSchedule> custom({
    Expression<String>? id,
    Expression<String>? batchId,
    Expression<String>? medicationName,
    Expression<DateTime>? scheduledDate,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<double>? quantity,
    Expression<String>? usageType,
    Expression<String>? unit,
    Expression<String>? farmId,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (medicationName != null) 'medication_name': medicationName,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (quantity != null) 'quantity': quantity,
      if (usageType != null) 'usage_type': usageType,
      if (unit != null) 'unit': unit,
      if (farmId != null) 'farm_id': farmId,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationSchedulesCompanion copyWith({
    Value<String>? id,
    Value<String>? batchId,
    Value<String>? medicationName,
    Value<DateTime>? scheduledDate,
    Value<String>? status,
    Value<String?>? notes,
    Value<double>? quantity,
    Value<String?>? usageType,
    Value<String?>? unit,
    Value<String>? farmId,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return MedicationSchedulesCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      medicationName: medicationName ?? this.medicationName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      quantity: quantity ?? this.quantity,
      usageType: usageType ?? this.usageType,
      unit: unit ?? this.unit,
      farmId: farmId ?? this.farmId,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (medicationName.present) {
      map['medication_name'] = Variable<String>(medicationName.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (usageType.present) {
      map['usage_type'] = Variable<String>(usageType.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('medicationName: $medicationName, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('quantity: $quantity, ')
          ..write('usageType: $usageType, ')
          ..write('unit: $unit, ')
          ..write('farmId: $farmId, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HealthRecordsTable extends HealthRecords
    with TableInfo<$HealthRecordsTable, HealthRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
    'record_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    recordType,
    description,
    recordDate,
    farmId,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      recordDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}record_date'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $HealthRecordsTable createAlias(String alias) {
    return $HealthRecordsTable(attachedDatabase, alias);
  }
}

class HealthRecord extends DataClass implements Insertable<HealthRecord> {
  final String id;
  final String? batchId;
  final String? recordType;
  final String? description;
  final DateTime recordDate;
  final String farmId;
  final bool synced;
  const HealthRecord({
    required this.id,
    this.batchId,
    this.recordType,
    this.description,
    required this.recordDate,
    required this.farmId,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    if (!nullToAbsent || recordType != null) {
      map['record_type'] = Variable<String>(recordType);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['record_date'] = Variable<DateTime>(recordDate);
    map['farm_id'] = Variable<String>(farmId);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  HealthRecordsCompanion toCompanion(bool nullToAbsent) {
    return HealthRecordsCompanion(
      id: Value(id),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      recordType: recordType == null && nullToAbsent
          ? const Value.absent()
          : Value(recordType),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      recordDate: Value(recordDate),
      farmId: Value(farmId),
      synced: Value(synced),
    );
  }

  factory HealthRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthRecord(
      id: serializer.fromJson<String>(json['id']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      recordType: serializer.fromJson<String?>(json['recordType']),
      description: serializer.fromJson<String?>(json['description']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      farmId: serializer.fromJson<String>(json['farmId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'batchId': serializer.toJson<String?>(batchId),
      'recordType': serializer.toJson<String?>(recordType),
      'description': serializer.toJson<String?>(description),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'farmId': serializer.toJson<String>(farmId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  HealthRecord copyWith({
    String? id,
    Value<String?> batchId = const Value.absent(),
    Value<String?> recordType = const Value.absent(),
    Value<String?> description = const Value.absent(),
    DateTime? recordDate,
    String? farmId,
    bool? synced,
  }) => HealthRecord(
    id: id ?? this.id,
    batchId: batchId.present ? batchId.value : this.batchId,
    recordType: recordType.present ? recordType.value : this.recordType,
    description: description.present ? description.value : this.description,
    recordDate: recordDate ?? this.recordDate,
    farmId: farmId ?? this.farmId,
    synced: synced ?? this.synced,
  );
  HealthRecord copyWithCompanion(HealthRecordsCompanion data) {
    return HealthRecord(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      description: data.description.present
          ? data.description.value
          : this.description,
      recordDate: data.recordDate.present
          ? data.recordDate.value
          : this.recordDate,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthRecord(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('recordType: $recordType, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('farmId: $farmId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchId,
    recordType,
    description,
    recordDate,
    farmId,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthRecord &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.recordType == this.recordType &&
          other.description == this.description &&
          other.recordDate == this.recordDate &&
          other.farmId == this.farmId &&
          other.synced == this.synced);
}

class HealthRecordsCompanion extends UpdateCompanion<HealthRecord> {
  final Value<String> id;
  final Value<String?> batchId;
  final Value<String?> recordType;
  final Value<String?> description;
  final Value<DateTime> recordDate;
  final Value<String> farmId;
  final Value<bool> synced;
  final Value<int> rowid;
  const HealthRecordsCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.description = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.farmId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthRecordsCompanion.insert({
    required String id,
    this.batchId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.description = const Value.absent(),
    required DateTime recordDate,
    required String farmId,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recordDate = Value(recordDate),
       farmId = Value(farmId);
  static Insertable<HealthRecord> custom({
    Expression<String>? id,
    Expression<String>? batchId,
    Expression<String>? recordType,
    Expression<String>? description,
    Expression<DateTime>? recordDate,
    Expression<String>? farmId,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (recordType != null) 'record_type': recordType,
      if (description != null) 'description': description,
      if (recordDate != null) 'record_date': recordDate,
      if (farmId != null) 'farm_id': farmId,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthRecordsCompanion copyWith({
    Value<String>? id,
    Value<String?>? batchId,
    Value<String?>? recordType,
    Value<String?>? description,
    Value<DateTime>? recordDate,
    Value<String>? farmId,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return HealthRecordsCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      recordType: recordType ?? this.recordType,
      description: description ?? this.description,
      recordDate: recordDate ?? this.recordDate,
      farmId: farmId ?? this.farmId,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthRecordsCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('recordType: $recordType, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('farmId: $farmId, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleDateMeta = const VerificationMeta(
    'saleDate',
  );
  @override
  late final GeneratedColumn<DateTime> saleDate = GeneratedColumn<DateTime>(
    'sale_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    batchId,
    customerId,
    quantity,
    unitPrice,
    totalAmount,
    saleDate,
    userId,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('sale_date')) {
      context.handle(
        _saleDateMeta,
        saleDate.isAcceptableOrUnknown(data['sale_date']!, _saleDateMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      saleDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sale_date'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final String id;
  final String farmId;
  final String? batchId;
  final String? customerId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final DateTime saleDate;
  final String? userId;
  final bool synced;
  const Sale({
    required this.id,
    required this.farmId,
    this.batchId,
    this.customerId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.saleDate,
    this.userId,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_amount'] = Variable<double>(totalAmount);
    map['sale_date'] = Variable<DateTime>(saleDate);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      totalAmount: Value(totalAmount),
      saleDate: Value(saleDate),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      synced: Value(synced),
    );
  }

  factory Sale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      saleDate: serializer.fromJson<DateTime>(json['saleDate']),
      userId: serializer.fromJson<String?>(json['userId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'batchId': serializer.toJson<String?>(batchId),
      'customerId': serializer.toJson<String?>(customerId),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'saleDate': serializer.toJson<DateTime>(saleDate),
      'userId': serializer.toJson<String?>(userId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Sale copyWith({
    String? id,
    String? farmId,
    Value<String?> batchId = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    DateTime? saleDate,
    Value<String?> userId = const Value.absent(),
    bool? synced,
  }) => Sale(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    batchId: batchId.present ? batchId.value : this.batchId,
    customerId: customerId.present ? customerId.value : this.customerId,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    totalAmount: totalAmount ?? this.totalAmount,
    saleDate: saleDate ?? this.saleDate,
    userId: userId.present ? userId.value : this.userId,
    synced: synced ?? this.synced,
  );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      saleDate: data.saleDate.present ? data.saleDate.value : this.saleDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('customerId: $customerId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('saleDate: $saleDate, ')
          ..write('userId: $userId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    batchId,
    customerId,
    quantity,
    unitPrice,
    totalAmount,
    saleDate,
    userId,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.batchId == this.batchId &&
          other.customerId == this.customerId &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.totalAmount == this.totalAmount &&
          other.saleDate == this.saleDate &&
          other.userId == this.userId &&
          other.synced == this.synced);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String?> batchId;
  final Value<String?> customerId;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> totalAmount;
  final Value<DateTime> saleDate;
  final Value<String?> userId;
  final Value<bool> synced;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.saleDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    required String farmId,
    this.batchId = const Value.absent(),
    this.customerId = const Value.absent(),
    required int quantity,
    required double unitPrice,
    required double totalAmount,
    this.saleDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       quantity = Value(quantity),
       unitPrice = Value(unitPrice),
       totalAmount = Value(totalAmount);
  static Insertable<Sale> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? batchId,
    Expression<String>? customerId,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? totalAmount,
    Expression<DateTime>? saleDate,
    Expression<String>? userId,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (batchId != null) 'batch_id': batchId,
      if (customerId != null) 'customer_id': customerId,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (saleDate != null) 'sale_date': saleDate,
      if (userId != null) 'user_id': userId,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String?>? batchId,
    Value<String?>? customerId,
    Value<int>? quantity,
    Value<double>? unitPrice,
    Value<double>? totalAmount,
    Value<DateTime>? saleDate,
    Value<String?>? userId,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      batchId: batchId ?? this.batchId,
      customerId: customerId ?? this.customerId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      saleDate: saleDate ?? this.saleDate,
      userId: userId ?? this.userId,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (saleDate.present) {
      map['sale_date'] = Variable<DateTime>(saleDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('customerId: $customerId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('saleDate: $saleDate, ')
          ..write('userId: $userId, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allocationGroupIdMeta = const VerificationMeta(
    'allocationGroupId',
  );
  @override
  late final GeneratedColumn<String> allocationGroupId =
      GeneratedColumn<String>(
        'allocation_group_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _allocationPercentMeta = const VerificationMeta(
    'allocationPercent',
  );
  @override
  late final GeneratedColumn<double> allocationPercent =
      GeneratedColumn<double>(
        'allocation_percent',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isSharedAllocationMeta =
      const VerificationMeta('isSharedAllocation');
  @override
  late final GeneratedColumn<bool> isSharedAllocation = GeneratedColumn<bool>(
    'is_shared_allocation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shared_allocation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    batchId,
    supplierId,
    category,
    amount,
    date,
    description,
    allocationGroupId,
    allocationPercent,
    isSharedAllocation,
    userId,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('allocation_group_id')) {
      context.handle(
        _allocationGroupIdMeta,
        allocationGroupId.isAcceptableOrUnknown(
          data['allocation_group_id']!,
          _allocationGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('allocation_percent')) {
      context.handle(
        _allocationPercentMeta,
        allocationPercent.isAcceptableOrUnknown(
          data['allocation_percent']!,
          _allocationPercentMeta,
        ),
      );
    }
    if (data.containsKey('is_shared_allocation')) {
      context.handle(
        _isSharedAllocationMeta,
        isSharedAllocation.isAcceptableOrUnknown(
          data['is_shared_allocation']!,
          _isSharedAllocationMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      allocationGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allocation_group_id'],
      ),
      allocationPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}allocation_percent'],
      ),
      isSharedAllocation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shared_allocation'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final String farmId;
  final String? batchId;
  final String? supplierId;
  final String category;
  final double amount;
  final DateTime date;
  final String? description;
  final String? allocationGroupId;
  final double? allocationPercent;
  final bool isSharedAllocation;
  final String? userId;
  final bool synced;
  const Expense({
    required this.id,
    required this.farmId,
    this.batchId,
    this.supplierId,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    this.allocationGroupId,
    this.allocationPercent,
    required this.isSharedAllocation,
    this.userId,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || allocationGroupId != null) {
      map['allocation_group_id'] = Variable<String>(allocationGroupId);
    }
    if (!nullToAbsent || allocationPercent != null) {
      map['allocation_percent'] = Variable<double>(allocationPercent);
    }
    map['is_shared_allocation'] = Variable<bool>(isSharedAllocation);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      category: Value(category),
      amount: Value(amount),
      date: Value(date),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      allocationGroupId: allocationGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(allocationGroupId),
      allocationPercent: allocationPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(allocationPercent),
      isSharedAllocation: Value(isSharedAllocation),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      synced: Value(synced),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String?>(json['description']),
      allocationGroupId: serializer.fromJson<String?>(
        json['allocationGroupId'],
      ),
      allocationPercent: serializer.fromJson<double?>(
        json['allocationPercent'],
      ),
      isSharedAllocation: serializer.fromJson<bool>(json['isSharedAllocation']),
      userId: serializer.fromJson<String?>(json['userId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'batchId': serializer.toJson<String?>(batchId),
      'supplierId': serializer.toJson<String?>(supplierId),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String?>(description),
      'allocationGroupId': serializer.toJson<String?>(allocationGroupId),
      'allocationPercent': serializer.toJson<double?>(allocationPercent),
      'isSharedAllocation': serializer.toJson<bool>(isSharedAllocation),
      'userId': serializer.toJson<String?>(userId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Expense copyWith({
    String? id,
    String? farmId,
    Value<String?> batchId = const Value.absent(),
    Value<String?> supplierId = const Value.absent(),
    String? category,
    double? amount,
    DateTime? date,
    Value<String?> description = const Value.absent(),
    Value<String?> allocationGroupId = const Value.absent(),
    Value<double?> allocationPercent = const Value.absent(),
    bool? isSharedAllocation,
    Value<String?> userId = const Value.absent(),
    bool? synced,
  }) => Expense(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    batchId: batchId.present ? batchId.value : this.batchId,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    description: description.present ? description.value : this.description,
    allocationGroupId: allocationGroupId.present
        ? allocationGroupId.value
        : this.allocationGroupId,
    allocationPercent: allocationPercent.present
        ? allocationPercent.value
        : this.allocationPercent,
    isSharedAllocation: isSharedAllocation ?? this.isSharedAllocation,
    userId: userId.present ? userId.value : this.userId,
    synced: synced ?? this.synced,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      description: data.description.present
          ? data.description.value
          : this.description,
      allocationGroupId: data.allocationGroupId.present
          ? data.allocationGroupId.value
          : this.allocationGroupId,
      allocationPercent: data.allocationPercent.present
          ? data.allocationPercent.value
          : this.allocationPercent,
      isSharedAllocation: data.isSharedAllocation.present
          ? data.isSharedAllocation.value
          : this.isSharedAllocation,
      userId: data.userId.present ? data.userId.value : this.userId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('supplierId: $supplierId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('allocationGroupId: $allocationGroupId, ')
          ..write('allocationPercent: $allocationPercent, ')
          ..write('isSharedAllocation: $isSharedAllocation, ')
          ..write('userId: $userId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    batchId,
    supplierId,
    category,
    amount,
    date,
    description,
    allocationGroupId,
    allocationPercent,
    isSharedAllocation,
    userId,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.batchId == this.batchId &&
          other.supplierId == this.supplierId &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.description == this.description &&
          other.allocationGroupId == this.allocationGroupId &&
          other.allocationPercent == this.allocationPercent &&
          other.isSharedAllocation == this.isSharedAllocation &&
          other.userId == this.userId &&
          other.synced == this.synced);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String?> batchId;
  final Value<String?> supplierId;
  final Value<String> category;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String?> description;
  final Value<String?> allocationGroupId;
  final Value<double?> allocationPercent;
  final Value<bool> isSharedAllocation;
  final Value<String?> userId;
  final Value<bool> synced;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.allocationGroupId = const Value.absent(),
    this.allocationPercent = const Value.absent(),
    this.isSharedAllocation = const Value.absent(),
    this.userId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String farmId,
    this.batchId = const Value.absent(),
    this.supplierId = const Value.absent(),
    required String category,
    required double amount,
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.allocationGroupId = const Value.absent(),
    this.allocationPercent = const Value.absent(),
    this.isSharedAllocation = const Value.absent(),
    this.userId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       category = Value(category),
       amount = Value(amount);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? batchId,
    Expression<String>? supplierId,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<String>? allocationGroupId,
    Expression<double>? allocationPercent,
    Expression<bool>? isSharedAllocation,
    Expression<String>? userId,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (batchId != null) 'batch_id': batchId,
      if (supplierId != null) 'supplier_id': supplierId,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (allocationGroupId != null) 'allocation_group_id': allocationGroupId,
      if (allocationPercent != null) 'allocation_percent': allocationPercent,
      if (isSharedAllocation != null)
        'is_shared_allocation': isSharedAllocation,
      if (userId != null) 'user_id': userId,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String?>? batchId,
    Value<String?>? supplierId,
    Value<String>? category,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String?>? description,
    Value<String?>? allocationGroupId,
    Value<double?>? allocationPercent,
    Value<bool>? isSharedAllocation,
    Value<String?>? userId,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      batchId: batchId ?? this.batchId,
      supplierId: supplierId ?? this.supplierId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      allocationGroupId: allocationGroupId ?? this.allocationGroupId,
      allocationPercent: allocationPercent ?? this.allocationPercent,
      isSharedAllocation: isSharedAllocation ?? this.isSharedAllocation,
      userId: userId ?? this.userId,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (allocationGroupId.present) {
      map['allocation_group_id'] = Variable<String>(allocationGroupId.value);
    }
    if (allocationPercent.present) {
      map['allocation_percent'] = Variable<double>(allocationPercent.value);
    }
    if (isSharedAllocation.present) {
      map['is_shared_allocation'] = Variable<bool>(isSharedAllocation.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('supplierId: $supplierId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('allocationGroupId: $allocationGroupId, ')
          ..write('allocationPercent: $allocationPercent, ')
          ..write('isSharedAllocation: $isSharedAllocation, ')
          ..write('userId: $userId, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettlementsTable extends Settlements
    with TableInfo<$SettlementsTable, Settlement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settlementDateMeta = const VerificationMeta(
    'settlementDate',
  );
  @override
  late final GeneratedColumn<DateTime> settlementDate =
      GeneratedColumn<DateTime>(
        'settlement_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _settlementTypeMeta = const VerificationMeta(
    'settlementType',
  );
  @override
  late final GeneratedColumn<String> settlementType = GeneratedColumn<String>(
    'settlement_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    customerId,
    amount,
    settlementDate,
    settlementType,
    userId,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settlements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Settlement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('settlement_date')) {
      context.handle(
        _settlementDateMeta,
        settlementDate.isAcceptableOrUnknown(
          data['settlement_date']!,
          _settlementDateMeta,
        ),
      );
    }
    if (data.containsKey('settlement_type')) {
      context.handle(
        _settlementTypeMeta,
        settlementType.isAcceptableOrUnknown(
          data['settlement_type']!,
          _settlementTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settlementTypeMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Settlement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Settlement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      settlementDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}settlement_date'],
      )!,
      settlementType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settlement_type'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $SettlementsTable createAlias(String alias) {
    return $SettlementsTable(attachedDatabase, alias);
  }
}

class Settlement extends DataClass implements Insertable<Settlement> {
  final String id;
  final String farmId;
  final String customerId;
  final double amount;
  final DateTime settlementDate;
  final String settlementType;
  final String? userId;
  final bool synced;
  const Settlement({
    required this.id,
    required this.farmId,
    required this.customerId,
    required this.amount,
    required this.settlementDate,
    required this.settlementType,
    this.userId,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['customer_id'] = Variable<String>(customerId);
    map['amount'] = Variable<double>(amount);
    map['settlement_date'] = Variable<DateTime>(settlementDate);
    map['settlement_type'] = Variable<String>(settlementType);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  SettlementsCompanion toCompanion(bool nullToAbsent) {
    return SettlementsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      customerId: Value(customerId),
      amount: Value(amount),
      settlementDate: Value(settlementDate),
      settlementType: Value(settlementType),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      synced: Value(synced),
    );
  }

  factory Settlement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Settlement(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      amount: serializer.fromJson<double>(json['amount']),
      settlementDate: serializer.fromJson<DateTime>(json['settlementDate']),
      settlementType: serializer.fromJson<String>(json['settlementType']),
      userId: serializer.fromJson<String?>(json['userId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'customerId': serializer.toJson<String>(customerId),
      'amount': serializer.toJson<double>(amount),
      'settlementDate': serializer.toJson<DateTime>(settlementDate),
      'settlementType': serializer.toJson<String>(settlementType),
      'userId': serializer.toJson<String?>(userId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Settlement copyWith({
    String? id,
    String? farmId,
    String? customerId,
    double? amount,
    DateTime? settlementDate,
    String? settlementType,
    Value<String?> userId = const Value.absent(),
    bool? synced,
  }) => Settlement(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    customerId: customerId ?? this.customerId,
    amount: amount ?? this.amount,
    settlementDate: settlementDate ?? this.settlementDate,
    settlementType: settlementType ?? this.settlementType,
    userId: userId.present ? userId.value : this.userId,
    synced: synced ?? this.synced,
  );
  Settlement copyWithCompanion(SettlementsCompanion data) {
    return Settlement(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      amount: data.amount.present ? data.amount.value : this.amount,
      settlementDate: data.settlementDate.present
          ? data.settlementDate.value
          : this.settlementDate,
      settlementType: data.settlementType.present
          ? data.settlementType.value
          : this.settlementType,
      userId: data.userId.present ? data.userId.value : this.userId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Settlement(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('customerId: $customerId, ')
          ..write('amount: $amount, ')
          ..write('settlementDate: $settlementDate, ')
          ..write('settlementType: $settlementType, ')
          ..write('userId: $userId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    customerId,
    amount,
    settlementDate,
    settlementType,
    userId,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Settlement &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.customerId == this.customerId &&
          other.amount == this.amount &&
          other.settlementDate == this.settlementDate &&
          other.settlementType == this.settlementType &&
          other.userId == this.userId &&
          other.synced == this.synced);
}

class SettlementsCompanion extends UpdateCompanion<Settlement> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> customerId;
  final Value<double> amount;
  final Value<DateTime> settlementDate;
  final Value<String> settlementType;
  final Value<String?> userId;
  final Value<bool> synced;
  final Value<int> rowid;
  const SettlementsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.amount = const Value.absent(),
    this.settlementDate = const Value.absent(),
    this.settlementType = const Value.absent(),
    this.userId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettlementsCompanion.insert({
    required String id,
    required String farmId,
    required String customerId,
    required double amount,
    this.settlementDate = const Value.absent(),
    required String settlementType,
    this.userId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       customerId = Value(customerId),
       amount = Value(amount),
       settlementType = Value(settlementType);
  static Insertable<Settlement> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? customerId,
    Expression<double>? amount,
    Expression<DateTime>? settlementDate,
    Expression<String>? settlementType,
    Expression<String>? userId,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (customerId != null) 'customer_id': customerId,
      if (amount != null) 'amount': amount,
      if (settlementDate != null) 'settlement_date': settlementDate,
      if (settlementType != null) 'settlement_type': settlementType,
      if (userId != null) 'user_id': userId,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettlementsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? customerId,
    Value<double>? amount,
    Value<DateTime>? settlementDate,
    Value<String>? settlementType,
    Value<String?>? userId,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return SettlementsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      settlementDate: settlementDate ?? this.settlementDate,
      settlementType: settlementType ?? this.settlementType,
      userId: userId ?? this.userId,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (settlementDate.present) {
      map['settlement_date'] = Variable<DateTime>(settlementDate.value);
    }
    if (settlementType.present) {
      map['settlement_type'] = Variable<String>(settlementType.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettlementsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('customerId: $customerId, ')
          ..write('amount: $amount, ')
          ..write('settlementDate: $settlementDate, ')
          ..write('settlementType: $settlementType, ')
          ..write('userId: $userId, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingDeletionsTable extends PendingDeletions
    with TableInfo<$PendingDeletionsTable, PendingDeletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingDeletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableNameMeta = const VerificationMeta(
    'targetTableName',
  );
  @override
  late final GeneratedColumn<String> targetTableName = GeneratedColumn<String>(
    'target_table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTableName,
    recordId,
    farmId,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_deletions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingDeletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('target_table_name')) {
      context.handle(
        _targetTableNameMeta,
        targetTableName.isAcceptableOrUnknown(
          data['target_table_name']!,
          _targetTableNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableNameMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingDeletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingDeletion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      targetTableName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table_name'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      )!,
    );
  }

  @override
  $PendingDeletionsTable createAlias(String alias) {
    return $PendingDeletionsTable(attachedDatabase, alias);
  }
}

class PendingDeletion extends DataClass implements Insertable<PendingDeletion> {
  final String id;
  final String targetTableName;
  final String recordId;
  final String farmId;
  final DateTime deletedAt;
  const PendingDeletion({
    required this.id,
    required this.targetTableName,
    required this.recordId,
    required this.farmId,
    required this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['target_table_name'] = Variable<String>(targetTableName);
    map['record_id'] = Variable<String>(recordId);
    map['farm_id'] = Variable<String>(farmId);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    return map;
  }

  PendingDeletionsCompanion toCompanion(bool nullToAbsent) {
    return PendingDeletionsCompanion(
      id: Value(id),
      targetTableName: Value(targetTableName),
      recordId: Value(recordId),
      farmId: Value(farmId),
      deletedAt: Value(deletedAt),
    );
  }

  factory PendingDeletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingDeletion(
      id: serializer.fromJson<String>(json['id']),
      targetTableName: serializer.fromJson<String>(json['targetTableName']),
      recordId: serializer.fromJson<String>(json['recordId']),
      farmId: serializer.fromJson<String>(json['farmId']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'targetTableName': serializer.toJson<String>(targetTableName),
      'recordId': serializer.toJson<String>(recordId),
      'farmId': serializer.toJson<String>(farmId),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
    };
  }

  PendingDeletion copyWith({
    String? id,
    String? targetTableName,
    String? recordId,
    String? farmId,
    DateTime? deletedAt,
  }) => PendingDeletion(
    id: id ?? this.id,
    targetTableName: targetTableName ?? this.targetTableName,
    recordId: recordId ?? this.recordId,
    farmId: farmId ?? this.farmId,
    deletedAt: deletedAt ?? this.deletedAt,
  );
  PendingDeletion copyWithCompanion(PendingDeletionsCompanion data) {
    return PendingDeletion(
      id: data.id.present ? data.id.value : this.id,
      targetTableName: data.targetTableName.present
          ? data.targetTableName.value
          : this.targetTableName,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingDeletion(')
          ..write('id: $id, ')
          ..write('targetTableName: $targetTableName, ')
          ..write('recordId: $recordId, ')
          ..write('farmId: $farmId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, targetTableName, recordId, farmId, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingDeletion &&
          other.id == this.id &&
          other.targetTableName == this.targetTableName &&
          other.recordId == this.recordId &&
          other.farmId == this.farmId &&
          other.deletedAt == this.deletedAt);
}

class PendingDeletionsCompanion extends UpdateCompanion<PendingDeletion> {
  final Value<String> id;
  final Value<String> targetTableName;
  final Value<String> recordId;
  final Value<String> farmId;
  final Value<DateTime> deletedAt;
  final Value<int> rowid;
  const PendingDeletionsCompanion({
    this.id = const Value.absent(),
    this.targetTableName = const Value.absent(),
    this.recordId = const Value.absent(),
    this.farmId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingDeletionsCompanion.insert({
    required String id,
    required String targetTableName,
    required String recordId,
    required String farmId,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       targetTableName = Value(targetTableName),
       recordId = Value(recordId),
       farmId = Value(farmId);
  static Insertable<PendingDeletion> custom({
    Expression<String>? id,
    Expression<String>? targetTableName,
    Expression<String>? recordId,
    Expression<String>? farmId,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTableName != null) 'target_table_name': targetTableName,
      if (recordId != null) 'record_id': recordId,
      if (farmId != null) 'farm_id': farmId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingDeletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? targetTableName,
    Value<String>? recordId,
    Value<String>? farmId,
    Value<DateTime>? deletedAt,
    Value<int>? rowid,
  }) {
    return PendingDeletionsCompanion(
      id: id ?? this.id,
      targetTableName: targetTableName ?? this.targetTableName,
      recordId: recordId ?? this.recordId,
      farmId: farmId ?? this.farmId,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (targetTableName.present) {
      map['target_table_name'] = Variable<String>(targetTableName.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingDeletionsCompanion(')
          ..write('id: $id, ')
          ..write('targetTableName: $targetTableName, ')
          ..write('recordId: $recordId, ')
          ..write('farmId: $farmId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockLogsTable extends StockLogs
    with TableInfo<$StockLogsTable, StockLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logTypeMeta = const VerificationMeta(
    'logType',
  );
  @override
  late final GeneratedColumn<String> logType = GeneratedColumn<String>(
    'log_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    itemId,
    quantity,
    logType,
    batchId,
    supplierId,
    note,
    logDate,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('log_type')) {
      context.handle(
        _logTypeMeta,
        logType.isAcceptableOrUnknown(data['log_type']!, _logTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_logTypeMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      logType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_type'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}log_date'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $StockLogsTable createAlias(String alias) {
    return $StockLogsTable(attachedDatabase, alias);
  }
}

class StockLog extends DataClass implements Insertable<StockLog> {
  final String id;
  final String farmId;
  final String itemId;
  final double quantity;
  final String logType;
  final String? batchId;
  final String? supplierId;
  final String? note;
  final DateTime logDate;
  final bool synced;
  const StockLog({
    required this.id,
    required this.farmId,
    required this.itemId,
    required this.quantity,
    required this.logType,
    this.batchId,
    this.supplierId,
    this.note,
    required this.logDate,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['item_id'] = Variable<String>(itemId);
    map['quantity'] = Variable<double>(quantity);
    map['log_type'] = Variable<String>(logType);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['log_date'] = Variable<DateTime>(logDate);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  StockLogsCompanion toCompanion(bool nullToAbsent) {
    return StockLogsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      itemId: Value(itemId),
      quantity: Value(quantity),
      logType: Value(logType),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      logDate: Value(logDate),
      synced: Value(synced),
    );
  }

  factory StockLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockLog(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      logType: serializer.fromJson<String>(json['logType']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      note: serializer.fromJson<String?>(json['note']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'itemId': serializer.toJson<String>(itemId),
      'quantity': serializer.toJson<double>(quantity),
      'logType': serializer.toJson<String>(logType),
      'batchId': serializer.toJson<String?>(batchId),
      'supplierId': serializer.toJson<String?>(supplierId),
      'note': serializer.toJson<String?>(note),
      'logDate': serializer.toJson<DateTime>(logDate),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  StockLog copyWith({
    String? id,
    String? farmId,
    String? itemId,
    double? quantity,
    String? logType,
    Value<String?> batchId = const Value.absent(),
    Value<String?> supplierId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? logDate,
    bool? synced,
  }) => StockLog(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    itemId: itemId ?? this.itemId,
    quantity: quantity ?? this.quantity,
    logType: logType ?? this.logType,
    batchId: batchId.present ? batchId.value : this.batchId,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    note: note.present ? note.value : this.note,
    logDate: logDate ?? this.logDate,
    synced: synced ?? this.synced,
  );
  StockLog copyWithCompanion(StockLogsCompanion data) {
    return StockLog(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      logType: data.logType.present ? data.logType.value : this.logType,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      note: data.note.present ? data.note.value : this.note,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockLog(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('itemId: $itemId, ')
          ..write('quantity: $quantity, ')
          ..write('logType: $logType, ')
          ..write('batchId: $batchId, ')
          ..write('supplierId: $supplierId, ')
          ..write('note: $note, ')
          ..write('logDate: $logDate, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    itemId,
    quantity,
    logType,
    batchId,
    supplierId,
    note,
    logDate,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockLog &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.itemId == this.itemId &&
          other.quantity == this.quantity &&
          other.logType == this.logType &&
          other.batchId == this.batchId &&
          other.supplierId == this.supplierId &&
          other.note == this.note &&
          other.logDate == this.logDate &&
          other.synced == this.synced);
}

class StockLogsCompanion extends UpdateCompanion<StockLog> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> itemId;
  final Value<double> quantity;
  final Value<String> logType;
  final Value<String?> batchId;
  final Value<String?> supplierId;
  final Value<String?> note;
  final Value<DateTime> logDate;
  final Value<bool> synced;
  final Value<int> rowid;
  const StockLogsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.logType = const Value.absent(),
    this.batchId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.note = const Value.absent(),
    this.logDate = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockLogsCompanion.insert({
    required String id,
    required String farmId,
    required String itemId,
    required double quantity,
    required String logType,
    this.batchId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.note = const Value.absent(),
    this.logDate = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       itemId = Value(itemId),
       quantity = Value(quantity),
       logType = Value(logType);
  static Insertable<StockLog> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? itemId,
    Expression<double>? quantity,
    Expression<String>? logType,
    Expression<String>? batchId,
    Expression<String>? supplierId,
    Expression<String>? note,
    Expression<DateTime>? logDate,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (itemId != null) 'item_id': itemId,
      if (quantity != null) 'quantity': quantity,
      if (logType != null) 'log_type': logType,
      if (batchId != null) 'batch_id': batchId,
      if (supplierId != null) 'supplier_id': supplierId,
      if (note != null) 'note': note,
      if (logDate != null) 'log_date': logDate,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? itemId,
    Value<double>? quantity,
    Value<String>? logType,
    Value<String?>? batchId,
    Value<String?>? supplierId,
    Value<String?>? note,
    Value<DateTime>? logDate,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return StockLogsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      logType: logType ?? this.logType,
      batchId: batchId ?? this.batchId,
      supplierId: supplierId ?? this.supplierId,
      note: note ?? this.note,
      logDate: logDate ?? this.logDate,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (logType.present) {
      map['log_type'] = Variable<String>(logType.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockLogsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('itemId: $itemId, ')
          ..write('quantity: $quantity, ')
          ..write('logType: $logType, ')
          ..write('batchId: $batchId, ')
          ..write('supplierId: $supplierId, ')
          ..write('note: $note, ')
          ..write('logDate: $logDate, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LicenseConfigsTable extends LicenseConfigs
    with TableInfo<$LicenseConfigsTable, LicenseConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LicenseConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('OFFLINE'),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hardwareIdMeta = const VerificationMeta(
    'hardwareId',
  );
  @override
  late final GeneratedColumn<String> hardwareId = GeneratedColumn<String>(
    'hardware_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedMeta = const VerificationMeta(
    'lastUsed',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsed = GeneratedColumn<DateTime>(
    'last_used',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastCloudCheckAtMeta = const VerificationMeta(
    'lastCloudCheckAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCloudCheckAt =
      GeneratedColumn<DateTime>(
        'last_cloud_check_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    farmId,
    userId,
    hardwareId,
    installedAt,
    expiresAt,
    lastUsed,
    lastCloudCheckAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'license_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LicenseConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('hardware_id')) {
      context.handle(
        _hardwareIdMeta,
        hardwareId.isAcceptableOrUnknown(data['hardware_id']!, _hardwareIdMeta),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('last_used')) {
      context.handle(
        _lastUsedMeta,
        lastUsed.isAcceptableOrUnknown(data['last_used']!, _lastUsedMeta),
      );
    }
    if (data.containsKey('last_cloud_check_at')) {
      context.handle(
        _lastCloudCheckAtMeta,
        lastCloudCheckAt.isAcceptableOrUnknown(
          data['last_cloud_check_at']!,
          _lastCloudCheckAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LicenseConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LicenseConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      hardwareId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hardware_id'],
      ),
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      lastUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used'],
      )!,
      lastCloudCheckAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_cloud_check_at'],
      ),
    );
  }

  @override
  $LicenseConfigsTable createAlias(String alias) {
    return $LicenseConfigsTable(attachedDatabase, alias);
  }
}

class LicenseConfig extends DataClass implements Insertable<LicenseConfig> {
  /// Always 'singleton' – only one row ever exists.
  final String id;

  /// 'CLOUD_TRIAL' | 'CLOUD_ACTIVE' | 'EXPIRED' | 'HARD_LOCKED'
  final String mode;

  /// Local SQLite farm_id (may be overwritten by webFarmId after cascade)
  final String? farmId;

  /// Cloud user id after authentication
  final String? userId;

  /// Hardware fingerprint for this machine
  final String? hardwareId;

  /// Timestamp when the app was first installed/activated
  final DateTime installedAt;

  /// Timestamp when the license expires; compared on every boot
  final DateTime expiresAt;

  /// Updated on every DB write; used for anti-clock-tamper detection
  final DateTime lastUsed;

  /// Timestamp of the last successful cloud subscription check.
  /// Used for the 10-day offline tolerance window.
  /// Null means never successfully checked.
  final DateTime? lastCloudCheckAt;
  const LicenseConfig({
    required this.id,
    required this.mode,
    this.farmId,
    this.userId,
    this.hardwareId,
    required this.installedAt,
    required this.expiresAt,
    required this.lastUsed,
    this.lastCloudCheckAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || hardwareId != null) {
      map['hardware_id'] = Variable<String>(hardwareId);
    }
    map['installed_at'] = Variable<DateTime>(installedAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['last_used'] = Variable<DateTime>(lastUsed);
    if (!nullToAbsent || lastCloudCheckAt != null) {
      map['last_cloud_check_at'] = Variable<DateTime>(lastCloudCheckAt);
    }
    return map;
  }

  LicenseConfigsCompanion toCompanion(bool nullToAbsent) {
    return LicenseConfigsCompanion(
      id: Value(id),
      mode: Value(mode),
      farmId: farmId == null && nullToAbsent
          ? const Value.absent()
          : Value(farmId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      hardwareId: hardwareId == null && nullToAbsent
          ? const Value.absent()
          : Value(hardwareId),
      installedAt: Value(installedAt),
      expiresAt: Value(expiresAt),
      lastUsed: Value(lastUsed),
      lastCloudCheckAt: lastCloudCheckAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCloudCheckAt),
    );
  }

  factory LicenseConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LicenseConfig(
      id: serializer.fromJson<String>(json['id']),
      mode: serializer.fromJson<String>(json['mode']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      userId: serializer.fromJson<String?>(json['userId']),
      hardwareId: serializer.fromJson<String?>(json['hardwareId']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      lastUsed: serializer.fromJson<DateTime>(json['lastUsed']),
      lastCloudCheckAt: serializer.fromJson<DateTime?>(
        json['lastCloudCheckAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mode': serializer.toJson<String>(mode),
      'farmId': serializer.toJson<String?>(farmId),
      'userId': serializer.toJson<String?>(userId),
      'hardwareId': serializer.toJson<String?>(hardwareId),
      'installedAt': serializer.toJson<DateTime>(installedAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'lastUsed': serializer.toJson<DateTime>(lastUsed),
      'lastCloudCheckAt': serializer.toJson<DateTime?>(lastCloudCheckAt),
    };
  }

  LicenseConfig copyWith({
    String? id,
    String? mode,
    Value<String?> farmId = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    Value<String?> hardwareId = const Value.absent(),
    DateTime? installedAt,
    DateTime? expiresAt,
    DateTime? lastUsed,
    Value<DateTime?> lastCloudCheckAt = const Value.absent(),
  }) => LicenseConfig(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    farmId: farmId.present ? farmId.value : this.farmId,
    userId: userId.present ? userId.value : this.userId,
    hardwareId: hardwareId.present ? hardwareId.value : this.hardwareId,
    installedAt: installedAt ?? this.installedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    lastUsed: lastUsed ?? this.lastUsed,
    lastCloudCheckAt: lastCloudCheckAt.present
        ? lastCloudCheckAt.value
        : this.lastCloudCheckAt,
  );
  LicenseConfig copyWithCompanion(LicenseConfigsCompanion data) {
    return LicenseConfig(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      userId: data.userId.present ? data.userId.value : this.userId,
      hardwareId: data.hardwareId.present
          ? data.hardwareId.value
          : this.hardwareId,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      lastUsed: data.lastUsed.present ? data.lastUsed.value : this.lastUsed,
      lastCloudCheckAt: data.lastCloudCheckAt.present
          ? data.lastCloudCheckAt.value
          : this.lastCloudCheckAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LicenseConfig(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('hardwareId: $hardwareId, ')
          ..write('installedAt: $installedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('lastUsed: $lastUsed, ')
          ..write('lastCloudCheckAt: $lastCloudCheckAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mode,
    farmId,
    userId,
    hardwareId,
    installedAt,
    expiresAt,
    lastUsed,
    lastCloudCheckAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LicenseConfig &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.farmId == this.farmId &&
          other.userId == this.userId &&
          other.hardwareId == this.hardwareId &&
          other.installedAt == this.installedAt &&
          other.expiresAt == this.expiresAt &&
          other.lastUsed == this.lastUsed &&
          other.lastCloudCheckAt == this.lastCloudCheckAt);
}

class LicenseConfigsCompanion extends UpdateCompanion<LicenseConfig> {
  final Value<String> id;
  final Value<String> mode;
  final Value<String?> farmId;
  final Value<String?> userId;
  final Value<String?> hardwareId;
  final Value<DateTime> installedAt;
  final Value<DateTime> expiresAt;
  final Value<DateTime> lastUsed;
  final Value<DateTime?> lastCloudCheckAt;
  final Value<int> rowid;
  const LicenseConfigsCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.farmId = const Value.absent(),
    this.userId = const Value.absent(),
    this.hardwareId = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.lastUsed = const Value.absent(),
    this.lastCloudCheckAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LicenseConfigsCompanion.insert({
    required String id,
    this.mode = const Value.absent(),
    this.farmId = const Value.absent(),
    this.userId = const Value.absent(),
    this.hardwareId = const Value.absent(),
    this.installedAt = const Value.absent(),
    required DateTime expiresAt,
    this.lastUsed = const Value.absent(),
    this.lastCloudCheckAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       expiresAt = Value(expiresAt);
  static Insertable<LicenseConfig> custom({
    Expression<String>? id,
    Expression<String>? mode,
    Expression<String>? farmId,
    Expression<String>? userId,
    Expression<String>? hardwareId,
    Expression<DateTime>? installedAt,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? lastUsed,
    Expression<DateTime>? lastCloudCheckAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (farmId != null) 'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (hardwareId != null) 'hardware_id': hardwareId,
      if (installedAt != null) 'installed_at': installedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (lastUsed != null) 'last_used': lastUsed,
      if (lastCloudCheckAt != null) 'last_cloud_check_at': lastCloudCheckAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LicenseConfigsCompanion copyWith({
    Value<String>? id,
    Value<String>? mode,
    Value<String?>? farmId,
    Value<String?>? userId,
    Value<String?>? hardwareId,
    Value<DateTime>? installedAt,
    Value<DateTime>? expiresAt,
    Value<DateTime>? lastUsed,
    Value<DateTime?>? lastCloudCheckAt,
    Value<int>? rowid,
  }) {
    return LicenseConfigsCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      farmId: farmId ?? this.farmId,
      userId: userId ?? this.userId,
      hardwareId: hardwareId ?? this.hardwareId,
      installedAt: installedAt ?? this.installedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      lastUsed: lastUsed ?? this.lastUsed,
      lastCloudCheckAt: lastCloudCheckAt ?? this.lastCloudCheckAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (hardwareId.present) {
      map['hardware_id'] = Variable<String>(hardwareId.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (lastUsed.present) {
      map['last_used'] = Variable<DateTime>(lastUsed.value);
    }
    if (lastCloudCheckAt.present) {
      map['last_cloud_check_at'] = Variable<DateTime>(lastCloudCheckAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LicenseConfigsCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('hardwareId: $hardwareId, ')
          ..write('installedAt: $installedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('lastUsed: $lastUsed, ')
          ..write('lastCloudCheckAt: $lastCloudCheckAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPermissionsTable extends UserPermissions
    with TableInfo<$UserPermissionsTable, UserPermission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPermissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionKeyMeta = const VerificationMeta(
    'permissionKey',
  );
  @override
  late final GeneratedColumn<String> permissionKey = GeneratedColumn<String>(
    'permission_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allowedMeta = const VerificationMeta(
    'allowed',
  );
  @override
  late final GeneratedColumn<bool> allowed = GeneratedColumn<bool>(
    'allowed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allowed" IN (0, 1))',
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
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    userId,
    permissionKey,
    allowed,
    createdAt,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_permissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPermission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('permission_key')) {
      context.handle(
        _permissionKeyMeta,
        permissionKey.isAcceptableOrUnknown(
          data['permission_key']!,
          _permissionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_permissionKeyMeta);
    }
    if (data.containsKey('allowed')) {
      context.handle(
        _allowedMeta,
        allowed.isAcceptableOrUnknown(data['allowed']!, _allowedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPermission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPermission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      permissionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permission_key'],
      )!,
      allowed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allowed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $UserPermissionsTable createAlias(String alias) {
    return $UserPermissionsTable(attachedDatabase, alias);
  }
}

class UserPermission extends DataClass implements Insertable<UserPermission> {
  final String id;
  final String farmId;
  final String userId;
  final String permissionKey;
  final bool allowed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const UserPermission({
    required this.id,
    required this.farmId,
    required this.userId,
    required this.permissionKey,
    required this.allowed,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['user_id'] = Variable<String>(userId);
    map['permission_key'] = Variable<String>(permissionKey);
    map['allowed'] = Variable<bool>(allowed);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  UserPermissionsCompanion toCompanion(bool nullToAbsent) {
    return UserPermissionsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      userId: Value(userId),
      permissionKey: Value(permissionKey),
      allowed: Value(allowed),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory UserPermission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPermission(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      userId: serializer.fromJson<String>(json['userId']),
      permissionKey: serializer.fromJson<String>(json['permissionKey']),
      allowed: serializer.fromJson<bool>(json['allowed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'userId': serializer.toJson<String>(userId),
      'permissionKey': serializer.toJson<String>(permissionKey),
      'allowed': serializer.toJson<bool>(allowed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  UserPermission copyWith({
    String? id,
    String? farmId,
    String? userId,
    String? permissionKey,
    bool? allowed,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) => UserPermission(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    userId: userId ?? this.userId,
    permissionKey: permissionKey ?? this.permissionKey,
    allowed: allowed ?? this.allowed,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  UserPermission copyWithCompanion(UserPermissionsCompanion data) {
    return UserPermission(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      userId: data.userId.present ? data.userId.value : this.userId,
      permissionKey: data.permissionKey.present
          ? data.permissionKey.value
          : this.permissionKey,
      allowed: data.allowed.present ? data.allowed.value : this.allowed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPermission(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('permissionKey: $permissionKey, ')
          ..write('allowed: $allowed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    userId,
    permissionKey,
    allowed,
    createdAt,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPermission &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.userId == this.userId &&
          other.permissionKey == this.permissionKey &&
          other.allowed == this.allowed &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class UserPermissionsCompanion extends UpdateCompanion<UserPermission> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> userId;
  final Value<String> permissionKey;
  final Value<bool> allowed;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const UserPermissionsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.userId = const Value.absent(),
    this.permissionKey = const Value.absent(),
    this.allowed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPermissionsCompanion.insert({
    required String id,
    required String farmId,
    required String userId,
    required String permissionKey,
    this.allowed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       userId = Value(userId),
       permissionKey = Value(permissionKey);
  static Insertable<UserPermission> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? userId,
    Expression<String>? permissionKey,
    Expression<bool>? allowed,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (permissionKey != null) 'permission_key': permissionKey,
      if (allowed != null) 'allowed': allowed,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPermissionsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? userId,
    Value<String>? permissionKey,
    Value<bool>? allowed,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return UserPermissionsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      userId: userId ?? this.userId,
      permissionKey: permissionKey ?? this.permissionKey,
      allowed: allowed ?? this.allowed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (permissionKey.present) {
      map['permission_key'] = Variable<String>(permissionKey.value);
    }
    if (allowed.present) {
      map['allowed'] = Variable<bool>(allowed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPermissionsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('permissionKey: $permissionKey, ')
          ..write('allowed: $allowed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('WORKER'),
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _customPermissionsJsonMeta =
      const VerificationMeta('customPermissionsJson');
  @override
  late final GeneratedColumn<String> customPermissionsJson =
      GeneratedColumn<String>(
        'custom_permissions_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    phoneNumber,
    role,
    firstName,
    lastName,
    status,
    customPermissionsJson,
    createdAt,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('custom_permissions_json')) {
      context.handle(
        _customPermissionsJsonMeta,
        customPermissionsJson.isAcceptableOrUnknown(
          data['custom_permissions_json']!,
          _customPermissionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      ),
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      customPermissionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_permissions_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String id;
  final String farmId;
  final String phoneNumber;
  final String role;
  final String? firstName;
  final String? lastName;
  final String status;
  final String? customPermissionsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const Profile({
    required this.id,
    required this.farmId,
    required this.phoneNumber,
    required this.role,
    this.firstName,
    this.lastName,
    required this.status,
    this.customPermissionsJson,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || customPermissionsJson != null) {
      map['custom_permissions_json'] = Variable<String>(customPermissionsJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      phoneNumber: Value(phoneNumber),
      role: Value(role),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      status: Value(status),
      customPermissionsJson: customPermissionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(customPermissionsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      role: serializer.fromJson<String>(json['role']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      status: serializer.fromJson<String>(json['status']),
      customPermissionsJson: serializer.fromJson<String?>(
        json['customPermissionsJson'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'role': serializer.toJson<String>(role),
      'firstName': serializer.toJson<String?>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'status': serializer.toJson<String>(status),
      'customPermissionsJson': serializer.toJson<String?>(
        customPermissionsJson,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Profile copyWith({
    String? id,
    String? farmId,
    String? phoneNumber,
    String? role,
    Value<String?> firstName = const Value.absent(),
    Value<String?> lastName = const Value.absent(),
    String? status,
    Value<String?> customPermissionsJson = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) => Profile(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    role: role ?? this.role,
    firstName: firstName.present ? firstName.value : this.firstName,
    lastName: lastName.present ? lastName.value : this.lastName,
    status: status ?? this.status,
    customPermissionsJson: customPermissionsJson.present
        ? customPermissionsJson.value
        : this.customPermissionsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      role: data.role.present ? data.role.value : this.role,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      status: data.status.present ? data.status.value : this.status,
      customPermissionsJson: data.customPermissionsJson.present
          ? data.customPermissionsJson.value
          : this.customPermissionsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('role: $role, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('status: $status, ')
          ..write('customPermissionsJson: $customPermissionsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    phoneNumber,
    role,
    firstName,
    lastName,
    status,
    customPermissionsJson,
    createdAt,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.phoneNumber == this.phoneNumber &&
          other.role == this.role &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.status == this.status &&
          other.customPermissionsJson == this.customPermissionsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> phoneNumber;
  final Value<String> role;
  final Value<String?> firstName;
  final Value<String?> lastName;
  final Value<String> status;
  final Value<String?> customPermissionsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.role = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.status = const Value.absent(),
    this.customPermissionsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required String farmId,
    required String phoneNumber,
    this.role = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.status = const Value.absent(),
    this.customPermissionsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       phoneNumber = Value(phoneNumber);
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? phoneNumber,
    Expression<String>? role,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? status,
    Expression<String>? customPermissionsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (role != null) 'role': role,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (status != null) 'status': status,
      if (customPermissionsJson != null)
        'custom_permissions_json': customPermissionsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? phoneNumber,
    Value<String>? role,
    Value<String?>? firstName,
    Value<String?>? lastName,
    Value<String>? status,
    Value<String?>? customPermissionsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      status: status ?? this.status,
      customPermissionsJson:
          customPermissionsJson ?? this.customPermissionsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (customPermissionsJson.present) {
      map['custom_permissions_json'] = Variable<String>(
        customPermissionsJson.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('role: $role, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('status: $status, ')
          ..write('customPermissionsJson: $customPermissionsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $FarmsTable farms = $FarmsTable(this);
  late final $BatchesTable batches = $BatchesTable(this);
  late final $InventoryTable inventory = $InventoryTable(this);
  late final $FeedingLogsTable feedingLogs = $FeedingLogsTable(this);
  late final $EggProductionsTable eggProductions = $EggProductionsTable(this);
  late final $MortalitiesTable mortalities = $MortalitiesTable(this);
  late final $HousesTable houses = $HousesTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $FarmSettingsTable farmSettings = $FarmSettingsTable(this);
  late final $WeightRecordsTable weightRecords = $WeightRecordsTable(this);
  late final $DeviceRegistrationsTable deviceRegistrations =
      $DeviceRegistrationsTable(this);
  late final $FarmMembersTable farmMembers = $FarmMembersTable(this);
  late final $CloudUserIdMappingsTable cloudUserIdMappings =
      $CloudUserIdMappingsTable(this);
  late final $FeedFormulationsTable feedFormulations = $FeedFormulationsTable(
    this,
  );
  late final $FeedFormulationIngredientsTable feedFormulationIngredients =
      $FeedFormulationIngredientsTable(this);
  late final $VaccinationSchedulesTable vaccinationSchedules =
      $VaccinationSchedulesTable(this);
  late final $MedicationSchedulesTable medicationSchedules =
      $MedicationSchedulesTable(this);
  late final $HealthRecordsTable healthRecords = $HealthRecordsTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $SettlementsTable settlements = $SettlementsTable(this);
  late final $PendingDeletionsTable pendingDeletions = $PendingDeletionsTable(
    this,
  );
  late final $StockLogsTable stockLogs = $StockLogsTable(this);
  late final $LicenseConfigsTable licenseConfigs = $LicenseConfigsTable(this);
  late final $UserPermissionsTable userPermissions = $UserPermissionsTable(
    this,
  );
  late final $ProfilesTable profiles = $ProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    farms,
    batches,
    inventory,
    feedingLogs,
    eggProductions,
    mortalities,
    houses,
    customers,
    farmSettings,
    weightRecords,
    deviceRegistrations,
    farmMembers,
    cloudUserIdMappings,
    feedFormulations,
    feedFormulationIngredients,
    vaccinationSchedules,
    medicationSchedules,
    healthRecords,
    sales,
    expenses,
    settlements,
    pendingDeletions,
    stockLogs,
    licenseConfigs,
    userPermissions,
    profiles,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      Value<String?> firstname,
      Value<String?> surname,
      Value<String?> middleName,
      Value<String?> name,
      Value<String?> email,
      Value<String?> image,
      Value<String?> password,
      Value<String?> phoneNumber,
      Value<bool> mustChangePassword,
      Value<String> role,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String?> firstname,
      Value<String?> surname,
      Value<String?> middleName,
      Value<String?> name,
      Value<String?> email,
      Value<String?> image,
      Value<String?> password,
      Value<String?> phoneNumber,
      Value<bool> mustChangePassword,
      Value<String> role,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstname => $composableBuilder(
    column: $table.firstname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mustChangePassword => $composableBuilder(
    column: $table.mustChangePassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstname => $composableBuilder(
    column: $table.firstname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mustChangePassword => $composableBuilder(
    column: $table.mustChangePassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstname =>
      $composableBuilder(column: $table.firstname, builder: (column) => column);

  GeneratedColumn<String> get surname =>
      $composableBuilder(column: $table.surname, builder: (column) => column);

  GeneratedColumn<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get mustChangePassword => $composableBuilder(
    column: $table.mustChangePassword,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> firstname = const Value.absent(),
                Value<String?> surname = const Value.absent(),
                Value<String?> middleName = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> image = const Value.absent(),
                Value<String?> password = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<bool> mustChangePassword = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                firstname: firstname,
                surname: surname,
                middleName: middleName,
                name: name,
                email: email,
                image: image,
                password: password,
                phoneNumber: phoneNumber,
                mustChangePassword: mustChangePassword,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> firstname = const Value.absent(),
                Value<String?> surname = const Value.absent(),
                Value<String?> middleName = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> image = const Value.absent(),
                Value<String?> password = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<bool> mustChangePassword = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                firstname: firstname,
                surname: surname,
                middleName: middleName,
                name: name,
                email: email,
                image: image,
                password: password,
                phoneNumber: phoneNumber,
                mustChangePassword: mustChangePassword,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$FarmsTableCreateCompanionBuilder =
    FarmsCompanion Function({
      required String id,
      required String name,
      Value<String?> location,
      required int capacity,
      required String userId,
      Value<String> subscriptionTier,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$FarmsTableUpdateCompanionBuilder =
    FarmsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> location,
      Value<int> capacity,
      Value<String> userId,
      Value<String> subscriptionTier,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$FarmsTableFilterComposer extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subscriptionTier => $composableBuilder(
    column: $table.subscriptionTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FarmsTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriptionTier => $composableBuilder(
    column: $table.subscriptionTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FarmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get subscriptionTier => $composableBuilder(
    column: $table.subscriptionTier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FarmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmsTable,
          Farm,
          $$FarmsTableFilterComposer,
          $$FarmsTableOrderingComposer,
          $$FarmsTableAnnotationComposer,
          $$FarmsTableCreateCompanionBuilder,
          $$FarmsTableUpdateCompanionBuilder,
          (Farm, BaseReferences<_$AppDatabase, $FarmsTable, Farm>),
          Farm,
          PrefetchHooks Function()
        > {
  $$FarmsTableTableManager(_$AppDatabase db, $FarmsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> subscriptionTier = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmsCompanion(
                id: id,
                name: name,
                location: location,
                capacity: capacity,
                userId: userId,
                subscriptionTier: subscriptionTier,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> location = const Value.absent(),
                required int capacity,
                required String userId,
                Value<String> subscriptionTier = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmsCompanion.insert(
                id: id,
                name: name,
                location: location,
                capacity: capacity,
                userId: userId,
                subscriptionTier: subscriptionTier,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FarmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmsTable,
      Farm,
      $$FarmsTableFilterComposer,
      $$FarmsTableOrderingComposer,
      $$FarmsTableAnnotationComposer,
      $$FarmsTableCreateCompanionBuilder,
      $$FarmsTableUpdateCompanionBuilder,
      (Farm, BaseReferences<_$AppDatabase, $FarmsTable, Farm>),
      Farm,
      PrefetchHooks Function()
    >;
typedef $$BatchesTableCreateCompanionBuilder =
    BatchesCompanion Function({
      required String id,
      required String farmId,
      Value<String?> houseId,
      Value<String?> userId,
      Value<String> batchName,
      Value<String> type,
      Value<String> status,
      Value<String?> breedType,
      required DateTime arrivalDate,
      required int currentCount,
      required int initialCount,
      Value<int> isolationCount,
      Value<double?> initialActualCost,
      Value<String?> growthTarget,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$BatchesTableUpdateCompanionBuilder =
    BatchesCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String?> houseId,
      Value<String?> userId,
      Value<String> batchName,
      Value<String> type,
      Value<String> status,
      Value<String?> breedType,
      Value<DateTime> arrivalDate,
      Value<int> currentCount,
      Value<int> initialCount,
      Value<int> isolationCount,
      Value<double?> initialActualCost,
      Value<String?> growthTarget,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$BatchesTableFilterComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchName => $composableBuilder(
    column: $table.batchName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breedType => $composableBuilder(
    column: $table.breedType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arrivalDate => $composableBuilder(
    column: $table.arrivalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialCount => $composableBuilder(
    column: $table.initialCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isolationCount => $composableBuilder(
    column: $table.isolationCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialActualCost => $composableBuilder(
    column: $table.initialActualCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get growthTarget => $composableBuilder(
    column: $table.growthTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchName => $composableBuilder(
    column: $table.batchName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breedType => $composableBuilder(
    column: $table.breedType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arrivalDate => $composableBuilder(
    column: $table.arrivalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialCount => $composableBuilder(
    column: $table.initialCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isolationCount => $composableBuilder(
    column: $table.isolationCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialActualCost => $composableBuilder(
    column: $table.initialActualCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get growthTarget => $composableBuilder(
    column: $table.growthTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get batchName =>
      $composableBuilder(column: $table.batchName, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get breedType =>
      $composableBuilder(column: $table.breedType, builder: (column) => column);

  GeneratedColumn<DateTime> get arrivalDate => $composableBuilder(
    column: $table.arrivalDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initialCount => $composableBuilder(
    column: $table.initialCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isolationCount => $composableBuilder(
    column: $table.isolationCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get initialActualCost => $composableBuilder(
    column: $table.initialActualCost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get growthTarget => $composableBuilder(
    column: $table.growthTarget,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$BatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatchesTable,
          Batch,
          $$BatchesTableFilterComposer,
          $$BatchesTableOrderingComposer,
          $$BatchesTableAnnotationComposer,
          $$BatchesTableCreateCompanionBuilder,
          $$BatchesTableUpdateCompanionBuilder,
          (Batch, BaseReferences<_$AppDatabase, $BatchesTable, Batch>),
          Batch,
          PrefetchHooks Function()
        > {
  $$BatchesTableTableManager(_$AppDatabase db, $BatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String?> houseId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> batchName = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> breedType = const Value.absent(),
                Value<DateTime> arrivalDate = const Value.absent(),
                Value<int> currentCount = const Value.absent(),
                Value<int> initialCount = const Value.absent(),
                Value<int> isolationCount = const Value.absent(),
                Value<double?> initialActualCost = const Value.absent(),
                Value<String?> growthTarget = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion(
                id: id,
                farmId: farmId,
                houseId: houseId,
                userId: userId,
                batchName: batchName,
                type: type,
                status: status,
                breedType: breedType,
                arrivalDate: arrivalDate,
                currentCount: currentCount,
                initialCount: initialCount,
                isolationCount: isolationCount,
                initialActualCost: initialActualCost,
                growthTarget: growthTarget,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                Value<String?> houseId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> batchName = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> breedType = const Value.absent(),
                required DateTime arrivalDate,
                required int currentCount,
                required int initialCount,
                Value<int> isolationCount = const Value.absent(),
                Value<double?> initialActualCost = const Value.absent(),
                Value<String?> growthTarget = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion.insert(
                id: id,
                farmId: farmId,
                houseId: houseId,
                userId: userId,
                batchName: batchName,
                type: type,
                status: status,
                breedType: breedType,
                arrivalDate: arrivalDate,
                currentCount: currentCount,
                initialCount: initialCount,
                isolationCount: isolationCount,
                initialActualCost: initialActualCost,
                growthTarget: growthTarget,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatchesTable,
      Batch,
      $$BatchesTableFilterComposer,
      $$BatchesTableOrderingComposer,
      $$BatchesTableAnnotationComposer,
      $$BatchesTableCreateCompanionBuilder,
      $$BatchesTableUpdateCompanionBuilder,
      (Batch, BaseReferences<_$AppDatabase, $BatchesTable, Batch>),
      Batch,
      PrefetchHooks Function()
    >;
typedef $$InventoryTableCreateCompanionBuilder =
    InventoryCompanion Function({
      required String id,
      required String farmId,
      Value<String?> userId,
      required String itemName,
      required double stockLevel,
      Value<double?> reorderLevel,
      required String unit,
      Value<String?> category,
      Value<double?> costPerUnit,
      Value<String?> eggCategoryId,
      Value<String?> usageType,
      Value<String?> supplierId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$InventoryTableUpdateCompanionBuilder =
    InventoryCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String?> userId,
      Value<String> itemName,
      Value<double> stockLevel,
      Value<double?> reorderLevel,
      Value<String> unit,
      Value<String?> category,
      Value<double?> costPerUnit,
      Value<String?> eggCategoryId,
      Value<String?> usageType,
      Value<String?> supplierId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$InventoryTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockLevel => $composableBuilder(
    column: $table.stockLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eggCategoryId => $composableBuilder(
    column: $table.eggCategoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageType => $composableBuilder(
    column: $table.usageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InventoryTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockLevel => $composableBuilder(
    column: $table.stockLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eggCategoryId => $composableBuilder(
    column: $table.eggCategoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageType => $composableBuilder(
    column: $table.usageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<double> get stockLevel => $composableBuilder(
    column: $table.stockLevel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eggCategoryId => $composableBuilder(
    column: $table.eggCategoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get usageType =>
      $composableBuilder(column: $table.usageType, builder: (column) => column);

  GeneratedColumn<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$InventoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryTable,
          InventoryItem,
          $$InventoryTableFilterComposer,
          $$InventoryTableOrderingComposer,
          $$InventoryTableAnnotationComposer,
          $$InventoryTableCreateCompanionBuilder,
          $$InventoryTableUpdateCompanionBuilder,
          (
            InventoryItem,
            BaseReferences<_$AppDatabase, $InventoryTable, InventoryItem>,
          ),
          InventoryItem,
          PrefetchHooks Function()
        > {
  $$InventoryTableTableManager(_$AppDatabase db, $InventoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> itemName = const Value.absent(),
                Value<double> stockLevel = const Value.absent(),
                Value<double?> reorderLevel = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<double?> costPerUnit = const Value.absent(),
                Value<String?> eggCategoryId = const Value.absent(),
                Value<String?> usageType = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryCompanion(
                id: id,
                farmId: farmId,
                userId: userId,
                itemName: itemName,
                stockLevel: stockLevel,
                reorderLevel: reorderLevel,
                unit: unit,
                category: category,
                costPerUnit: costPerUnit,
                eggCategoryId: eggCategoryId,
                usageType: usageType,
                supplierId: supplierId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                Value<String?> userId = const Value.absent(),
                required String itemName,
                required double stockLevel,
                Value<double?> reorderLevel = const Value.absent(),
                required String unit,
                Value<String?> category = const Value.absent(),
                Value<double?> costPerUnit = const Value.absent(),
                Value<String?> eggCategoryId = const Value.absent(),
                Value<String?> usageType = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryCompanion.insert(
                id: id,
                farmId: farmId,
                userId: userId,
                itemName: itemName,
                stockLevel: stockLevel,
                reorderLevel: reorderLevel,
                unit: unit,
                category: category,
                costPerUnit: costPerUnit,
                eggCategoryId: eggCategoryId,
                usageType: usageType,
                supplierId: supplierId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InventoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryTable,
      InventoryItem,
      $$InventoryTableFilterComposer,
      $$InventoryTableOrderingComposer,
      $$InventoryTableAnnotationComposer,
      $$InventoryTableCreateCompanionBuilder,
      $$InventoryTableUpdateCompanionBuilder,
      (
        InventoryItem,
        BaseReferences<_$AppDatabase, $InventoryTable, InventoryItem>,
      ),
      InventoryItem,
      PrefetchHooks Function()
    >;
typedef $$FeedingLogsTableCreateCompanionBuilder =
    FeedingLogsCompanion Function({
      required String id,
      required String farmId,
      Value<String?> batchId,
      Value<String?> feedTypeId,
      Value<String?> formulationId,
      required double amountConsumed,
      required DateTime logDate,
      Value<String?> userId,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$FeedingLogsTableUpdateCompanionBuilder =
    FeedingLogsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String?> batchId,
      Value<String?> feedTypeId,
      Value<String?> formulationId,
      Value<double> amountConsumed,
      Value<DateTime> logDate,
      Value<String?> userId,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$FeedingLogsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedingLogsTable> {
  $$FeedingLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedTypeId => $composableBuilder(
    column: $table.feedTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formulationId => $composableBuilder(
    column: $table.formulationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountConsumed => $composableBuilder(
    column: $table.amountConsumed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedingLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedingLogsTable> {
  $$FeedingLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedTypeId => $composableBuilder(
    column: $table.feedTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formulationId => $composableBuilder(
    column: $table.formulationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountConsumed => $composableBuilder(
    column: $table.amountConsumed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedingLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedingLogsTable> {
  $$FeedingLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get feedTypeId => $composableBuilder(
    column: $table.feedTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get formulationId => $composableBuilder(
    column: $table.formulationId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountConsumed => $composableBuilder(
    column: $table.amountConsumed,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$FeedingLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedingLogsTable,
          FeedingLog,
          $$FeedingLogsTableFilterComposer,
          $$FeedingLogsTableOrderingComposer,
          $$FeedingLogsTableAnnotationComposer,
          $$FeedingLogsTableCreateCompanionBuilder,
          $$FeedingLogsTableUpdateCompanionBuilder,
          (
            FeedingLog,
            BaseReferences<_$AppDatabase, $FeedingLogsTable, FeedingLog>,
          ),
          FeedingLog,
          PrefetchHooks Function()
        > {
  $$FeedingLogsTableTableManager(_$AppDatabase db, $FeedingLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedingLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedingLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedingLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String?> feedTypeId = const Value.absent(),
                Value<String?> formulationId = const Value.absent(),
                Value<double> amountConsumed = const Value.absent(),
                Value<DateTime> logDate = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedingLogsCompanion(
                id: id,
                farmId: farmId,
                batchId: batchId,
                feedTypeId: feedTypeId,
                formulationId: formulationId,
                amountConsumed: amountConsumed,
                logDate: logDate,
                userId: userId,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                Value<String?> batchId = const Value.absent(),
                Value<String?> feedTypeId = const Value.absent(),
                Value<String?> formulationId = const Value.absent(),
                required double amountConsumed,
                required DateTime logDate,
                Value<String?> userId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedingLogsCompanion.insert(
                id: id,
                farmId: farmId,
                batchId: batchId,
                feedTypeId: feedTypeId,
                formulationId: formulationId,
                amountConsumed: amountConsumed,
                logDate: logDate,
                userId: userId,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedingLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedingLogsTable,
      FeedingLog,
      $$FeedingLogsTableFilterComposer,
      $$FeedingLogsTableOrderingComposer,
      $$FeedingLogsTableAnnotationComposer,
      $$FeedingLogsTableCreateCompanionBuilder,
      $$FeedingLogsTableUpdateCompanionBuilder,
      (
        FeedingLog,
        BaseReferences<_$AppDatabase, $FeedingLogsTable, FeedingLog>,
      ),
      FeedingLog,
      PrefetchHooks Function()
    >;
typedef $$EggProductionsTableCreateCompanionBuilder =
    EggProductionsCompanion Function({
      required String id,
      required String farmId,
      required String batchId,
      Value<String?> categoryId,
      required int eggsCollected,
      Value<int> unusableCount,
      Value<int> eggsRemaining,
      Value<double?> cratesCollected,
      Value<String?> qualityGrade,
      Value<bool> isSorted,
      Value<int> smallCount,
      Value<int> mediumCount,
      Value<int> largeCount,
      required DateTime logDate,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$EggProductionsTableUpdateCompanionBuilder =
    EggProductionsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> batchId,
      Value<String?> categoryId,
      Value<int> eggsCollected,
      Value<int> unusableCount,
      Value<int> eggsRemaining,
      Value<double?> cratesCollected,
      Value<String?> qualityGrade,
      Value<bool> isSorted,
      Value<int> smallCount,
      Value<int> mediumCount,
      Value<int> largeCount,
      Value<DateTime> logDate,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$EggProductionsTableFilterComposer
    extends Composer<_$AppDatabase, $EggProductionsTable> {
  $$EggProductionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eggsCollected => $composableBuilder(
    column: $table.eggsCollected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unusableCount => $composableBuilder(
    column: $table.unusableCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eggsRemaining => $composableBuilder(
    column: $table.eggsRemaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cratesCollected => $composableBuilder(
    column: $table.cratesCollected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qualityGrade => $composableBuilder(
    column: $table.qualityGrade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSorted => $composableBuilder(
    column: $table.isSorted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get smallCount => $composableBuilder(
    column: $table.smallCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediumCount => $composableBuilder(
    column: $table.mediumCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get largeCount => $composableBuilder(
    column: $table.largeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EggProductionsTableOrderingComposer
    extends Composer<_$AppDatabase, $EggProductionsTable> {
  $$EggProductionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eggsCollected => $composableBuilder(
    column: $table.eggsCollected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unusableCount => $composableBuilder(
    column: $table.unusableCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eggsRemaining => $composableBuilder(
    column: $table.eggsRemaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cratesCollected => $composableBuilder(
    column: $table.cratesCollected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qualityGrade => $composableBuilder(
    column: $table.qualityGrade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSorted => $composableBuilder(
    column: $table.isSorted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get smallCount => $composableBuilder(
    column: $table.smallCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediumCount => $composableBuilder(
    column: $table.mediumCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get largeCount => $composableBuilder(
    column: $table.largeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EggProductionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EggProductionsTable> {
  $$EggProductionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eggsCollected => $composableBuilder(
    column: $table.eggsCollected,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unusableCount => $composableBuilder(
    column: $table.unusableCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eggsRemaining => $composableBuilder(
    column: $table.eggsRemaining,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cratesCollected => $composableBuilder(
    column: $table.cratesCollected,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qualityGrade => $composableBuilder(
    column: $table.qualityGrade,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSorted =>
      $composableBuilder(column: $table.isSorted, builder: (column) => column);

  GeneratedColumn<int> get smallCount => $composableBuilder(
    column: $table.smallCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mediumCount => $composableBuilder(
    column: $table.mediumCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get largeCount => $composableBuilder(
    column: $table.largeCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$EggProductionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EggProductionsTable,
          EggProduction,
          $$EggProductionsTableFilterComposer,
          $$EggProductionsTableOrderingComposer,
          $$EggProductionsTableAnnotationComposer,
          $$EggProductionsTableCreateCompanionBuilder,
          $$EggProductionsTableUpdateCompanionBuilder,
          (
            EggProduction,
            BaseReferences<_$AppDatabase, $EggProductionsTable, EggProduction>,
          ),
          EggProduction,
          PrefetchHooks Function()
        > {
  $$EggProductionsTableTableManager(
    _$AppDatabase db,
    $EggProductionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EggProductionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EggProductionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EggProductionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int> eggsCollected = const Value.absent(),
                Value<int> unusableCount = const Value.absent(),
                Value<int> eggsRemaining = const Value.absent(),
                Value<double?> cratesCollected = const Value.absent(),
                Value<String?> qualityGrade = const Value.absent(),
                Value<bool> isSorted = const Value.absent(),
                Value<int> smallCount = const Value.absent(),
                Value<int> mediumCount = const Value.absent(),
                Value<int> largeCount = const Value.absent(),
                Value<DateTime> logDate = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EggProductionsCompanion(
                id: id,
                farmId: farmId,
                batchId: batchId,
                categoryId: categoryId,
                eggsCollected: eggsCollected,
                unusableCount: unusableCount,
                eggsRemaining: eggsRemaining,
                cratesCollected: cratesCollected,
                qualityGrade: qualityGrade,
                isSorted: isSorted,
                smallCount: smallCount,
                mediumCount: mediumCount,
                largeCount: largeCount,
                logDate: logDate,
                userId: userId,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required String batchId,
                Value<String?> categoryId = const Value.absent(),
                required int eggsCollected,
                Value<int> unusableCount = const Value.absent(),
                Value<int> eggsRemaining = const Value.absent(),
                Value<double?> cratesCollected = const Value.absent(),
                Value<String?> qualityGrade = const Value.absent(),
                Value<bool> isSorted = const Value.absent(),
                Value<int> smallCount = const Value.absent(),
                Value<int> mediumCount = const Value.absent(),
                Value<int> largeCount = const Value.absent(),
                required DateTime logDate,
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EggProductionsCompanion.insert(
                id: id,
                farmId: farmId,
                batchId: batchId,
                categoryId: categoryId,
                eggsCollected: eggsCollected,
                unusableCount: unusableCount,
                eggsRemaining: eggsRemaining,
                cratesCollected: cratesCollected,
                qualityGrade: qualityGrade,
                isSorted: isSorted,
                smallCount: smallCount,
                mediumCount: mediumCount,
                largeCount: largeCount,
                logDate: logDate,
                userId: userId,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EggProductionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EggProductionsTable,
      EggProduction,
      $$EggProductionsTableFilterComposer,
      $$EggProductionsTableOrderingComposer,
      $$EggProductionsTableAnnotationComposer,
      $$EggProductionsTableCreateCompanionBuilder,
      $$EggProductionsTableUpdateCompanionBuilder,
      (
        EggProduction,
        BaseReferences<_$AppDatabase, $EggProductionsTable, EggProduction>,
      ),
      EggProduction,
      PrefetchHooks Function()
    >;
typedef $$MortalitiesTableCreateCompanionBuilder =
    MortalitiesCompanion Function({
      required String id,
      required String farmId,
      required String batchId,
      required int count,
      Value<String?> reason,
      Value<String?> category,
      Value<String?> subCategory,
      Value<String> healthType,
      Value<String?> isolationRoomId,
      required DateTime logDate,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$MortalitiesTableUpdateCompanionBuilder =
    MortalitiesCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> batchId,
      Value<int> count,
      Value<String?> reason,
      Value<String?> category,
      Value<String?> subCategory,
      Value<String> healthType,
      Value<String?> isolationRoomId,
      Value<DateTime> logDate,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$MortalitiesTableFilterComposer
    extends Composer<_$AppDatabase, $MortalitiesTable> {
  $$MortalitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subCategory => $composableBuilder(
    column: $table.subCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get healthType => $composableBuilder(
    column: $table.healthType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isolationRoomId => $composableBuilder(
    column: $table.isolationRoomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MortalitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $MortalitiesTable> {
  $$MortalitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subCategory => $composableBuilder(
    column: $table.subCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get healthType => $composableBuilder(
    column: $table.healthType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isolationRoomId => $composableBuilder(
    column: $table.isolationRoomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MortalitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MortalitiesTable> {
  $$MortalitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subCategory => $composableBuilder(
    column: $table.subCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get healthType => $composableBuilder(
    column: $table.healthType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get isolationRoomId => $composableBuilder(
    column: $table.isolationRoomId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$MortalitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MortalitiesTable,
          Mortality,
          $$MortalitiesTableFilterComposer,
          $$MortalitiesTableOrderingComposer,
          $$MortalitiesTableAnnotationComposer,
          $$MortalitiesTableCreateCompanionBuilder,
          $$MortalitiesTableUpdateCompanionBuilder,
          (
            Mortality,
            BaseReferences<_$AppDatabase, $MortalitiesTable, Mortality>,
          ),
          Mortality,
          PrefetchHooks Function()
        > {
  $$MortalitiesTableTableManager(_$AppDatabase db, $MortalitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MortalitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MortalitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MortalitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> subCategory = const Value.absent(),
                Value<String> healthType = const Value.absent(),
                Value<String?> isolationRoomId = const Value.absent(),
                Value<DateTime> logDate = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MortalitiesCompanion(
                id: id,
                farmId: farmId,
                batchId: batchId,
                count: count,
                reason: reason,
                category: category,
                subCategory: subCategory,
                healthType: healthType,
                isolationRoomId: isolationRoomId,
                logDate: logDate,
                userId: userId,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required String batchId,
                required int count,
                Value<String?> reason = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> subCategory = const Value.absent(),
                Value<String> healthType = const Value.absent(),
                Value<String?> isolationRoomId = const Value.absent(),
                required DateTime logDate,
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MortalitiesCompanion.insert(
                id: id,
                farmId: farmId,
                batchId: batchId,
                count: count,
                reason: reason,
                category: category,
                subCategory: subCategory,
                healthType: healthType,
                isolationRoomId: isolationRoomId,
                logDate: logDate,
                userId: userId,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MortalitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MortalitiesTable,
      Mortality,
      $$MortalitiesTableFilterComposer,
      $$MortalitiesTableOrderingComposer,
      $$MortalitiesTableAnnotationComposer,
      $$MortalitiesTableCreateCompanionBuilder,
      $$MortalitiesTableUpdateCompanionBuilder,
      (Mortality, BaseReferences<_$AppDatabase, $MortalitiesTable, Mortality>),
      Mortality,
      PrefetchHooks Function()
    >;
typedef $$HousesTableCreateCompanionBuilder =
    HousesCompanion Function({
      required String id,
      required String farmId,
      Value<String?> userId,
      required String name,
      required int capacity,
      Value<double?> currentTemperature,
      Value<double?> currentHumidity,
      Value<bool> isIsolation,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$HousesTableUpdateCompanionBuilder =
    HousesCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String?> userId,
      Value<String> name,
      Value<int> capacity,
      Value<double?> currentTemperature,
      Value<double?> currentHumidity,
      Value<bool> isIsolation,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$HousesTableFilterComposer
    extends Composer<_$AppDatabase, $HousesTable> {
  $$HousesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentTemperature => $composableBuilder(
    column: $table.currentTemperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentHumidity => $composableBuilder(
    column: $table.currentHumidity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIsolation => $composableBuilder(
    column: $table.isIsolation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HousesTableOrderingComposer
    extends Composer<_$AppDatabase, $HousesTable> {
  $$HousesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentTemperature => $composableBuilder(
    column: $table.currentTemperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentHumidity => $composableBuilder(
    column: $table.currentHumidity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIsolation => $composableBuilder(
    column: $table.isIsolation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HousesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HousesTable> {
  $$HousesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<double> get currentTemperature => $composableBuilder(
    column: $table.currentTemperature,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentHumidity => $composableBuilder(
    column: $table.currentHumidity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIsolation => $composableBuilder(
    column: $table.isIsolation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$HousesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HousesTable,
          House,
          $$HousesTableFilterComposer,
          $$HousesTableOrderingComposer,
          $$HousesTableAnnotationComposer,
          $$HousesTableCreateCompanionBuilder,
          $$HousesTableUpdateCompanionBuilder,
          (House, BaseReferences<_$AppDatabase, $HousesTable, House>),
          House,
          PrefetchHooks Function()
        > {
  $$HousesTableTableManager(_$AppDatabase db, $HousesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HousesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HousesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HousesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<double?> currentTemperature = const Value.absent(),
                Value<double?> currentHumidity = const Value.absent(),
                Value<bool> isIsolation = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HousesCompanion(
                id: id,
                farmId: farmId,
                userId: userId,
                name: name,
                capacity: capacity,
                currentTemperature: currentTemperature,
                currentHumidity: currentHumidity,
                isIsolation: isIsolation,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                Value<String?> userId = const Value.absent(),
                required String name,
                required int capacity,
                Value<double?> currentTemperature = const Value.absent(),
                Value<double?> currentHumidity = const Value.absent(),
                Value<bool> isIsolation = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HousesCompanion.insert(
                id: id,
                farmId: farmId,
                userId: userId,
                name: name,
                capacity: capacity,
                currentTemperature: currentTemperature,
                currentHumidity: currentHumidity,
                isIsolation: isIsolation,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HousesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HousesTable,
      House,
      $$HousesTableFilterComposer,
      $$HousesTableOrderingComposer,
      $$HousesTableAnnotationComposer,
      $$HousesTableCreateCompanionBuilder,
      $$HousesTableUpdateCompanionBuilder,
      (House, BaseReferences<_$AppDatabase, $HousesTable, House>),
      House,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      required String id,
      required String farmId,
      required String name,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> address,
      Value<double> balanceOwed,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> customerType,
      Value<String?> supplyItems,
      Value<String?> contactPerson,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> name,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> address,
      Value<double> balanceOwed,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> customerType,
      Value<String?> supplyItems,
      Value<String?> contactPerson,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
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

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balanceOwed => $composableBuilder(
    column: $table.balanceOwed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerType => $composableBuilder(
    column: $table.customerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplyItems => $composableBuilder(
    column: $table.supplyItems,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
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

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balanceOwed => $composableBuilder(
    column: $table.balanceOwed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerType => $composableBuilder(
    column: $table.customerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplyItems => $composableBuilder(
    column: $table.supplyItems,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get balanceOwed => $composableBuilder(
    column: $table.balanceOwed,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get customerType => $composableBuilder(
    column: $table.customerType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplyItems => $composableBuilder(
    column: $table.supplyItems,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
          Customer,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<double> balanceOwed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> customerType = const Value.absent(),
                Value<String?> supplyItems = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                farmId: farmId,
                name: name,
                phone: phone,
                email: email,
                address: address,
                balanceOwed: balanceOwed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                customerType: customerType,
                supplyItems: supplyItems,
                contactPerson: contactPerson,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<double> balanceOwed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> customerType = const Value.absent(),
                Value<String?> supplyItems = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                farmId: farmId,
                name: name,
                phone: phone,
                email: email,
                address: address,
                balanceOwed: balanceOwed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                customerType: customerType,
                supplyItems: supplyItems,
                contactPerson: contactPerson,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
      Customer,
      PrefetchHooks Function()
    >;
typedef $$FarmSettingsTableCreateCompanionBuilder =
    FarmSettingsCompanion Function({
      required String id,
      required String farmId,
      Value<String> currency,
      Value<String?> eggRecordReminderTime,
      Value<String?> feedRecordReminderTime,
      Value<int?> growthTargetStandard,
      Value<int> eggsPerCrate,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$FarmSettingsTableUpdateCompanionBuilder =
    FarmSettingsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> currency,
      Value<String?> eggRecordReminderTime,
      Value<String?> feedRecordReminderTime,
      Value<int?> growthTargetStandard,
      Value<int> eggsPerCrate,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$FarmSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $FarmSettingsTable> {
  $$FarmSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eggRecordReminderTime => $composableBuilder(
    column: $table.eggRecordReminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedRecordReminderTime => $composableBuilder(
    column: $table.feedRecordReminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get growthTargetStandard => $composableBuilder(
    column: $table.growthTargetStandard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eggsPerCrate => $composableBuilder(
    column: $table.eggsPerCrate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FarmSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmSettingsTable> {
  $$FarmSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eggRecordReminderTime => $composableBuilder(
    column: $table.eggRecordReminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedRecordReminderTime => $composableBuilder(
    column: $table.feedRecordReminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get growthTargetStandard => $composableBuilder(
    column: $table.growthTargetStandard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eggsPerCrate => $composableBuilder(
    column: $table.eggsPerCrate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FarmSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmSettingsTable> {
  $$FarmSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get eggRecordReminderTime => $composableBuilder(
    column: $table.eggRecordReminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedRecordReminderTime => $composableBuilder(
    column: $table.feedRecordReminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get growthTargetStandard => $composableBuilder(
    column: $table.growthTargetStandard,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eggsPerCrate => $composableBuilder(
    column: $table.eggsPerCrate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$FarmSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmSettingsTable,
          FarmSetting,
          $$FarmSettingsTableFilterComposer,
          $$FarmSettingsTableOrderingComposer,
          $$FarmSettingsTableAnnotationComposer,
          $$FarmSettingsTableCreateCompanionBuilder,
          $$FarmSettingsTableUpdateCompanionBuilder,
          (
            FarmSetting,
            BaseReferences<_$AppDatabase, $FarmSettingsTable, FarmSetting>,
          ),
          FarmSetting,
          PrefetchHooks Function()
        > {
  $$FarmSettingsTableTableManager(_$AppDatabase db, $FarmSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> eggRecordReminderTime = const Value.absent(),
                Value<String?> feedRecordReminderTime = const Value.absent(),
                Value<int?> growthTargetStandard = const Value.absent(),
                Value<int> eggsPerCrate = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmSettingsCompanion(
                id: id,
                farmId: farmId,
                currency: currency,
                eggRecordReminderTime: eggRecordReminderTime,
                feedRecordReminderTime: feedRecordReminderTime,
                growthTargetStandard: growthTargetStandard,
                eggsPerCrate: eggsPerCrate,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                Value<String> currency = const Value.absent(),
                Value<String?> eggRecordReminderTime = const Value.absent(),
                Value<String?> feedRecordReminderTime = const Value.absent(),
                Value<int?> growthTargetStandard = const Value.absent(),
                Value<int> eggsPerCrate = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmSettingsCompanion.insert(
                id: id,
                farmId: farmId,
                currency: currency,
                eggRecordReminderTime: eggRecordReminderTime,
                feedRecordReminderTime: feedRecordReminderTime,
                growthTargetStandard: growthTargetStandard,
                eggsPerCrate: eggsPerCrate,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FarmSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmSettingsTable,
      FarmSetting,
      $$FarmSettingsTableFilterComposer,
      $$FarmSettingsTableOrderingComposer,
      $$FarmSettingsTableAnnotationComposer,
      $$FarmSettingsTableCreateCompanionBuilder,
      $$FarmSettingsTableUpdateCompanionBuilder,
      (
        FarmSetting,
        BaseReferences<_$AppDatabase, $FarmSettingsTable, FarmSetting>,
      ),
      FarmSetting,
      PrefetchHooks Function()
    >;
typedef $$WeightRecordsTableCreateCompanionBuilder =
    WeightRecordsCompanion Function({
      required String id,
      required String farmId,
      required String batchId,
      required double averageWeight,
      required DateTime logDate,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$WeightRecordsTableUpdateCompanionBuilder =
    WeightRecordsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> batchId,
      Value<double> averageWeight,
      Value<DateTime> logDate,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$WeightRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WeightRecordsTable> {
  $$WeightRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageWeight => $composableBuilder(
    column: $table.averageWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightRecordsTable> {
  $$WeightRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageWeight => $composableBuilder(
    column: $table.averageWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightRecordsTable> {
  $$WeightRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<double> get averageWeight => $composableBuilder(
    column: $table.averageWeight,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$WeightRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightRecordsTable,
          WeightRecord,
          $$WeightRecordsTableFilterComposer,
          $$WeightRecordsTableOrderingComposer,
          $$WeightRecordsTableAnnotationComposer,
          $$WeightRecordsTableCreateCompanionBuilder,
          $$WeightRecordsTableUpdateCompanionBuilder,
          (
            WeightRecord,
            BaseReferences<_$AppDatabase, $WeightRecordsTable, WeightRecord>,
          ),
          WeightRecord,
          PrefetchHooks Function()
        > {
  $$WeightRecordsTableTableManager(_$AppDatabase db, $WeightRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<double> averageWeight = const Value.absent(),
                Value<DateTime> logDate = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightRecordsCompanion(
                id: id,
                farmId: farmId,
                batchId: batchId,
                averageWeight: averageWeight,
                logDate: logDate,
                userId: userId,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required String batchId,
                required double averageWeight,
                required DateTime logDate,
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightRecordsCompanion.insert(
                id: id,
                farmId: farmId,
                batchId: batchId,
                averageWeight: averageWeight,
                logDate: logDate,
                userId: userId,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightRecordsTable,
      WeightRecord,
      $$WeightRecordsTableFilterComposer,
      $$WeightRecordsTableOrderingComposer,
      $$WeightRecordsTableAnnotationComposer,
      $$WeightRecordsTableCreateCompanionBuilder,
      $$WeightRecordsTableUpdateCompanionBuilder,
      (
        WeightRecord,
        BaseReferences<_$AppDatabase, $WeightRecordsTable, WeightRecord>,
      ),
      WeightRecord,
      PrefetchHooks Function()
    >;
typedef $$DeviceRegistrationsTableCreateCompanionBuilder =
    DeviceRegistrationsCompanion Function({
      required String id,
      required String farmId,
      required String userId,
      required String deviceIdentifier,
      Value<String?> deviceName,
      Value<DateTime> registeredAt,
      Value<int> rowid,
    });
typedef $$DeviceRegistrationsTableUpdateCompanionBuilder =
    DeviceRegistrationsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> userId,
      Value<String> deviceIdentifier,
      Value<String?> deviceName,
      Value<DateTime> registeredAt,
      Value<int> rowid,
    });

class $$DeviceRegistrationsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceRegistrationsTable> {
  $$DeviceRegistrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceIdentifier => $composableBuilder(
    column: $table.deviceIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviceRegistrationsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceRegistrationsTable> {
  $$DeviceRegistrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceIdentifier => $composableBuilder(
    column: $table.deviceIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceRegistrationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceRegistrationsTable> {
  $$DeviceRegistrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceIdentifier => $composableBuilder(
    column: $table.deviceIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => column,
  );
}

class $$DeviceRegistrationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceRegistrationsTable,
          DeviceRegistration,
          $$DeviceRegistrationsTableFilterComposer,
          $$DeviceRegistrationsTableOrderingComposer,
          $$DeviceRegistrationsTableAnnotationComposer,
          $$DeviceRegistrationsTableCreateCompanionBuilder,
          $$DeviceRegistrationsTableUpdateCompanionBuilder,
          (
            DeviceRegistration,
            BaseReferences<
              _$AppDatabase,
              $DeviceRegistrationsTable,
              DeviceRegistration
            >,
          ),
          DeviceRegistration,
          PrefetchHooks Function()
        > {
  $$DeviceRegistrationsTableTableManager(
    _$AppDatabase db,
    $DeviceRegistrationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceRegistrationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceRegistrationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DeviceRegistrationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> deviceIdentifier = const Value.absent(),
                Value<String?> deviceName = const Value.absent(),
                Value<DateTime> registeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceRegistrationsCompanion(
                id: id,
                farmId: farmId,
                userId: userId,
                deviceIdentifier: deviceIdentifier,
                deviceName: deviceName,
                registeredAt: registeredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required String userId,
                required String deviceIdentifier,
                Value<String?> deviceName = const Value.absent(),
                Value<DateTime> registeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceRegistrationsCompanion.insert(
                id: id,
                farmId: farmId,
                userId: userId,
                deviceIdentifier: deviceIdentifier,
                deviceName: deviceName,
                registeredAt: registeredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceRegistrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceRegistrationsTable,
      DeviceRegistration,
      $$DeviceRegistrationsTableFilterComposer,
      $$DeviceRegistrationsTableOrderingComposer,
      $$DeviceRegistrationsTableAnnotationComposer,
      $$DeviceRegistrationsTableCreateCompanionBuilder,
      $$DeviceRegistrationsTableUpdateCompanionBuilder,
      (
        DeviceRegistration,
        BaseReferences<
          _$AppDatabase,
          $DeviceRegistrationsTable,
          DeviceRegistration
        >,
      ),
      DeviceRegistration,
      PrefetchHooks Function()
    >;
typedef $$FarmMembersTableCreateCompanionBuilder =
    FarmMembersCompanion Function({
      required String id,
      required String farmId,
      required String userId,
      Value<String> role,
      Value<DateTime> joinedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$FarmMembersTableUpdateCompanionBuilder =
    FarmMembersCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> userId,
      Value<String> role,
      Value<DateTime> joinedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$FarmMembersTableFilterComposer
    extends Composer<_$AppDatabase, $FarmMembersTable> {
  $$FarmMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FarmMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmMembersTable> {
  $$FarmMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FarmMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmMembersTable> {
  $$FarmMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$FarmMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmMembersTable,
          FarmMember,
          $$FarmMembersTableFilterComposer,
          $$FarmMembersTableOrderingComposer,
          $$FarmMembersTableAnnotationComposer,
          $$FarmMembersTableCreateCompanionBuilder,
          $$FarmMembersTableUpdateCompanionBuilder,
          (
            FarmMember,
            BaseReferences<_$AppDatabase, $FarmMembersTable, FarmMember>,
          ),
          FarmMember,
          PrefetchHooks Function()
        > {
  $$FarmMembersTableTableManager(_$AppDatabase db, $FarmMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmMembersCompanion(
                id: id,
                farmId: farmId,
                userId: userId,
                role: role,
                joinedAt: joinedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required String userId,
                Value<String> role = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmMembersCompanion.insert(
                id: id,
                farmId: farmId,
                userId: userId,
                role: role,
                joinedAt: joinedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FarmMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmMembersTable,
      FarmMember,
      $$FarmMembersTableFilterComposer,
      $$FarmMembersTableOrderingComposer,
      $$FarmMembersTableAnnotationComposer,
      $$FarmMembersTableCreateCompanionBuilder,
      $$FarmMembersTableUpdateCompanionBuilder,
      (
        FarmMember,
        BaseReferences<_$AppDatabase, $FarmMembersTable, FarmMember>,
      ),
      FarmMember,
      PrefetchHooks Function()
    >;
typedef $$CloudUserIdMappingsTableCreateCompanionBuilder =
    CloudUserIdMappingsCompanion Function({
      required String localUserId,
      required String cloudUserId,
      required String farmId,
      Value<String?> matchKey,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$CloudUserIdMappingsTableUpdateCompanionBuilder =
    CloudUserIdMappingsCompanion Function({
      Value<String> localUserId,
      Value<String> cloudUserId,
      Value<String> farmId,
      Value<String?> matchKey,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CloudUserIdMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $CloudUserIdMappingsTable> {
  $$CloudUserIdMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localUserId => $composableBuilder(
    column: $table.localUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudUserId => $composableBuilder(
    column: $table.cloudUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchKey => $composableBuilder(
    column: $table.matchKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CloudUserIdMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CloudUserIdMappingsTable> {
  $$CloudUserIdMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localUserId => $composableBuilder(
    column: $table.localUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudUserId => $composableBuilder(
    column: $table.cloudUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchKey => $composableBuilder(
    column: $table.matchKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CloudUserIdMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CloudUserIdMappingsTable> {
  $$CloudUserIdMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localUserId => $composableBuilder(
    column: $table.localUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cloudUserId => $composableBuilder(
    column: $table.cloudUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get matchKey =>
      $composableBuilder(column: $table.matchKey, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CloudUserIdMappingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CloudUserIdMappingsTable,
          CloudUserIdMapping,
          $$CloudUserIdMappingsTableFilterComposer,
          $$CloudUserIdMappingsTableOrderingComposer,
          $$CloudUserIdMappingsTableAnnotationComposer,
          $$CloudUserIdMappingsTableCreateCompanionBuilder,
          $$CloudUserIdMappingsTableUpdateCompanionBuilder,
          (
            CloudUserIdMapping,
            BaseReferences<
              _$AppDatabase,
              $CloudUserIdMappingsTable,
              CloudUserIdMapping
            >,
          ),
          CloudUserIdMapping,
          PrefetchHooks Function()
        > {
  $$CloudUserIdMappingsTableTableManager(
    _$AppDatabase db,
    $CloudUserIdMappingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CloudUserIdMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CloudUserIdMappingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CloudUserIdMappingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> localUserId = const Value.absent(),
                Value<String> cloudUserId = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String?> matchKey = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CloudUserIdMappingsCompanion(
                localUserId: localUserId,
                cloudUserId: cloudUserId,
                farmId: farmId,
                matchKey: matchKey,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localUserId,
                required String cloudUserId,
                required String farmId,
                Value<String?> matchKey = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CloudUserIdMappingsCompanion.insert(
                localUserId: localUserId,
                cloudUserId: cloudUserId,
                farmId: farmId,
                matchKey: matchKey,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CloudUserIdMappingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CloudUserIdMappingsTable,
      CloudUserIdMapping,
      $$CloudUserIdMappingsTableFilterComposer,
      $$CloudUserIdMappingsTableOrderingComposer,
      $$CloudUserIdMappingsTableAnnotationComposer,
      $$CloudUserIdMappingsTableCreateCompanionBuilder,
      $$CloudUserIdMappingsTableUpdateCompanionBuilder,
      (
        CloudUserIdMapping,
        BaseReferences<
          _$AppDatabase,
          $CloudUserIdMappingsTable,
          CloudUserIdMapping
        >,
      ),
      CloudUserIdMapping,
      PrefetchHooks Function()
    >;
typedef $$FeedFormulationsTableCreateCompanionBuilder =
    FeedFormulationsCompanion Function({
      required String id,
      required String farmId,
      required String name,
      Value<String?> notes,
      Value<String> type,
      Value<String?> targetLivestock,
      Value<double> stockLevel,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$FeedFormulationsTableUpdateCompanionBuilder =
    FeedFormulationsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> name,
      Value<String?> notes,
      Value<String> type,
      Value<String?> targetLivestock,
      Value<double> stockLevel,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$FeedFormulationsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedFormulationsTable> {
  $$FeedFormulationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLivestock => $composableBuilder(
    column: $table.targetLivestock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockLevel => $composableBuilder(
    column: $table.stockLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedFormulationsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedFormulationsTable> {
  $$FeedFormulationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLivestock => $composableBuilder(
    column: $table.targetLivestock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockLevel => $composableBuilder(
    column: $table.stockLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedFormulationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedFormulationsTable> {
  $$FeedFormulationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get targetLivestock => $composableBuilder(
    column: $table.targetLivestock,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stockLevel => $composableBuilder(
    column: $table.stockLevel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$FeedFormulationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedFormulationsTable,
          FeedFormulation,
          $$FeedFormulationsTableFilterComposer,
          $$FeedFormulationsTableOrderingComposer,
          $$FeedFormulationsTableAnnotationComposer,
          $$FeedFormulationsTableCreateCompanionBuilder,
          $$FeedFormulationsTableUpdateCompanionBuilder,
          (
            FeedFormulation,
            BaseReferences<
              _$AppDatabase,
              $FeedFormulationsTable,
              FeedFormulation
            >,
          ),
          FeedFormulation,
          PrefetchHooks Function()
        > {
  $$FeedFormulationsTableTableManager(
    _$AppDatabase db,
    $FeedFormulationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedFormulationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedFormulationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedFormulationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> targetLivestock = const Value.absent(),
                Value<double> stockLevel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedFormulationsCompanion(
                id: id,
                farmId: farmId,
                name: name,
                notes: notes,
                type: type,
                targetLivestock: targetLivestock,
                stockLevel: stockLevel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required String name,
                Value<String?> notes = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> targetLivestock = const Value.absent(),
                Value<double> stockLevel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedFormulationsCompanion.insert(
                id: id,
                farmId: farmId,
                name: name,
                notes: notes,
                type: type,
                targetLivestock: targetLivestock,
                stockLevel: stockLevel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedFormulationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedFormulationsTable,
      FeedFormulation,
      $$FeedFormulationsTableFilterComposer,
      $$FeedFormulationsTableOrderingComposer,
      $$FeedFormulationsTableAnnotationComposer,
      $$FeedFormulationsTableCreateCompanionBuilder,
      $$FeedFormulationsTableUpdateCompanionBuilder,
      (
        FeedFormulation,
        BaseReferences<_$AppDatabase, $FeedFormulationsTable, FeedFormulation>,
      ),
      FeedFormulation,
      PrefetchHooks Function()
    >;
typedef $$FeedFormulationIngredientsTableCreateCompanionBuilder =
    FeedFormulationIngredientsCompanion Function({
      required String id,
      required String formulationId,
      required String inventoryId,
      required double quantity,
      Value<String> unit,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$FeedFormulationIngredientsTableUpdateCompanionBuilder =
    FeedFormulationIngredientsCompanion Function({
      Value<String> id,
      Value<String> formulationId,
      Value<String> inventoryId,
      Value<double> quantity,
      Value<String> unit,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$FeedFormulationIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedFormulationIngredientsTable> {
  $$FeedFormulationIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formulationId => $composableBuilder(
    column: $table.formulationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inventoryId => $composableBuilder(
    column: $table.inventoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedFormulationIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedFormulationIngredientsTable> {
  $$FeedFormulationIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formulationId => $composableBuilder(
    column: $table.formulationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inventoryId => $composableBuilder(
    column: $table.inventoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedFormulationIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedFormulationIngredientsTable> {
  $$FeedFormulationIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get formulationId => $composableBuilder(
    column: $table.formulationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inventoryId => $composableBuilder(
    column: $table.inventoryId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$FeedFormulationIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedFormulationIngredientsTable,
          FeedFormulationIngredient,
          $$FeedFormulationIngredientsTableFilterComposer,
          $$FeedFormulationIngredientsTableOrderingComposer,
          $$FeedFormulationIngredientsTableAnnotationComposer,
          $$FeedFormulationIngredientsTableCreateCompanionBuilder,
          $$FeedFormulationIngredientsTableUpdateCompanionBuilder,
          (
            FeedFormulationIngredient,
            BaseReferences<
              _$AppDatabase,
              $FeedFormulationIngredientsTable,
              FeedFormulationIngredient
            >,
          ),
          FeedFormulationIngredient,
          PrefetchHooks Function()
        > {
  $$FeedFormulationIngredientsTableTableManager(
    _$AppDatabase db,
    $FeedFormulationIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedFormulationIngredientsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FeedFormulationIngredientsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FeedFormulationIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> formulationId = const Value.absent(),
                Value<String> inventoryId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedFormulationIngredientsCompanion(
                id: id,
                formulationId: formulationId,
                inventoryId: inventoryId,
                quantity: quantity,
                unit: unit,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String formulationId,
                required String inventoryId,
                required double quantity,
                Value<String> unit = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedFormulationIngredientsCompanion.insert(
                id: id,
                formulationId: formulationId,
                inventoryId: inventoryId,
                quantity: quantity,
                unit: unit,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedFormulationIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedFormulationIngredientsTable,
      FeedFormulationIngredient,
      $$FeedFormulationIngredientsTableFilterComposer,
      $$FeedFormulationIngredientsTableOrderingComposer,
      $$FeedFormulationIngredientsTableAnnotationComposer,
      $$FeedFormulationIngredientsTableCreateCompanionBuilder,
      $$FeedFormulationIngredientsTableUpdateCompanionBuilder,
      (
        FeedFormulationIngredient,
        BaseReferences<
          _$AppDatabase,
          $FeedFormulationIngredientsTable,
          FeedFormulationIngredient
        >,
      ),
      FeedFormulationIngredient,
      PrefetchHooks Function()
    >;
typedef $$VaccinationSchedulesTableCreateCompanionBuilder =
    VaccinationSchedulesCompanion Function({
      required String id,
      required String batchId,
      required String vaccineName,
      required DateTime scheduledDate,
      Value<String> status,
      Value<String?> notes,
      Value<double> quantity,
      Value<String?> usageType,
      Value<String?> unit,
      required String farmId,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$VaccinationSchedulesTableUpdateCompanionBuilder =
    VaccinationSchedulesCompanion Function({
      Value<String> id,
      Value<String> batchId,
      Value<String> vaccineName,
      Value<DateTime> scheduledDate,
      Value<String> status,
      Value<String?> notes,
      Value<double> quantity,
      Value<String?> usageType,
      Value<String?> unit,
      Value<String> farmId,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$VaccinationSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $VaccinationSchedulesTable> {
  $$VaccinationSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vaccineName => $composableBuilder(
    column: $table.vaccineName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageType => $composableBuilder(
    column: $table.usageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaccinationSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $VaccinationSchedulesTable> {
  $$VaccinationSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vaccineName => $composableBuilder(
    column: $table.vaccineName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageType => $composableBuilder(
    column: $table.usageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaccinationSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaccinationSchedulesTable> {
  $$VaccinationSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get vaccineName => $composableBuilder(
    column: $table.vaccineName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get usageType =>
      $composableBuilder(column: $table.usageType, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$VaccinationSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VaccinationSchedulesTable,
          VaccinationSchedule,
          $$VaccinationSchedulesTableFilterComposer,
          $$VaccinationSchedulesTableOrderingComposer,
          $$VaccinationSchedulesTableAnnotationComposer,
          $$VaccinationSchedulesTableCreateCompanionBuilder,
          $$VaccinationSchedulesTableUpdateCompanionBuilder,
          (
            VaccinationSchedule,
            BaseReferences<
              _$AppDatabase,
              $VaccinationSchedulesTable,
              VaccinationSchedule
            >,
          ),
          VaccinationSchedule,
          PrefetchHooks Function()
        > {
  $$VaccinationSchedulesTableTableManager(
    _$AppDatabase db,
    $VaccinationSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaccinationSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaccinationSchedulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VaccinationSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> vaccineName = const Value.absent(),
                Value<DateTime> scheduledDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String?> usageType = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaccinationSchedulesCompanion(
                id: id,
                batchId: batchId,
                vaccineName: vaccineName,
                scheduledDate: scheduledDate,
                status: status,
                notes: notes,
                quantity: quantity,
                usageType: usageType,
                unit: unit,
                farmId: farmId,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String batchId,
                required String vaccineName,
                required DateTime scheduledDate,
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String?> usageType = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                required String farmId,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaccinationSchedulesCompanion.insert(
                id: id,
                batchId: batchId,
                vaccineName: vaccineName,
                scheduledDate: scheduledDate,
                status: status,
                notes: notes,
                quantity: quantity,
                usageType: usageType,
                unit: unit,
                farmId: farmId,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaccinationSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VaccinationSchedulesTable,
      VaccinationSchedule,
      $$VaccinationSchedulesTableFilterComposer,
      $$VaccinationSchedulesTableOrderingComposer,
      $$VaccinationSchedulesTableAnnotationComposer,
      $$VaccinationSchedulesTableCreateCompanionBuilder,
      $$VaccinationSchedulesTableUpdateCompanionBuilder,
      (
        VaccinationSchedule,
        BaseReferences<
          _$AppDatabase,
          $VaccinationSchedulesTable,
          VaccinationSchedule
        >,
      ),
      VaccinationSchedule,
      PrefetchHooks Function()
    >;
typedef $$MedicationSchedulesTableCreateCompanionBuilder =
    MedicationSchedulesCompanion Function({
      required String id,
      required String batchId,
      required String medicationName,
      required DateTime scheduledDate,
      Value<String> status,
      Value<String?> notes,
      Value<double> quantity,
      Value<String?> usageType,
      Value<String?> unit,
      required String farmId,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$MedicationSchedulesTableUpdateCompanionBuilder =
    MedicationSchedulesCompanion Function({
      Value<String> id,
      Value<String> batchId,
      Value<String> medicationName,
      Value<DateTime> scheduledDate,
      Value<String> status,
      Value<String?> notes,
      Value<double> quantity,
      Value<String?> usageType,
      Value<String?> unit,
      Value<String> farmId,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$MedicationSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageType => $composableBuilder(
    column: $table.usageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicationSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageType => $composableBuilder(
    column: $table.usageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get usageType =>
      $composableBuilder(column: $table.usageType, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$MedicationSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationSchedulesTable,
          MedicationSchedule,
          $$MedicationSchedulesTableFilterComposer,
          $$MedicationSchedulesTableOrderingComposer,
          $$MedicationSchedulesTableAnnotationComposer,
          $$MedicationSchedulesTableCreateCompanionBuilder,
          $$MedicationSchedulesTableUpdateCompanionBuilder,
          (
            MedicationSchedule,
            BaseReferences<
              _$AppDatabase,
              $MedicationSchedulesTable,
              MedicationSchedule
            >,
          ),
          MedicationSchedule,
          PrefetchHooks Function()
        > {
  $$MedicationSchedulesTableTableManager(
    _$AppDatabase db,
    $MedicationSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationSchedulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MedicationSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> medicationName = const Value.absent(),
                Value<DateTime> scheduledDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String?> usageType = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationSchedulesCompanion(
                id: id,
                batchId: batchId,
                medicationName: medicationName,
                scheduledDate: scheduledDate,
                status: status,
                notes: notes,
                quantity: quantity,
                usageType: usageType,
                unit: unit,
                farmId: farmId,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String batchId,
                required String medicationName,
                required DateTime scheduledDate,
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String?> usageType = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                required String farmId,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationSchedulesCompanion.insert(
                id: id,
                batchId: batchId,
                medicationName: medicationName,
                scheduledDate: scheduledDate,
                status: status,
                notes: notes,
                quantity: quantity,
                usageType: usageType,
                unit: unit,
                farmId: farmId,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicationSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationSchedulesTable,
      MedicationSchedule,
      $$MedicationSchedulesTableFilterComposer,
      $$MedicationSchedulesTableOrderingComposer,
      $$MedicationSchedulesTableAnnotationComposer,
      $$MedicationSchedulesTableCreateCompanionBuilder,
      $$MedicationSchedulesTableUpdateCompanionBuilder,
      (
        MedicationSchedule,
        BaseReferences<
          _$AppDatabase,
          $MedicationSchedulesTable,
          MedicationSchedule
        >,
      ),
      MedicationSchedule,
      PrefetchHooks Function()
    >;
typedef $$HealthRecordsTableCreateCompanionBuilder =
    HealthRecordsCompanion Function({
      required String id,
      Value<String?> batchId,
      Value<String?> recordType,
      Value<String?> description,
      required DateTime recordDate,
      required String farmId,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$HealthRecordsTableUpdateCompanionBuilder =
    HealthRecordsCompanion Function({
      Value<String> id,
      Value<String?> batchId,
      Value<String?> recordType,
      Value<String?> description,
      Value<DateTime> recordDate,
      Value<String> farmId,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$HealthRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $HealthRecordsTable> {
  $$HealthRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthRecordsTable> {
  $$HealthRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthRecordsTable> {
  $$HealthRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$HealthRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthRecordsTable,
          HealthRecord,
          $$HealthRecordsTableFilterComposer,
          $$HealthRecordsTableOrderingComposer,
          $$HealthRecordsTableAnnotationComposer,
          $$HealthRecordsTableCreateCompanionBuilder,
          $$HealthRecordsTableUpdateCompanionBuilder,
          (
            HealthRecord,
            BaseReferences<_$AppDatabase, $HealthRecordsTable, HealthRecord>,
          ),
          HealthRecord,
          PrefetchHooks Function()
        > {
  $$HealthRecordsTableTableManager(_$AppDatabase db, $HealthRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String?> recordType = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> recordDate = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HealthRecordsCompanion(
                id: id,
                batchId: batchId,
                recordType: recordType,
                description: description,
                recordDate: recordDate,
                farmId: farmId,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> batchId = const Value.absent(),
                Value<String?> recordType = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required DateTime recordDate,
                required String farmId,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HealthRecordsCompanion.insert(
                id: id,
                batchId: batchId,
                recordType: recordType,
                description: description,
                recordDate: recordDate,
                farmId: farmId,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthRecordsTable,
      HealthRecord,
      $$HealthRecordsTableFilterComposer,
      $$HealthRecordsTableOrderingComposer,
      $$HealthRecordsTableAnnotationComposer,
      $$HealthRecordsTableCreateCompanionBuilder,
      $$HealthRecordsTableUpdateCompanionBuilder,
      (
        HealthRecord,
        BaseReferences<_$AppDatabase, $HealthRecordsTable, HealthRecord>,
      ),
      HealthRecord,
      PrefetchHooks Function()
    >;
typedef $$SalesTableCreateCompanionBuilder =
    SalesCompanion Function({
      required String id,
      required String farmId,
      Value<String?> batchId,
      Value<String?> customerId,
      required int quantity,
      required double unitPrice,
      required double totalAmount,
      Value<DateTime> saleDate,
      Value<String?> userId,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$SalesTableUpdateCompanionBuilder =
    SalesCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String?> batchId,
      Value<String?> customerId,
      Value<int> quantity,
      Value<double> unitPrice,
      Value<double> totalAmount,
      Value<DateTime> saleDate,
      Value<String?> userId,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get saleDate => $composableBuilder(
    column: $table.saleDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get saleDate => $composableBuilder(
    column: $table.saleDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get saleDate =>
      $composableBuilder(column: $table.saleDate, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          Sale,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
          Sale,
          PrefetchHooks Function()
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<DateTime> saleDate = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                farmId: farmId,
                batchId: batchId,
                customerId: customerId,
                quantity: quantity,
                unitPrice: unitPrice,
                totalAmount: totalAmount,
                saleDate: saleDate,
                userId: userId,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                Value<String?> batchId = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                required int quantity,
                required double unitPrice,
                required double totalAmount,
                Value<DateTime> saleDate = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                farmId: farmId,
                batchId: batchId,
                customerId: customerId,
                quantity: quantity,
                unitPrice: unitPrice,
                totalAmount: totalAmount,
                saleDate: saleDate,
                userId: userId,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      Sale,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
      Sale,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      required String id,
      required String farmId,
      Value<String?> batchId,
      Value<String?> supplierId,
      required String category,
      required double amount,
      Value<DateTime> date,
      Value<String?> description,
      Value<String?> allocationGroupId,
      Value<double?> allocationPercent,
      Value<bool> isSharedAllocation,
      Value<String?> userId,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String?> batchId,
      Value<String?> supplierId,
      Value<String> category,
      Value<double> amount,
      Value<DateTime> date,
      Value<String?> description,
      Value<String?> allocationGroupId,
      Value<double?> allocationPercent,
      Value<bool> isSharedAllocation,
      Value<String?> userId,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allocationGroupId => $composableBuilder(
    column: $table.allocationGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get allocationPercent => $composableBuilder(
    column: $table.allocationPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSharedAllocation => $composableBuilder(
    column: $table.isSharedAllocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allocationGroupId => $composableBuilder(
    column: $table.allocationGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get allocationPercent => $composableBuilder(
    column: $table.allocationPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSharedAllocation => $composableBuilder(
    column: $table.isSharedAllocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allocationGroupId => $composableBuilder(
    column: $table.allocationGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get allocationPercent => $composableBuilder(
    column: $table.allocationPercent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSharedAllocation => $composableBuilder(
    column: $table.isSharedAllocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
          Expense,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> allocationGroupId = const Value.absent(),
                Value<double?> allocationPercent = const Value.absent(),
                Value<bool> isSharedAllocation = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                farmId: farmId,
                batchId: batchId,
                supplierId: supplierId,
                category: category,
                amount: amount,
                date: date,
                description: description,
                allocationGroupId: allocationGroupId,
                allocationPercent: allocationPercent,
                isSharedAllocation: isSharedAllocation,
                userId: userId,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                Value<String?> batchId = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                required String category,
                required double amount,
                Value<DateTime> date = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> allocationGroupId = const Value.absent(),
                Value<double?> allocationPercent = const Value.absent(),
                Value<bool> isSharedAllocation = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                farmId: farmId,
                batchId: batchId,
                supplierId: supplierId,
                category: category,
                amount: amount,
                date: date,
                description: description,
                allocationGroupId: allocationGroupId,
                allocationPercent: allocationPercent,
                isSharedAllocation: isSharedAllocation,
                userId: userId,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
      Expense,
      PrefetchHooks Function()
    >;
typedef $$SettlementsTableCreateCompanionBuilder =
    SettlementsCompanion Function({
      required String id,
      required String farmId,
      required String customerId,
      required double amount,
      Value<DateTime> settlementDate,
      required String settlementType,
      Value<String?> userId,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$SettlementsTableUpdateCompanionBuilder =
    SettlementsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> customerId,
      Value<double> amount,
      Value<DateTime> settlementDate,
      Value<String> settlementType,
      Value<String?> userId,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$SettlementsTableFilterComposer
    extends Composer<_$AppDatabase, $SettlementsTable> {
  $$SettlementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get settlementDate => $composableBuilder(
    column: $table.settlementDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settlementType => $composableBuilder(
    column: $table.settlementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettlementsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettlementsTable> {
  $$SettlementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get settlementDate => $composableBuilder(
    column: $table.settlementDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settlementType => $composableBuilder(
    column: $table.settlementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettlementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettlementsTable> {
  $$SettlementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get settlementDate => $composableBuilder(
    column: $table.settlementDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settlementType => $composableBuilder(
    column: $table.settlementType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$SettlementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettlementsTable,
          Settlement,
          $$SettlementsTableFilterComposer,
          $$SettlementsTableOrderingComposer,
          $$SettlementsTableAnnotationComposer,
          $$SettlementsTableCreateCompanionBuilder,
          $$SettlementsTableUpdateCompanionBuilder,
          (
            Settlement,
            BaseReferences<_$AppDatabase, $SettlementsTable, Settlement>,
          ),
          Settlement,
          PrefetchHooks Function()
        > {
  $$SettlementsTableTableManager(_$AppDatabase db, $SettlementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettlementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettlementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettlementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> settlementDate = const Value.absent(),
                Value<String> settlementType = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettlementsCompanion(
                id: id,
                farmId: farmId,
                customerId: customerId,
                amount: amount,
                settlementDate: settlementDate,
                settlementType: settlementType,
                userId: userId,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required String customerId,
                required double amount,
                Value<DateTime> settlementDate = const Value.absent(),
                required String settlementType,
                Value<String?> userId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettlementsCompanion.insert(
                id: id,
                farmId: farmId,
                customerId: customerId,
                amount: amount,
                settlementDate: settlementDate,
                settlementType: settlementType,
                userId: userId,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettlementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettlementsTable,
      Settlement,
      $$SettlementsTableFilterComposer,
      $$SettlementsTableOrderingComposer,
      $$SettlementsTableAnnotationComposer,
      $$SettlementsTableCreateCompanionBuilder,
      $$SettlementsTableUpdateCompanionBuilder,
      (
        Settlement,
        BaseReferences<_$AppDatabase, $SettlementsTable, Settlement>,
      ),
      Settlement,
      PrefetchHooks Function()
    >;
typedef $$PendingDeletionsTableCreateCompanionBuilder =
    PendingDeletionsCompanion Function({
      required String id,
      required String targetTableName,
      required String recordId,
      required String farmId,
      Value<DateTime> deletedAt,
      Value<int> rowid,
    });
typedef $$PendingDeletionsTableUpdateCompanionBuilder =
    PendingDeletionsCompanion Function({
      Value<String> id,
      Value<String> targetTableName,
      Value<String> recordId,
      Value<String> farmId,
      Value<DateTime> deletedAt,
      Value<int> rowid,
    });

class $$PendingDeletionsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingDeletionsTable> {
  $$PendingDeletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTableName => $composableBuilder(
    column: $table.targetTableName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingDeletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingDeletionsTable> {
  $$PendingDeletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTableName => $composableBuilder(
    column: $table.targetTableName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingDeletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingDeletionsTable> {
  $$PendingDeletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTableName => $composableBuilder(
    column: $table.targetTableName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PendingDeletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingDeletionsTable,
          PendingDeletion,
          $$PendingDeletionsTableFilterComposer,
          $$PendingDeletionsTableOrderingComposer,
          $$PendingDeletionsTableAnnotationComposer,
          $$PendingDeletionsTableCreateCompanionBuilder,
          $$PendingDeletionsTableUpdateCompanionBuilder,
          (
            PendingDeletion,
            BaseReferences<
              _$AppDatabase,
              $PendingDeletionsTable,
              PendingDeletion
            >,
          ),
          PendingDeletion,
          PrefetchHooks Function()
        > {
  $$PendingDeletionsTableTableManager(
    _$AppDatabase db,
    $PendingDeletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingDeletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingDeletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingDeletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> targetTableName = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingDeletionsCompanion(
                id: id,
                targetTableName: targetTableName,
                recordId: recordId,
                farmId: farmId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String targetTableName,
                required String recordId,
                required String farmId,
                Value<DateTime> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingDeletionsCompanion.insert(
                id: id,
                targetTableName: targetTableName,
                recordId: recordId,
                farmId: farmId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingDeletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingDeletionsTable,
      PendingDeletion,
      $$PendingDeletionsTableFilterComposer,
      $$PendingDeletionsTableOrderingComposer,
      $$PendingDeletionsTableAnnotationComposer,
      $$PendingDeletionsTableCreateCompanionBuilder,
      $$PendingDeletionsTableUpdateCompanionBuilder,
      (
        PendingDeletion,
        BaseReferences<_$AppDatabase, $PendingDeletionsTable, PendingDeletion>,
      ),
      PendingDeletion,
      PrefetchHooks Function()
    >;
typedef $$StockLogsTableCreateCompanionBuilder =
    StockLogsCompanion Function({
      required String id,
      required String farmId,
      required String itemId,
      required double quantity,
      required String logType,
      Value<String?> batchId,
      Value<String?> supplierId,
      Value<String?> note,
      Value<DateTime> logDate,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$StockLogsTableUpdateCompanionBuilder =
    StockLogsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> itemId,
      Value<double> quantity,
      Value<String> logType,
      Value<String?> batchId,
      Value<String?> supplierId,
      Value<String?> note,
      Value<DateTime> logDate,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$StockLogsTableFilterComposer
    extends Composer<_$AppDatabase, $StockLogsTable> {
  $$StockLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logType => $composableBuilder(
    column: $table.logType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockLogsTable> {
  $$StockLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logType => $composableBuilder(
    column: $table.logType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockLogsTable> {
  $$StockLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get logType =>
      $composableBuilder(column: $table.logType, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$StockLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockLogsTable,
          StockLog,
          $$StockLogsTableFilterComposer,
          $$StockLogsTableOrderingComposer,
          $$StockLogsTableAnnotationComposer,
          $$StockLogsTableCreateCompanionBuilder,
          $$StockLogsTableUpdateCompanionBuilder,
          (StockLog, BaseReferences<_$AppDatabase, $StockLogsTable, StockLog>),
          StockLog,
          PrefetchHooks Function()
        > {
  $$StockLogsTableTableManager(_$AppDatabase db, $StockLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> logType = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> logDate = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockLogsCompanion(
                id: id,
                farmId: farmId,
                itemId: itemId,
                quantity: quantity,
                logType: logType,
                batchId: batchId,
                supplierId: supplierId,
                note: note,
                logDate: logDate,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required String itemId,
                required double quantity,
                required String logType,
                Value<String?> batchId = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> logDate = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockLogsCompanion.insert(
                id: id,
                farmId: farmId,
                itemId: itemId,
                quantity: quantity,
                logType: logType,
                batchId: batchId,
                supplierId: supplierId,
                note: note,
                logDate: logDate,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockLogsTable,
      StockLog,
      $$StockLogsTableFilterComposer,
      $$StockLogsTableOrderingComposer,
      $$StockLogsTableAnnotationComposer,
      $$StockLogsTableCreateCompanionBuilder,
      $$StockLogsTableUpdateCompanionBuilder,
      (StockLog, BaseReferences<_$AppDatabase, $StockLogsTable, StockLog>),
      StockLog,
      PrefetchHooks Function()
    >;
typedef $$LicenseConfigsTableCreateCompanionBuilder =
    LicenseConfigsCompanion Function({
      required String id,
      Value<String> mode,
      Value<String?> farmId,
      Value<String?> userId,
      Value<String?> hardwareId,
      Value<DateTime> installedAt,
      required DateTime expiresAt,
      Value<DateTime> lastUsed,
      Value<DateTime?> lastCloudCheckAt,
      Value<int> rowid,
    });
typedef $$LicenseConfigsTableUpdateCompanionBuilder =
    LicenseConfigsCompanion Function({
      Value<String> id,
      Value<String> mode,
      Value<String?> farmId,
      Value<String?> userId,
      Value<String?> hardwareId,
      Value<DateTime> installedAt,
      Value<DateTime> expiresAt,
      Value<DateTime> lastUsed,
      Value<DateTime?> lastCloudCheckAt,
      Value<int> rowid,
    });

class $$LicenseConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $LicenseConfigsTable> {
  $$LicenseConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hardwareId => $composableBuilder(
    column: $table.hardwareId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsed => $composableBuilder(
    column: $table.lastUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCloudCheckAt => $composableBuilder(
    column: $table.lastCloudCheckAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LicenseConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $LicenseConfigsTable> {
  $$LicenseConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hardwareId => $composableBuilder(
    column: $table.hardwareId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsed => $composableBuilder(
    column: $table.lastUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCloudCheckAt => $composableBuilder(
    column: $table.lastCloudCheckAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LicenseConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LicenseConfigsTable> {
  $$LicenseConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get hardwareId => $composableBuilder(
    column: $table.hardwareId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsed =>
      $composableBuilder(column: $table.lastUsed, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCloudCheckAt => $composableBuilder(
    column: $table.lastCloudCheckAt,
    builder: (column) => column,
  );
}

class $$LicenseConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LicenseConfigsTable,
          LicenseConfig,
          $$LicenseConfigsTableFilterComposer,
          $$LicenseConfigsTableOrderingComposer,
          $$LicenseConfigsTableAnnotationComposer,
          $$LicenseConfigsTableCreateCompanionBuilder,
          $$LicenseConfigsTableUpdateCompanionBuilder,
          (
            LicenseConfig,
            BaseReferences<_$AppDatabase, $LicenseConfigsTable, LicenseConfig>,
          ),
          LicenseConfig,
          PrefetchHooks Function()
        > {
  $$LicenseConfigsTableTableManager(
    _$AppDatabase db,
    $LicenseConfigsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LicenseConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LicenseConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LicenseConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String?> farmId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> hardwareId = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<DateTime> lastUsed = const Value.absent(),
                Value<DateTime?> lastCloudCheckAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LicenseConfigsCompanion(
                id: id,
                mode: mode,
                farmId: farmId,
                userId: userId,
                hardwareId: hardwareId,
                installedAt: installedAt,
                expiresAt: expiresAt,
                lastUsed: lastUsed,
                lastCloudCheckAt: lastCloudCheckAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> mode = const Value.absent(),
                Value<String?> farmId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> hardwareId = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                required DateTime expiresAt,
                Value<DateTime> lastUsed = const Value.absent(),
                Value<DateTime?> lastCloudCheckAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LicenseConfigsCompanion.insert(
                id: id,
                mode: mode,
                farmId: farmId,
                userId: userId,
                hardwareId: hardwareId,
                installedAt: installedAt,
                expiresAt: expiresAt,
                lastUsed: lastUsed,
                lastCloudCheckAt: lastCloudCheckAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LicenseConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LicenseConfigsTable,
      LicenseConfig,
      $$LicenseConfigsTableFilterComposer,
      $$LicenseConfigsTableOrderingComposer,
      $$LicenseConfigsTableAnnotationComposer,
      $$LicenseConfigsTableCreateCompanionBuilder,
      $$LicenseConfigsTableUpdateCompanionBuilder,
      (
        LicenseConfig,
        BaseReferences<_$AppDatabase, $LicenseConfigsTable, LicenseConfig>,
      ),
      LicenseConfig,
      PrefetchHooks Function()
    >;
typedef $$UserPermissionsTableCreateCompanionBuilder =
    UserPermissionsCompanion Function({
      required String id,
      required String farmId,
      required String userId,
      required String permissionKey,
      Value<bool> allowed,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$UserPermissionsTableUpdateCompanionBuilder =
    UserPermissionsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> userId,
      Value<String> permissionKey,
      Value<bool> allowed,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$UserPermissionsTableFilterComposer
    extends Composer<_$AppDatabase, $UserPermissionsTable> {
  $$UserPermissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissionKey => $composableBuilder(
    column: $table.permissionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowed => $composableBuilder(
    column: $table.allowed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPermissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPermissionsTable> {
  $$UserPermissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissionKey => $composableBuilder(
    column: $table.permissionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowed => $composableBuilder(
    column: $table.allowed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPermissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPermissionsTable> {
  $$UserPermissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get permissionKey => $composableBuilder(
    column: $table.permissionKey,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowed =>
      $composableBuilder(column: $table.allowed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$UserPermissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPermissionsTable,
          UserPermission,
          $$UserPermissionsTableFilterComposer,
          $$UserPermissionsTableOrderingComposer,
          $$UserPermissionsTableAnnotationComposer,
          $$UserPermissionsTableCreateCompanionBuilder,
          $$UserPermissionsTableUpdateCompanionBuilder,
          (
            UserPermission,
            BaseReferences<
              _$AppDatabase,
              $UserPermissionsTable,
              UserPermission
            >,
          ),
          UserPermission,
          PrefetchHooks Function()
        > {
  $$UserPermissionsTableTableManager(
    _$AppDatabase db,
    $UserPermissionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPermissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPermissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPermissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> permissionKey = const Value.absent(),
                Value<bool> allowed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPermissionsCompanion(
                id: id,
                farmId: farmId,
                userId: userId,
                permissionKey: permissionKey,
                allowed: allowed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required String userId,
                required String permissionKey,
                Value<bool> allowed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPermissionsCompanion.insert(
                id: id,
                farmId: farmId,
                userId: userId,
                permissionKey: permissionKey,
                allowed: allowed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPermissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPermissionsTable,
      UserPermission,
      $$UserPermissionsTableFilterComposer,
      $$UserPermissionsTableOrderingComposer,
      $$UserPermissionsTableAnnotationComposer,
      $$UserPermissionsTableCreateCompanionBuilder,
      $$UserPermissionsTableUpdateCompanionBuilder,
      (
        UserPermission,
        BaseReferences<_$AppDatabase, $UserPermissionsTable, UserPermission>,
      ),
      UserPermission,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String id,
      required String farmId,
      required String phoneNumber,
      Value<String> role,
      Value<String?> firstName,
      Value<String?> lastName,
      Value<String> status,
      Value<String?> customPermissionsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> phoneNumber,
      Value<String> role,
      Value<String?> firstName,
      Value<String?> lastName,
      Value<String> status,
      Value<String?> customPermissionsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customPermissionsJson => $composableBuilder(
    column: $table.customPermissionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customPermissionsJson => $composableBuilder(
    column: $table.customPermissionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get customPermissionsJson => $composableBuilder(
    column: $table.customPermissionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> customPermissionsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                farmId: farmId,
                phoneNumber: phoneNumber,
                role: role,
                firstName: firstName,
                lastName: lastName,
                status: status,
                customPermissionsJson: customPermissionsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required String phoneNumber,
                Value<String> role = const Value.absent(),
                Value<String?> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> customPermissionsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                farmId: farmId,
                phoneNumber: phoneNumber,
                role: role,
                firstName: firstName,
                lastName: lastName,
                status: status,
                customPermissionsJson: customPermissionsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$FarmsTableTableManager get farms =>
      $$FarmsTableTableManager(_db, _db.farms);
  $$BatchesTableTableManager get batches =>
      $$BatchesTableTableManager(_db, _db.batches);
  $$InventoryTableTableManager get inventory =>
      $$InventoryTableTableManager(_db, _db.inventory);
  $$FeedingLogsTableTableManager get feedingLogs =>
      $$FeedingLogsTableTableManager(_db, _db.feedingLogs);
  $$EggProductionsTableTableManager get eggProductions =>
      $$EggProductionsTableTableManager(_db, _db.eggProductions);
  $$MortalitiesTableTableManager get mortalities =>
      $$MortalitiesTableTableManager(_db, _db.mortalities);
  $$HousesTableTableManager get houses =>
      $$HousesTableTableManager(_db, _db.houses);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$FarmSettingsTableTableManager get farmSettings =>
      $$FarmSettingsTableTableManager(_db, _db.farmSettings);
  $$WeightRecordsTableTableManager get weightRecords =>
      $$WeightRecordsTableTableManager(_db, _db.weightRecords);
  $$DeviceRegistrationsTableTableManager get deviceRegistrations =>
      $$DeviceRegistrationsTableTableManager(_db, _db.deviceRegistrations);
  $$FarmMembersTableTableManager get farmMembers =>
      $$FarmMembersTableTableManager(_db, _db.farmMembers);
  $$CloudUserIdMappingsTableTableManager get cloudUserIdMappings =>
      $$CloudUserIdMappingsTableTableManager(_db, _db.cloudUserIdMappings);
  $$FeedFormulationsTableTableManager get feedFormulations =>
      $$FeedFormulationsTableTableManager(_db, _db.feedFormulations);
  $$FeedFormulationIngredientsTableTableManager
  get feedFormulationIngredients =>
      $$FeedFormulationIngredientsTableTableManager(
        _db,
        _db.feedFormulationIngredients,
      );
  $$VaccinationSchedulesTableTableManager get vaccinationSchedules =>
      $$VaccinationSchedulesTableTableManager(_db, _db.vaccinationSchedules);
  $$MedicationSchedulesTableTableManager get medicationSchedules =>
      $$MedicationSchedulesTableTableManager(_db, _db.medicationSchedules);
  $$HealthRecordsTableTableManager get healthRecords =>
      $$HealthRecordsTableTableManager(_db, _db.healthRecords);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$SettlementsTableTableManager get settlements =>
      $$SettlementsTableTableManager(_db, _db.settlements);
  $$PendingDeletionsTableTableManager get pendingDeletions =>
      $$PendingDeletionsTableTableManager(_db, _db.pendingDeletions);
  $$StockLogsTableTableManager get stockLogs =>
      $$StockLogsTableTableManager(_db, _db.stockLogs);
  $$LicenseConfigsTableTableManager get licenseConfigs =>
      $$LicenseConfigsTableTableManager(_db, _db.licenseConfigs);
  $$UserPermissionsTableTableManager get userPermissions =>
      $$UserPermissionsTableTableManager(_db, _db.userPermissions);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
}
