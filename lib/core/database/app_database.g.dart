// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WatchHistoryTable extends WatchHistory
    with TableInfo<$WatchHistoryTable, WatchHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchHistoryTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _movieSlugMeta = const VerificationMeta(
    'movieSlug',
  );
  @override
  late final GeneratedColumn<String> movieSlug = GeneratedColumn<String>(
    'movie_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movieNameMeta = const VerificationMeta(
    'movieName',
  );
  @override
  late final GeneratedColumn<String> movieName = GeneratedColumn<String>(
    'movie_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posterUrlMeta = const VerificationMeta(
    'posterUrl',
  );
  @override
  late final GeneratedColumn<String> posterUrl = GeneratedColumn<String>(
    'poster_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeNameMeta = const VerificationMeta(
    'episodeName',
  );
  @override
  late final GeneratedColumn<String> episodeName = GeneratedColumn<String>(
    'episode_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodeSlugMeta = const VerificationMeta(
    'episodeSlug',
  );
  @override
  late final GeneratedColumn<String> episodeSlug = GeneratedColumn<String>(
    'episode_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverNameMeta = const VerificationMeta(
    'serverName',
  );
  @override
  late final GeneratedColumn<String> serverName = GeneratedColumn<String>(
    'server_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Vietsub'),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('kkphim'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    movieSlug,
    movieName,
    posterUrl,
    episodeName,
    episodeSlug,
    serverName,
    positionMs,
    durationMs,
    updatedAt,
    sourceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('movie_slug')) {
      context.handle(
        _movieSlugMeta,
        movieSlug.isAcceptableOrUnknown(data['movie_slug']!, _movieSlugMeta),
      );
    } else if (isInserting) {
      context.missing(_movieSlugMeta);
    }
    if (data.containsKey('movie_name')) {
      context.handle(
        _movieNameMeta,
        movieName.isAcceptableOrUnknown(data['movie_name']!, _movieNameMeta),
      );
    } else if (isInserting) {
      context.missing(_movieNameMeta);
    }
    if (data.containsKey('poster_url')) {
      context.handle(
        _posterUrlMeta,
        posterUrl.isAcceptableOrUnknown(data['poster_url']!, _posterUrlMeta),
      );
    }
    if (data.containsKey('episode_name')) {
      context.handle(
        _episodeNameMeta,
        episodeName.isAcceptableOrUnknown(
          data['episode_name']!,
          _episodeNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_episodeNameMeta);
    }
    if (data.containsKey('episode_slug')) {
      context.handle(
        _episodeSlugMeta,
        episodeSlug.isAcceptableOrUnknown(
          data['episode_slug']!,
          _episodeSlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_episodeSlugMeta);
    }
    if (data.containsKey('server_name')) {
      context.handle(
        _serverNameMeta,
        serverName.isAcceptableOrUnknown(data['server_name']!, _serverNameMeta),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {movieSlug, episodeSlug, serverName},
  ];
  @override
  WatchHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      movieSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movie_slug'],
      )!,
      movieName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movie_name'],
      )!,
      posterUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_url'],
      ),
      episodeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_name'],
      )!,
      episodeSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_slug'],
      )!,
      serverName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_name'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
    );
  }

  @override
  $WatchHistoryTable createAlias(String alias) {
    return $WatchHistoryTable(attachedDatabase, alias);
  }
}

class WatchHistoryData extends DataClass
    implements Insertable<WatchHistoryData> {
  final int id;
  final String movieSlug;
  final String movieName;
  final String? posterUrl;
  final String episodeName;
  final String episodeSlug;
  final String serverName;
  final int positionMs;
  final int durationMs;
  final DateTime updatedAt;
  final String sourceId;
  const WatchHistoryData({
    required this.id,
    required this.movieSlug,
    required this.movieName,
    this.posterUrl,
    required this.episodeName,
    required this.episodeSlug,
    required this.serverName,
    required this.positionMs,
    required this.durationMs,
    required this.updatedAt,
    required this.sourceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['movie_slug'] = Variable<String>(movieSlug);
    map['movie_name'] = Variable<String>(movieName);
    if (!nullToAbsent || posterUrl != null) {
      map['poster_url'] = Variable<String>(posterUrl);
    }
    map['episode_name'] = Variable<String>(episodeName);
    map['episode_slug'] = Variable<String>(episodeSlug);
    map['server_name'] = Variable<String>(serverName);
    map['position_ms'] = Variable<int>(positionMs);
    map['duration_ms'] = Variable<int>(durationMs);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['source_id'] = Variable<String>(sourceId);
    return map;
  }

  WatchHistoryCompanion toCompanion(bool nullToAbsent) {
    return WatchHistoryCompanion(
      id: Value(id),
      movieSlug: Value(movieSlug),
      movieName: Value(movieName),
      posterUrl: posterUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(posterUrl),
      episodeName: Value(episodeName),
      episodeSlug: Value(episodeSlug),
      serverName: Value(serverName),
      positionMs: Value(positionMs),
      durationMs: Value(durationMs),
      updatedAt: Value(updatedAt),
      sourceId: Value(sourceId),
    );
  }

  factory WatchHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchHistoryData(
      id: serializer.fromJson<int>(json['id']),
      movieSlug: serializer.fromJson<String>(json['movieSlug']),
      movieName: serializer.fromJson<String>(json['movieName']),
      posterUrl: serializer.fromJson<String?>(json['posterUrl']),
      episodeName: serializer.fromJson<String>(json['episodeName']),
      episodeSlug: serializer.fromJson<String>(json['episodeSlug']),
      serverName: serializer.fromJson<String>(json['serverName']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'movieSlug': serializer.toJson<String>(movieSlug),
      'movieName': serializer.toJson<String>(movieName),
      'posterUrl': serializer.toJson<String?>(posterUrl),
      'episodeName': serializer.toJson<String>(episodeName),
      'episodeSlug': serializer.toJson<String>(episodeSlug),
      'serverName': serializer.toJson<String>(serverName),
      'positionMs': serializer.toJson<int>(positionMs),
      'durationMs': serializer.toJson<int>(durationMs),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sourceId': serializer.toJson<String>(sourceId),
    };
  }

  WatchHistoryData copyWith({
    int? id,
    String? movieSlug,
    String? movieName,
    Value<String?> posterUrl = const Value.absent(),
    String? episodeName,
    String? episodeSlug,
    String? serverName,
    int? positionMs,
    int? durationMs,
    DateTime? updatedAt,
    String? sourceId,
  }) => WatchHistoryData(
    id: id ?? this.id,
    movieSlug: movieSlug ?? this.movieSlug,
    movieName: movieName ?? this.movieName,
    posterUrl: posterUrl.present ? posterUrl.value : this.posterUrl,
    episodeName: episodeName ?? this.episodeName,
    episodeSlug: episodeSlug ?? this.episodeSlug,
    serverName: serverName ?? this.serverName,
    positionMs: positionMs ?? this.positionMs,
    durationMs: durationMs ?? this.durationMs,
    updatedAt: updatedAt ?? this.updatedAt,
    sourceId: sourceId ?? this.sourceId,
  );
  WatchHistoryData copyWithCompanion(WatchHistoryCompanion data) {
    return WatchHistoryData(
      id: data.id.present ? data.id.value : this.id,
      movieSlug: data.movieSlug.present ? data.movieSlug.value : this.movieSlug,
      movieName: data.movieName.present ? data.movieName.value : this.movieName,
      posterUrl: data.posterUrl.present ? data.posterUrl.value : this.posterUrl,
      episodeName: data.episodeName.present
          ? data.episodeName.value
          : this.episodeName,
      episodeSlug: data.episodeSlug.present
          ? data.episodeSlug.value
          : this.episodeSlug,
      serverName: data.serverName.present
          ? data.serverName.value
          : this.serverName,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchHistoryData(')
          ..write('id: $id, ')
          ..write('movieSlug: $movieSlug, ')
          ..write('movieName: $movieName, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('episodeName: $episodeName, ')
          ..write('episodeSlug: $episodeSlug, ')
          ..write('serverName: $serverName, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sourceId: $sourceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    movieSlug,
    movieName,
    posterUrl,
    episodeName,
    episodeSlug,
    serverName,
    positionMs,
    durationMs,
    updatedAt,
    sourceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchHistoryData &&
          other.id == this.id &&
          other.movieSlug == this.movieSlug &&
          other.movieName == this.movieName &&
          other.posterUrl == this.posterUrl &&
          other.episodeName == this.episodeName &&
          other.episodeSlug == this.episodeSlug &&
          other.serverName == this.serverName &&
          other.positionMs == this.positionMs &&
          other.durationMs == this.durationMs &&
          other.updatedAt == this.updatedAt &&
          other.sourceId == this.sourceId);
}

class WatchHistoryCompanion extends UpdateCompanion<WatchHistoryData> {
  final Value<int> id;
  final Value<String> movieSlug;
  final Value<String> movieName;
  final Value<String?> posterUrl;
  final Value<String> episodeName;
  final Value<String> episodeSlug;
  final Value<String> serverName;
  final Value<int> positionMs;
  final Value<int> durationMs;
  final Value<DateTime> updatedAt;
  final Value<String> sourceId;
  const WatchHistoryCompanion({
    this.id = const Value.absent(),
    this.movieSlug = const Value.absent(),
    this.movieName = const Value.absent(),
    this.posterUrl = const Value.absent(),
    this.episodeName = const Value.absent(),
    this.episodeSlug = const Value.absent(),
    this.serverName = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sourceId = const Value.absent(),
  });
  WatchHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String movieSlug,
    required String movieName,
    this.posterUrl = const Value.absent(),
    required String episodeName,
    required String episodeSlug,
    this.serverName = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    required DateTime updatedAt,
    this.sourceId = const Value.absent(),
  }) : movieSlug = Value(movieSlug),
       movieName = Value(movieName),
       episodeName = Value(episodeName),
       episodeSlug = Value(episodeSlug),
       updatedAt = Value(updatedAt);
  static Insertable<WatchHistoryData> custom({
    Expression<int>? id,
    Expression<String>? movieSlug,
    Expression<String>? movieName,
    Expression<String>? posterUrl,
    Expression<String>? episodeName,
    Expression<String>? episodeSlug,
    Expression<String>? serverName,
    Expression<int>? positionMs,
    Expression<int>? durationMs,
    Expression<DateTime>? updatedAt,
    Expression<String>? sourceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (movieSlug != null) 'movie_slug': movieSlug,
      if (movieName != null) 'movie_name': movieName,
      if (posterUrl != null) 'poster_url': posterUrl,
      if (episodeName != null) 'episode_name': episodeName,
      if (episodeSlug != null) 'episode_slug': episodeSlug,
      if (serverName != null) 'server_name': serverName,
      if (positionMs != null) 'position_ms': positionMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sourceId != null) 'source_id': sourceId,
    });
  }

  WatchHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? movieSlug,
    Value<String>? movieName,
    Value<String?>? posterUrl,
    Value<String>? episodeName,
    Value<String>? episodeSlug,
    Value<String>? serverName,
    Value<int>? positionMs,
    Value<int>? durationMs,
    Value<DateTime>? updatedAt,
    Value<String>? sourceId,
  }) {
    return WatchHistoryCompanion(
      id: id ?? this.id,
      movieSlug: movieSlug ?? this.movieSlug,
      movieName: movieName ?? this.movieName,
      posterUrl: posterUrl ?? this.posterUrl,
      episodeName: episodeName ?? this.episodeName,
      episodeSlug: episodeSlug ?? this.episodeSlug,
      serverName: serverName ?? this.serverName,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceId: sourceId ?? this.sourceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (movieSlug.present) {
      map['movie_slug'] = Variable<String>(movieSlug.value);
    }
    if (movieName.present) {
      map['movie_name'] = Variable<String>(movieName.value);
    }
    if (posterUrl.present) {
      map['poster_url'] = Variable<String>(posterUrl.value);
    }
    if (episodeName.present) {
      map['episode_name'] = Variable<String>(episodeName.value);
    }
    if (episodeSlug.present) {
      map['episode_slug'] = Variable<String>(episodeSlug.value);
    }
    if (serverName.present) {
      map['server_name'] = Variable<String>(serverName.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchHistoryCompanion(')
          ..write('id: $id, ')
          ..write('movieSlug: $movieSlug, ')
          ..write('movieName: $movieName, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('episodeName: $episodeName, ')
          ..write('episodeSlug: $episodeSlug, ')
          ..write('serverName: $serverName, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sourceId: $sourceId')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _movieSlugMeta = const VerificationMeta(
    'movieSlug',
  );
  @override
  late final GeneratedColumn<String> movieSlug = GeneratedColumn<String>(
    'movie_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movieNameMeta = const VerificationMeta(
    'movieName',
  );
  @override
  late final GeneratedColumn<String> movieName = GeneratedColumn<String>(
    'movie_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posterUrlMeta = const VerificationMeta(
    'posterUrl',
  );
  @override
  late final GeneratedColumn<String> posterUrl = GeneratedColumn<String>(
    'poster_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('kkphim'),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataJsonMeta = const VerificationMeta(
    'dataJson',
  );
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
    'data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    movieSlug,
    movieName,
    posterUrl,
    year,
    sourceId,
    addedAt,
    dataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('movie_slug')) {
      context.handle(
        _movieSlugMeta,
        movieSlug.isAcceptableOrUnknown(data['movie_slug']!, _movieSlugMeta),
      );
    } else if (isInserting) {
      context.missing(_movieSlugMeta);
    }
    if (data.containsKey('movie_name')) {
      context.handle(
        _movieNameMeta,
        movieName.isAcceptableOrUnknown(data['movie_name']!, _movieNameMeta),
      );
    } else if (isInserting) {
      context.missing(_movieNameMeta);
    }
    if (data.containsKey('poster_url')) {
      context.handle(
        _posterUrlMeta,
        posterUrl.isAcceptableOrUnknown(data['poster_url']!, _posterUrlMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('data_json')) {
      context.handle(
        _dataJsonMeta,
        dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {movieSlug};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      movieSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movie_slug'],
      )!,
      movieName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movie_name'],
      )!,
      posterUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_url'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      dataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_json'],
      ),
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final String movieSlug;
  final String movieName;
  final String? posterUrl;
  final int? year;
  final String sourceId;
  final DateTime addedAt;
  final String? dataJson;
  const Bookmark({
    required this.movieSlug,
    required this.movieName,
    this.posterUrl,
    this.year,
    required this.sourceId,
    required this.addedAt,
    this.dataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['movie_slug'] = Variable<String>(movieSlug);
    map['movie_name'] = Variable<String>(movieName);
    if (!nullToAbsent || posterUrl != null) {
      map['poster_url'] = Variable<String>(posterUrl);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    map['source_id'] = Variable<String>(sourceId);
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || dataJson != null) {
      map['data_json'] = Variable<String>(dataJson);
    }
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      movieSlug: Value(movieSlug),
      movieName: Value(movieName),
      posterUrl: posterUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(posterUrl),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      sourceId: Value(sourceId),
      addedAt: Value(addedAt),
      dataJson: dataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(dataJson),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      movieSlug: serializer.fromJson<String>(json['movieSlug']),
      movieName: serializer.fromJson<String>(json['movieName']),
      posterUrl: serializer.fromJson<String?>(json['posterUrl']),
      year: serializer.fromJson<int?>(json['year']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      dataJson: serializer.fromJson<String?>(json['dataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'movieSlug': serializer.toJson<String>(movieSlug),
      'movieName': serializer.toJson<String>(movieName),
      'posterUrl': serializer.toJson<String?>(posterUrl),
      'year': serializer.toJson<int?>(year),
      'sourceId': serializer.toJson<String>(sourceId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'dataJson': serializer.toJson<String?>(dataJson),
    };
  }

  Bookmark copyWith({
    String? movieSlug,
    String? movieName,
    Value<String?> posterUrl = const Value.absent(),
    Value<int?> year = const Value.absent(),
    String? sourceId,
    DateTime? addedAt,
    Value<String?> dataJson = const Value.absent(),
  }) => Bookmark(
    movieSlug: movieSlug ?? this.movieSlug,
    movieName: movieName ?? this.movieName,
    posterUrl: posterUrl.present ? posterUrl.value : this.posterUrl,
    year: year.present ? year.value : this.year,
    sourceId: sourceId ?? this.sourceId,
    addedAt: addedAt ?? this.addedAt,
    dataJson: dataJson.present ? dataJson.value : this.dataJson,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      movieSlug: data.movieSlug.present ? data.movieSlug.value : this.movieSlug,
      movieName: data.movieName.present ? data.movieName.value : this.movieName,
      posterUrl: data.posterUrl.present ? data.posterUrl.value : this.posterUrl,
      year: data.year.present ? data.year.value : this.year,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('movieSlug: $movieSlug, ')
          ..write('movieName: $movieName, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('year: $year, ')
          ..write('sourceId: $sourceId, ')
          ..write('addedAt: $addedAt, ')
          ..write('dataJson: $dataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    movieSlug,
    movieName,
    posterUrl,
    year,
    sourceId,
    addedAt,
    dataJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.movieSlug == this.movieSlug &&
          other.movieName == this.movieName &&
          other.posterUrl == this.posterUrl &&
          other.year == this.year &&
          other.sourceId == this.sourceId &&
          other.addedAt == this.addedAt &&
          other.dataJson == this.dataJson);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<String> movieSlug;
  final Value<String> movieName;
  final Value<String?> posterUrl;
  final Value<int?> year;
  final Value<String> sourceId;
  final Value<DateTime> addedAt;
  final Value<String?> dataJson;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.movieSlug = const Value.absent(),
    this.movieName = const Value.absent(),
    this.posterUrl = const Value.absent(),
    this.year = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String movieSlug,
    required String movieName,
    this.posterUrl = const Value.absent(),
    this.year = const Value.absent(),
    this.sourceId = const Value.absent(),
    required DateTime addedAt,
    this.dataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : movieSlug = Value(movieSlug),
       movieName = Value(movieName),
       addedAt = Value(addedAt);
  static Insertable<Bookmark> custom({
    Expression<String>? movieSlug,
    Expression<String>? movieName,
    Expression<String>? posterUrl,
    Expression<int>? year,
    Expression<String>? sourceId,
    Expression<DateTime>? addedAt,
    Expression<String>? dataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (movieSlug != null) 'movie_slug': movieSlug,
      if (movieName != null) 'movie_name': movieName,
      if (posterUrl != null) 'poster_url': posterUrl,
      if (year != null) 'year': year,
      if (sourceId != null) 'source_id': sourceId,
      if (addedAt != null) 'added_at': addedAt,
      if (dataJson != null) 'data_json': dataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith({
    Value<String>? movieSlug,
    Value<String>? movieName,
    Value<String?>? posterUrl,
    Value<int?>? year,
    Value<String>? sourceId,
    Value<DateTime>? addedAt,
    Value<String?>? dataJson,
    Value<int>? rowid,
  }) {
    return BookmarksCompanion(
      movieSlug: movieSlug ?? this.movieSlug,
      movieName: movieName ?? this.movieName,
      posterUrl: posterUrl ?? this.posterUrl,
      year: year ?? this.year,
      sourceId: sourceId ?? this.sourceId,
      addedAt: addedAt ?? this.addedAt,
      dataJson: dataJson ?? this.dataJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (movieSlug.present) {
      map['movie_slug'] = Variable<String>(movieSlug.value);
    }
    if (movieName.present) {
      map['movie_name'] = Variable<String>(movieName.value);
    }
    if (posterUrl.present) {
      map['poster_url'] = Variable<String>(posterUrl.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('movieSlug: $movieSlug, ')
          ..write('movieName: $movieName, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('year: $year, ')
          ..write('sourceId: $sourceId, ')
          ..write('addedAt: $addedAt, ')
          ..write('dataJson: $dataJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConfigCacheTable extends ConfigCache
    with TableInfo<$ConfigCacheTable, ConfigCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfigCacheTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json, version, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'config_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfigCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConfigCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfigCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ConfigCacheTable createAlias(String alias) {
    return $ConfigCacheTable(attachedDatabase, alias);
  }
}

class ConfigCacheData extends DataClass implements Insertable<ConfigCacheData> {
  final int id;
  final String json;
  final int version;
  final DateTime updatedAt;
  const ConfigCacheData({
    required this.id,
    required this.json,
    required this.version,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['json'] = Variable<String>(json);
    map['version'] = Variable<int>(version);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConfigCacheCompanion toCompanion(bool nullToAbsent) {
    return ConfigCacheCompanion(
      id: Value(id),
      json: Value(json),
      version: Value(version),
      updatedAt: Value(updatedAt),
    );
  }

  factory ConfigCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfigCacheData(
      id: serializer.fromJson<int>(json['id']),
      json: serializer.fromJson<String>(json['json']),
      version: serializer.fromJson<int>(json['version']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'json': serializer.toJson<String>(json),
      'version': serializer.toJson<int>(version),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ConfigCacheData copyWith({
    int? id,
    String? json,
    int? version,
    DateTime? updatedAt,
  }) => ConfigCacheData(
    id: id ?? this.id,
    json: json ?? this.json,
    version: version ?? this.version,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ConfigCacheData copyWithCompanion(ConfigCacheCompanion data) {
    return ConfigCacheData(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfigCacheData(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json, version, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfigCacheData &&
          other.id == this.id &&
          other.json == this.json &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt);
}

class ConfigCacheCompanion extends UpdateCompanion<ConfigCacheData> {
  final Value<int> id;
  final Value<String> json;
  final Value<int> version;
  final Value<DateTime> updatedAt;
  const ConfigCacheCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ConfigCacheCompanion.insert({
    this.id = const Value.absent(),
    required String json,
    required int version,
    required DateTime updatedAt,
  }) : json = Value(json),
       version = Value(version),
       updatedAt = Value(updatedAt);
  static Insertable<ConfigCacheData> custom({
    Expression<int>? id,
    Expression<String>? json,
    Expression<int>? version,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ConfigCacheCompanion copyWith({
    Value<int>? id,
    Value<String>? json,
    Value<int>? version,
    Value<DateTime>? updatedAt,
  }) {
    return ConfigCacheCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfigCacheCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DownloadsTable extends Downloads
    with TableInfo<$DownloadsTable, Download> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _movieSlugMeta = const VerificationMeta(
    'movieSlug',
  );
  @override
  late final GeneratedColumn<String> movieSlug = GeneratedColumn<String>(
    'movie_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movieNameMeta = const VerificationMeta(
    'movieName',
  );
  @override
  late final GeneratedColumn<String> movieName = GeneratedColumn<String>(
    'movie_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posterUrlMeta = const VerificationMeta(
    'posterUrl',
  );
  @override
  late final GeneratedColumn<String> posterUrl = GeneratedColumn<String>(
    'poster_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeNameMeta = const VerificationMeta(
    'episodeName',
  );
  @override
  late final GeneratedColumn<String> episodeName = GeneratedColumn<String>(
    'episode_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodeSlugMeta = const VerificationMeta(
    'episodeSlug',
  );
  @override
  late final GeneratedColumn<String> episodeSlug = GeneratedColumn<String>(
    'episode_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverNameMeta = const VerificationMeta(
    'serverName',
  );
  @override
  late final GeneratedColumn<String> serverName = GeneratedColumn<String>(
    'server_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Vietsub'),
  );
  static const VerificationMeta _remoteM3u8Meta = const VerificationMeta(
    'remoteM3u8',
  );
  @override
  late final GeneratedColumn<String> remoteM3u8 = GeneratedColumn<String>(
    'remote_m3u8',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localM3u8Meta = const VerificationMeta(
    'localM3u8',
  );
  @override
  late final GeneratedColumn<String> localM3u8 = GeneratedColumn<String>(
    'local_m3u8',
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
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalSegmentsMeta = const VerificationMeta(
    'totalSegments',
  );
  @override
  late final GeneratedColumn<int> totalSegments = GeneratedColumn<int>(
    'total_segments',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _downloadedSegmentsMeta =
      const VerificationMeta('downloadedSegments');
  @override
  late final GeneratedColumn<int> downloadedSegments = GeneratedColumn<int>(
    'downloaded_segments',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    movieSlug,
    movieName,
    posterUrl,
    episodeName,
    episodeSlug,
    serverName,
    remoteM3u8,
    localM3u8,
    status,
    progress,
    totalSegments,
    downloadedSegments,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<Download> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('movie_slug')) {
      context.handle(
        _movieSlugMeta,
        movieSlug.isAcceptableOrUnknown(data['movie_slug']!, _movieSlugMeta),
      );
    } else if (isInserting) {
      context.missing(_movieSlugMeta);
    }
    if (data.containsKey('movie_name')) {
      context.handle(
        _movieNameMeta,
        movieName.isAcceptableOrUnknown(data['movie_name']!, _movieNameMeta),
      );
    } else if (isInserting) {
      context.missing(_movieNameMeta);
    }
    if (data.containsKey('poster_url')) {
      context.handle(
        _posterUrlMeta,
        posterUrl.isAcceptableOrUnknown(data['poster_url']!, _posterUrlMeta),
      );
    }
    if (data.containsKey('episode_name')) {
      context.handle(
        _episodeNameMeta,
        episodeName.isAcceptableOrUnknown(
          data['episode_name']!,
          _episodeNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_episodeNameMeta);
    }
    if (data.containsKey('episode_slug')) {
      context.handle(
        _episodeSlugMeta,
        episodeSlug.isAcceptableOrUnknown(
          data['episode_slug']!,
          _episodeSlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_episodeSlugMeta);
    }
    if (data.containsKey('server_name')) {
      context.handle(
        _serverNameMeta,
        serverName.isAcceptableOrUnknown(data['server_name']!, _serverNameMeta),
      );
    }
    if (data.containsKey('remote_m3u8')) {
      context.handle(
        _remoteM3u8Meta,
        remoteM3u8.isAcceptableOrUnknown(data['remote_m3u8']!, _remoteM3u8Meta),
      );
    } else if (isInserting) {
      context.missing(_remoteM3u8Meta);
    }
    if (data.containsKey('local_m3u8')) {
      context.handle(
        _localM3u8Meta,
        localM3u8.isAcceptableOrUnknown(data['local_m3u8']!, _localM3u8Meta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('total_segments')) {
      context.handle(
        _totalSegmentsMeta,
        totalSegments.isAcceptableOrUnknown(
          data['total_segments']!,
          _totalSegmentsMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_segments')) {
      context.handle(
        _downloadedSegmentsMeta,
        downloadedSegments.isAcceptableOrUnknown(
          data['downloaded_segments']!,
          _downloadedSegmentsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {movieSlug, episodeSlug, serverName},
  ];
  @override
  Download map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Download(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      movieSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movie_slug'],
      )!,
      movieName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movie_name'],
      )!,
      posterUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_url'],
      ),
      episodeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_name'],
      )!,
      episodeSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_slug'],
      )!,
      serverName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_name'],
      )!,
      remoteM3u8: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_m3u8'],
      )!,
      localM3u8: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_m3u8'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      totalSegments: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_segments'],
      )!,
      downloadedSegments: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_segments'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $DownloadsTable createAlias(String alias) {
    return $DownloadsTable(attachedDatabase, alias);
  }
}

class Download extends DataClass implements Insertable<Download> {
  final int id;
  final String movieSlug;
  final String movieName;
  final String? posterUrl;
  final String episodeName;
  final String episodeSlug;
  final String serverName;
  final String remoteM3u8;
  final String? localM3u8;
  final String status;
  final int progress;
  final int totalSegments;
  final int downloadedSegments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Download({
    required this.id,
    required this.movieSlug,
    required this.movieName,
    this.posterUrl,
    required this.episodeName,
    required this.episodeSlug,
    required this.serverName,
    required this.remoteM3u8,
    this.localM3u8,
    required this.status,
    required this.progress,
    required this.totalSegments,
    required this.downloadedSegments,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['movie_slug'] = Variable<String>(movieSlug);
    map['movie_name'] = Variable<String>(movieName);
    if (!nullToAbsent || posterUrl != null) {
      map['poster_url'] = Variable<String>(posterUrl);
    }
    map['episode_name'] = Variable<String>(episodeName);
    map['episode_slug'] = Variable<String>(episodeSlug);
    map['server_name'] = Variable<String>(serverName);
    map['remote_m3u8'] = Variable<String>(remoteM3u8);
    if (!nullToAbsent || localM3u8 != null) {
      map['local_m3u8'] = Variable<String>(localM3u8);
    }
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<int>(progress);
    map['total_segments'] = Variable<int>(totalSegments);
    map['downloaded_segments'] = Variable<int>(downloadedSegments);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  DownloadsCompanion toCompanion(bool nullToAbsent) {
    return DownloadsCompanion(
      id: Value(id),
      movieSlug: Value(movieSlug),
      movieName: Value(movieName),
      posterUrl: posterUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(posterUrl),
      episodeName: Value(episodeName),
      episodeSlug: Value(episodeSlug),
      serverName: Value(serverName),
      remoteM3u8: Value(remoteM3u8),
      localM3u8: localM3u8 == null && nullToAbsent
          ? const Value.absent()
          : Value(localM3u8),
      status: Value(status),
      progress: Value(progress),
      totalSegments: Value(totalSegments),
      downloadedSegments: Value(downloadedSegments),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Download.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Download(
      id: serializer.fromJson<int>(json['id']),
      movieSlug: serializer.fromJson<String>(json['movieSlug']),
      movieName: serializer.fromJson<String>(json['movieName']),
      posterUrl: serializer.fromJson<String?>(json['posterUrl']),
      episodeName: serializer.fromJson<String>(json['episodeName']),
      episodeSlug: serializer.fromJson<String>(json['episodeSlug']),
      serverName: serializer.fromJson<String>(json['serverName']),
      remoteM3u8: serializer.fromJson<String>(json['remoteM3u8']),
      localM3u8: serializer.fromJson<String?>(json['localM3u8']),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<int>(json['progress']),
      totalSegments: serializer.fromJson<int>(json['totalSegments']),
      downloadedSegments: serializer.fromJson<int>(json['downloadedSegments']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'movieSlug': serializer.toJson<String>(movieSlug),
      'movieName': serializer.toJson<String>(movieName),
      'posterUrl': serializer.toJson<String?>(posterUrl),
      'episodeName': serializer.toJson<String>(episodeName),
      'episodeSlug': serializer.toJson<String>(episodeSlug),
      'serverName': serializer.toJson<String>(serverName),
      'remoteM3u8': serializer.toJson<String>(remoteM3u8),
      'localM3u8': serializer.toJson<String?>(localM3u8),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<int>(progress),
      'totalSegments': serializer.toJson<int>(totalSegments),
      'downloadedSegments': serializer.toJson<int>(downloadedSegments),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Download copyWith({
    int? id,
    String? movieSlug,
    String? movieName,
    Value<String?> posterUrl = const Value.absent(),
    String? episodeName,
    String? episodeSlug,
    String? serverName,
    String? remoteM3u8,
    Value<String?> localM3u8 = const Value.absent(),
    String? status,
    int? progress,
    int? totalSegments,
    int? downloadedSegments,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => Download(
    id: id ?? this.id,
    movieSlug: movieSlug ?? this.movieSlug,
    movieName: movieName ?? this.movieName,
    posterUrl: posterUrl.present ? posterUrl.value : this.posterUrl,
    episodeName: episodeName ?? this.episodeName,
    episodeSlug: episodeSlug ?? this.episodeSlug,
    serverName: serverName ?? this.serverName,
    remoteM3u8: remoteM3u8 ?? this.remoteM3u8,
    localM3u8: localM3u8.present ? localM3u8.value : this.localM3u8,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    totalSegments: totalSegments ?? this.totalSegments,
    downloadedSegments: downloadedSegments ?? this.downloadedSegments,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Download copyWithCompanion(DownloadsCompanion data) {
    return Download(
      id: data.id.present ? data.id.value : this.id,
      movieSlug: data.movieSlug.present ? data.movieSlug.value : this.movieSlug,
      movieName: data.movieName.present ? data.movieName.value : this.movieName,
      posterUrl: data.posterUrl.present ? data.posterUrl.value : this.posterUrl,
      episodeName: data.episodeName.present
          ? data.episodeName.value
          : this.episodeName,
      episodeSlug: data.episodeSlug.present
          ? data.episodeSlug.value
          : this.episodeSlug,
      serverName: data.serverName.present
          ? data.serverName.value
          : this.serverName,
      remoteM3u8: data.remoteM3u8.present
          ? data.remoteM3u8.value
          : this.remoteM3u8,
      localM3u8: data.localM3u8.present ? data.localM3u8.value : this.localM3u8,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      totalSegments: data.totalSegments.present
          ? data.totalSegments.value
          : this.totalSegments,
      downloadedSegments: data.downloadedSegments.present
          ? data.downloadedSegments.value
          : this.downloadedSegments,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Download(')
          ..write('id: $id, ')
          ..write('movieSlug: $movieSlug, ')
          ..write('movieName: $movieName, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('episodeName: $episodeName, ')
          ..write('episodeSlug: $episodeSlug, ')
          ..write('serverName: $serverName, ')
          ..write('remoteM3u8: $remoteM3u8, ')
          ..write('localM3u8: $localM3u8, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('totalSegments: $totalSegments, ')
          ..write('downloadedSegments: $downloadedSegments, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    movieSlug,
    movieName,
    posterUrl,
    episodeName,
    episodeSlug,
    serverName,
    remoteM3u8,
    localM3u8,
    status,
    progress,
    totalSegments,
    downloadedSegments,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Download &&
          other.id == this.id &&
          other.movieSlug == this.movieSlug &&
          other.movieName == this.movieName &&
          other.posterUrl == this.posterUrl &&
          other.episodeName == this.episodeName &&
          other.episodeSlug == this.episodeSlug &&
          other.serverName == this.serverName &&
          other.remoteM3u8 == this.remoteM3u8 &&
          other.localM3u8 == this.localM3u8 &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.totalSegments == this.totalSegments &&
          other.downloadedSegments == this.downloadedSegments &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DownloadsCompanion extends UpdateCompanion<Download> {
  final Value<int> id;
  final Value<String> movieSlug;
  final Value<String> movieName;
  final Value<String?> posterUrl;
  final Value<String> episodeName;
  final Value<String> episodeSlug;
  final Value<String> serverName;
  final Value<String> remoteM3u8;
  final Value<String?> localM3u8;
  final Value<String> status;
  final Value<int> progress;
  final Value<int> totalSegments;
  final Value<int> downloadedSegments;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const DownloadsCompanion({
    this.id = const Value.absent(),
    this.movieSlug = const Value.absent(),
    this.movieName = const Value.absent(),
    this.posterUrl = const Value.absent(),
    this.episodeName = const Value.absent(),
    this.episodeSlug = const Value.absent(),
    this.serverName = const Value.absent(),
    this.remoteM3u8 = const Value.absent(),
    this.localM3u8 = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.totalSegments = const Value.absent(),
    this.downloadedSegments = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DownloadsCompanion.insert({
    this.id = const Value.absent(),
    required String movieSlug,
    required String movieName,
    this.posterUrl = const Value.absent(),
    required String episodeName,
    required String episodeSlug,
    this.serverName = const Value.absent(),
    required String remoteM3u8,
    this.localM3u8 = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.totalSegments = const Value.absent(),
    this.downloadedSegments = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
  }) : movieSlug = Value(movieSlug),
       movieName = Value(movieName),
       episodeName = Value(episodeName),
       episodeSlug = Value(episodeSlug),
       remoteM3u8 = Value(remoteM3u8),
       createdAt = Value(createdAt);
  static Insertable<Download> custom({
    Expression<int>? id,
    Expression<String>? movieSlug,
    Expression<String>? movieName,
    Expression<String>? posterUrl,
    Expression<String>? episodeName,
    Expression<String>? episodeSlug,
    Expression<String>? serverName,
    Expression<String>? remoteM3u8,
    Expression<String>? localM3u8,
    Expression<String>? status,
    Expression<int>? progress,
    Expression<int>? totalSegments,
    Expression<int>? downloadedSegments,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (movieSlug != null) 'movie_slug': movieSlug,
      if (movieName != null) 'movie_name': movieName,
      if (posterUrl != null) 'poster_url': posterUrl,
      if (episodeName != null) 'episode_name': episodeName,
      if (episodeSlug != null) 'episode_slug': episodeSlug,
      if (serverName != null) 'server_name': serverName,
      if (remoteM3u8 != null) 'remote_m3u8': remoteM3u8,
      if (localM3u8 != null) 'local_m3u8': localM3u8,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (totalSegments != null) 'total_segments': totalSegments,
      if (downloadedSegments != null) 'downloaded_segments': downloadedSegments,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DownloadsCompanion copyWith({
    Value<int>? id,
    Value<String>? movieSlug,
    Value<String>? movieName,
    Value<String?>? posterUrl,
    Value<String>? episodeName,
    Value<String>? episodeSlug,
    Value<String>? serverName,
    Value<String>? remoteM3u8,
    Value<String?>? localM3u8,
    Value<String>? status,
    Value<int>? progress,
    Value<int>? totalSegments,
    Value<int>? downloadedSegments,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return DownloadsCompanion(
      id: id ?? this.id,
      movieSlug: movieSlug ?? this.movieSlug,
      movieName: movieName ?? this.movieName,
      posterUrl: posterUrl ?? this.posterUrl,
      episodeName: episodeName ?? this.episodeName,
      episodeSlug: episodeSlug ?? this.episodeSlug,
      serverName: serverName ?? this.serverName,
      remoteM3u8: remoteM3u8 ?? this.remoteM3u8,
      localM3u8: localM3u8 ?? this.localM3u8,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalSegments: totalSegments ?? this.totalSegments,
      downloadedSegments: downloadedSegments ?? this.downloadedSegments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (movieSlug.present) {
      map['movie_slug'] = Variable<String>(movieSlug.value);
    }
    if (movieName.present) {
      map['movie_name'] = Variable<String>(movieName.value);
    }
    if (posterUrl.present) {
      map['poster_url'] = Variable<String>(posterUrl.value);
    }
    if (episodeName.present) {
      map['episode_name'] = Variable<String>(episodeName.value);
    }
    if (episodeSlug.present) {
      map['episode_slug'] = Variable<String>(episodeSlug.value);
    }
    if (serverName.present) {
      map['server_name'] = Variable<String>(serverName.value);
    }
    if (remoteM3u8.present) {
      map['remote_m3u8'] = Variable<String>(remoteM3u8.value);
    }
    if (localM3u8.present) {
      map['local_m3u8'] = Variable<String>(localM3u8.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (totalSegments.present) {
      map['total_segments'] = Variable<int>(totalSegments.value);
    }
    if (downloadedSegments.present) {
      map['downloaded_segments'] = Variable<int>(downloadedSegments.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsCompanion(')
          ..write('id: $id, ')
          ..write('movieSlug: $movieSlug, ')
          ..write('movieName: $movieName, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('episodeName: $episodeName, ')
          ..write('episodeSlug: $episodeSlug, ')
          ..write('serverName: $serverName, ')
          ..write('remoteM3u8: $remoteM3u8, ')
          ..write('localM3u8: $localM3u8, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('totalSegments: $totalSegments, ')
          ..write('downloadedSegments: $downloadedSegments, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WatchHistoryTable watchHistory = $WatchHistoryTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $ConfigCacheTable configCache = $ConfigCacheTable(this);
  late final $DownloadsTable downloads = $DownloadsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    watchHistory,
    bookmarks,
    configCache,
    downloads,
  ];
}

typedef $$WatchHistoryTableCreateCompanionBuilder =
    WatchHistoryCompanion Function({
      Value<int> id,
      required String movieSlug,
      required String movieName,
      Value<String?> posterUrl,
      required String episodeName,
      required String episodeSlug,
      Value<String> serverName,
      Value<int> positionMs,
      Value<int> durationMs,
      required DateTime updatedAt,
      Value<String> sourceId,
    });
typedef $$WatchHistoryTableUpdateCompanionBuilder =
    WatchHistoryCompanion Function({
      Value<int> id,
      Value<String> movieSlug,
      Value<String> movieName,
      Value<String?> posterUrl,
      Value<String> episodeName,
      Value<String> episodeSlug,
      Value<String> serverName,
      Value<int> positionMs,
      Value<int> durationMs,
      Value<DateTime> updatedAt,
      Value<String> sourceId,
    });

class $$WatchHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $WatchHistoryTable> {
  $$WatchHistoryTableFilterComposer({
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

  ColumnFilters<String> get movieSlug => $composableBuilder(
    column: $table.movieSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movieName => $composableBuilder(
    column: $table.movieName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeName => $composableBuilder(
    column: $table.episodeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeSlug => $composableBuilder(
    column: $table.episodeSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverName => $composableBuilder(
    column: $table.serverName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WatchHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchHistoryTable> {
  $$WatchHistoryTableOrderingComposer({
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

  ColumnOrderings<String> get movieSlug => $composableBuilder(
    column: $table.movieSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movieName => $composableBuilder(
    column: $table.movieName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeName => $composableBuilder(
    column: $table.episodeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeSlug => $composableBuilder(
    column: $table.episodeSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverName => $composableBuilder(
    column: $table.serverName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WatchHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchHistoryTable> {
  $$WatchHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get movieSlug =>
      $composableBuilder(column: $table.movieSlug, builder: (column) => column);

  GeneratedColumn<String> get movieName =>
      $composableBuilder(column: $table.movieName, builder: (column) => column);

  GeneratedColumn<String> get posterUrl =>
      $composableBuilder(column: $table.posterUrl, builder: (column) => column);

  GeneratedColumn<String> get episodeName => $composableBuilder(
    column: $table.episodeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get episodeSlug => $composableBuilder(
    column: $table.episodeSlug,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverName => $composableBuilder(
    column: $table.serverName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);
}

class $$WatchHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchHistoryTable,
          WatchHistoryData,
          $$WatchHistoryTableFilterComposer,
          $$WatchHistoryTableOrderingComposer,
          $$WatchHistoryTableAnnotationComposer,
          $$WatchHistoryTableCreateCompanionBuilder,
          $$WatchHistoryTableUpdateCompanionBuilder,
          (
            WatchHistoryData,
            BaseReferences<_$AppDatabase, $WatchHistoryTable, WatchHistoryData>,
          ),
          WatchHistoryData,
          PrefetchHooks Function()
        > {
  $$WatchHistoryTableTableManager(_$AppDatabase db, $WatchHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> movieSlug = const Value.absent(),
                Value<String> movieName = const Value.absent(),
                Value<String?> posterUrl = const Value.absent(),
                Value<String> episodeName = const Value.absent(),
                Value<String> episodeSlug = const Value.absent(),
                Value<String> serverName = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
              }) => WatchHistoryCompanion(
                id: id,
                movieSlug: movieSlug,
                movieName: movieName,
                posterUrl: posterUrl,
                episodeName: episodeName,
                episodeSlug: episodeSlug,
                serverName: serverName,
                positionMs: positionMs,
                durationMs: durationMs,
                updatedAt: updatedAt,
                sourceId: sourceId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String movieSlug,
                required String movieName,
                Value<String?> posterUrl = const Value.absent(),
                required String episodeName,
                required String episodeSlug,
                Value<String> serverName = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                required DateTime updatedAt,
                Value<String> sourceId = const Value.absent(),
              }) => WatchHistoryCompanion.insert(
                id: id,
                movieSlug: movieSlug,
                movieName: movieName,
                posterUrl: posterUrl,
                episodeName: episodeName,
                episodeSlug: episodeSlug,
                serverName: serverName,
                positionMs: positionMs,
                durationMs: durationMs,
                updatedAt: updatedAt,
                sourceId: sourceId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WatchHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchHistoryTable,
      WatchHistoryData,
      $$WatchHistoryTableFilterComposer,
      $$WatchHistoryTableOrderingComposer,
      $$WatchHistoryTableAnnotationComposer,
      $$WatchHistoryTableCreateCompanionBuilder,
      $$WatchHistoryTableUpdateCompanionBuilder,
      (
        WatchHistoryData,
        BaseReferences<_$AppDatabase, $WatchHistoryTable, WatchHistoryData>,
      ),
      WatchHistoryData,
      PrefetchHooks Function()
    >;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  required String movieSlug,
  required String movieName,
  Value<String?> posterUrl,
  Value<int?> year,
  Value<String> sourceId,
  required DateTime addedAt,
  Value<String?> dataJson,
  Value<int> rowid,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<String> movieSlug,
  Value<String> movieName,
  Value<String?> posterUrl,
  Value<int?> year,
  Value<String> sourceId,
  Value<DateTime> addedAt,
  Value<String?> dataJson,
  Value<int> rowid,
});

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get movieSlug => $composableBuilder(
    column: $table.movieSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movieName => $composableBuilder(
    column: $table.movieName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get movieSlug => $composableBuilder(
    column: $table.movieSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movieName => $composableBuilder(
    column: $table.movieName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get movieSlug =>
      $composableBuilder(column: $table.movieSlug, builder: (column) => column);

  GeneratedColumn<String> get movieName =>
      $composableBuilder(column: $table.movieName, builder: (column) => column);

  GeneratedColumn<String> get posterUrl =>
      $composableBuilder(column: $table.posterUrl, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
          Bookmark,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> movieSlug = const Value.absent(),
                Value<String> movieName = const Value.absent(),
                Value<String?> posterUrl = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<String?> dataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion(
                movieSlug: movieSlug,
                movieName: movieName,
                posterUrl: posterUrl,
                year: year,
                sourceId: sourceId,
                addedAt: addedAt,
                dataJson: dataJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String movieSlug,
                required String movieName,
                Value<String?> posterUrl = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                required DateTime addedAt,
                Value<String?> dataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion.insert(
                movieSlug: movieSlug,
                movieName: movieName,
                posterUrl: posterUrl,
                year: year,
                sourceId: sourceId,
                addedAt: addedAt,
                dataJson: dataJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
      Bookmark,
      PrefetchHooks Function()
    >;
typedef $$ConfigCacheTableCreateCompanionBuilder =
    ConfigCacheCompanion Function({
      Value<int> id,
      required String json,
      required int version,
      required DateTime updatedAt,
    });
typedef $$ConfigCacheTableUpdateCompanionBuilder =
    ConfigCacheCompanion Function({
      Value<int> id,
      Value<String> json,
      Value<int> version,
      Value<DateTime> updatedAt,
    });

class $$ConfigCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ConfigCacheTable> {
  $$ConfigCacheTableFilterComposer({
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

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfigCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfigCacheTable> {
  $$ConfigCacheTableOrderingComposer({
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

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfigCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfigCacheTable> {
  $$ConfigCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ConfigCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfigCacheTable,
          ConfigCacheData,
          $$ConfigCacheTableFilterComposer,
          $$ConfigCacheTableOrderingComposer,
          $$ConfigCacheTableAnnotationComposer,
          $$ConfigCacheTableCreateCompanionBuilder,
          $$ConfigCacheTableUpdateCompanionBuilder,
          (
            ConfigCacheData,
            BaseReferences<_$AppDatabase, $ConfigCacheTable, ConfigCacheData>,
          ),
          ConfigCacheData,
          PrefetchHooks Function()
        > {
  $$ConfigCacheTableTableManager(_$AppDatabase db, $ConfigCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfigCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfigCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfigCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ConfigCacheCompanion(
                id: id,
                json: json,
                version: version,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String json,
                required int version,
                required DateTime updatedAt,
              }) => ConfigCacheCompanion.insert(
                id: id,
                json: json,
                version: version,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfigCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfigCacheTable,
      ConfigCacheData,
      $$ConfigCacheTableFilterComposer,
      $$ConfigCacheTableOrderingComposer,
      $$ConfigCacheTableAnnotationComposer,
      $$ConfigCacheTableCreateCompanionBuilder,
      $$ConfigCacheTableUpdateCompanionBuilder,
      (
        ConfigCacheData,
        BaseReferences<_$AppDatabase, $ConfigCacheTable, ConfigCacheData>,
      ),
      ConfigCacheData,
      PrefetchHooks Function()
    >;
typedef $$DownloadsTableCreateCompanionBuilder = DownloadsCompanion Function({
  Value<int> id,
  required String movieSlug,
  required String movieName,
  Value<String?> posterUrl,
  required String episodeName,
  required String episodeSlug,
  Value<String> serverName,
  required String remoteM3u8,
  Value<String?> localM3u8,
  Value<String> status,
  Value<int> progress,
  Value<int> totalSegments,
  Value<int> downloadedSegments,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
});
typedef $$DownloadsTableUpdateCompanionBuilder = DownloadsCompanion Function({
  Value<int> id,
  Value<String> movieSlug,
  Value<String> movieName,
  Value<String?> posterUrl,
  Value<String> episodeName,
  Value<String> episodeSlug,
  Value<String> serverName,
  Value<String> remoteM3u8,
  Value<String?> localM3u8,
  Value<String> status,
  Value<int> progress,
  Value<int> totalSegments,
  Value<int> downloadedSegments,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
});

class $$DownloadsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableFilterComposer({
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

  ColumnFilters<String> get movieSlug => $composableBuilder(
    column: $table.movieSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movieName => $composableBuilder(
    column: $table.movieName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeName => $composableBuilder(
    column: $table.episodeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeSlug => $composableBuilder(
    column: $table.episodeSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverName => $composableBuilder(
    column: $table.serverName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteM3u8 => $composableBuilder(
    column: $table.remoteM3u8,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localM3u8 => $composableBuilder(
    column: $table.localM3u8,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSegments => $composableBuilder(
    column: $table.totalSegments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedSegments => $composableBuilder(
    column: $table.downloadedSegments,
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

class $$DownloadsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableOrderingComposer({
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

  ColumnOrderings<String> get movieSlug => $composableBuilder(
    column: $table.movieSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movieName => $composableBuilder(
    column: $table.movieName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeName => $composableBuilder(
    column: $table.episodeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeSlug => $composableBuilder(
    column: $table.episodeSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverName => $composableBuilder(
    column: $table.serverName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteM3u8 => $composableBuilder(
    column: $table.remoteM3u8,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localM3u8 => $composableBuilder(
    column: $table.localM3u8,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSegments => $composableBuilder(
    column: $table.totalSegments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedSegments => $composableBuilder(
    column: $table.downloadedSegments,
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

class $$DownloadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get movieSlug =>
      $composableBuilder(column: $table.movieSlug, builder: (column) => column);

  GeneratedColumn<String> get movieName =>
      $composableBuilder(column: $table.movieName, builder: (column) => column);

  GeneratedColumn<String> get posterUrl =>
      $composableBuilder(column: $table.posterUrl, builder: (column) => column);

  GeneratedColumn<String> get episodeName => $composableBuilder(
    column: $table.episodeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get episodeSlug => $composableBuilder(
    column: $table.episodeSlug,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverName => $composableBuilder(
    column: $table.serverName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteM3u8 => $composableBuilder(
    column: $table.remoteM3u8,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localM3u8 =>
      $composableBuilder(column: $table.localM3u8, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<int> get totalSegments => $composableBuilder(
    column: $table.totalSegments,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downloadedSegments => $composableBuilder(
    column: $table.downloadedSegments,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadsTable,
          Download,
          $$DownloadsTableFilterComposer,
          $$DownloadsTableOrderingComposer,
          $$DownloadsTableAnnotationComposer,
          $$DownloadsTableCreateCompanionBuilder,
          $$DownloadsTableUpdateCompanionBuilder,
          (Download, BaseReferences<_$AppDatabase, $DownloadsTable, Download>),
          Download,
          PrefetchHooks Function()
        > {
  $$DownloadsTableTableManager(_$AppDatabase db, $DownloadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> movieSlug = const Value.absent(),
                Value<String> movieName = const Value.absent(),
                Value<String?> posterUrl = const Value.absent(),
                Value<String> episodeName = const Value.absent(),
                Value<String> episodeSlug = const Value.absent(),
                Value<String> serverName = const Value.absent(),
                Value<String> remoteM3u8 = const Value.absent(),
                Value<String?> localM3u8 = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<int> totalSegments = const Value.absent(),
                Value<int> downloadedSegments = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => DownloadsCompanion(
                id: id,
                movieSlug: movieSlug,
                movieName: movieName,
                posterUrl: posterUrl,
                episodeName: episodeName,
                episodeSlug: episodeSlug,
                serverName: serverName,
                remoteM3u8: remoteM3u8,
                localM3u8: localM3u8,
                status: status,
                progress: progress,
                totalSegments: totalSegments,
                downloadedSegments: downloadedSegments,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String movieSlug,
                required String movieName,
                Value<String?> posterUrl = const Value.absent(),
                required String episodeName,
                required String episodeSlug,
                Value<String> serverName = const Value.absent(),
                required String remoteM3u8,
                Value<String?> localM3u8 = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<int> totalSegments = const Value.absent(),
                Value<int> downloadedSegments = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => DownloadsCompanion.insert(
                id: id,
                movieSlug: movieSlug,
                movieName: movieName,
                posterUrl: posterUrl,
                episodeName: episodeName,
                episodeSlug: episodeSlug,
                serverName: serverName,
                remoteM3u8: remoteM3u8,
                localM3u8: localM3u8,
                status: status,
                progress: progress,
                totalSegments: totalSegments,
                downloadedSegments: downloadedSegments,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadsTable,
      Download,
      $$DownloadsTableFilterComposer,
      $$DownloadsTableOrderingComposer,
      $$DownloadsTableAnnotationComposer,
      $$DownloadsTableCreateCompanionBuilder,
      $$DownloadsTableUpdateCompanionBuilder,
      (Download, BaseReferences<_$AppDatabase, $DownloadsTable, Download>),
      Download,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WatchHistoryTableTableManager get watchHistory =>
      $$WatchHistoryTableTableManager(_db, _db.watchHistory);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$ConfigCacheTableTableManager get configCache =>
      $$ConfigCacheTableTableManager(_db, _db.configCache);
  $$DownloadsTableTableManager get downloads =>
      $$DownloadsTableTableManager(_db, _db.downloads);
}
