// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DetailState {

 DetailStatus get status;@JsonKey(includeFromJson: false, includeToJson: false) Movie? get movie;@JsonKey(includeFromJson: false, includeToJson: false) List<EpisodeServer> get servers; bool get isBookmarked; String? get errorMessage;
/// Create a copy of DetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetailStateCopyWith<DetailState> get copyWith => _$DetailStateCopyWithImpl<DetailState>(this as DetailState, _$identity);

  /// Serializes this DetailState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DetailState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetailState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.movie, _this.movie) || other.movie == _this.movie)&&const DeepCollectionEquality().equals(other.servers, _this.servers)&&(identical(other.isBookmarked, _this.isBookmarked) || other.isBookmarked == _this.isBookmarked)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DetailState;
  return Object.hash(runtimeType,_this.status,_this.movie,const DeepCollectionEquality().hash(_this.servers),_this.isBookmarked,_this.errorMessage);
}

@override
String toString() {
  final _this = this as DetailState;
  return 'DetailState(status: ${_this.status}, movie: ${_this.movie}, servers: ${_this.servers}, isBookmarked: ${_this.isBookmarked}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $DetailStateCopyWith<$Res>  {
  factory $DetailStateCopyWith(DetailState value, $Res Function(DetailState) _then) = _$DetailStateCopyWithImpl;
@useResult
$Res call({
 DetailStatus status,@JsonKey(includeFromJson: false, includeToJson: false) Movie? movie,@JsonKey(includeFromJson: false, includeToJson: false) List<EpisodeServer> servers, bool isBookmarked, String? errorMessage
});




}
/// @nodoc
class _$DetailStateCopyWithImpl<$Res>
    implements $DetailStateCopyWith<$Res> {
  _$DetailStateCopyWithImpl(this._self, this._then);

  final DetailState _self;
  final $Res Function(DetailState) _then;

/// Create a copy of DetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? movie = freezed,Object? servers = null,Object? isBookmarked = null,Object? errorMessage = freezed,}) {
  return _then(DetailState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DetailStatus,movie: freezed == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as Movie?,servers: null == servers ? _self.servers : servers // ignore: cast_nullable_to_non_nullable
as List<EpisodeServer>,isBookmarked: null == isBookmarked ? _self.isBookmarked : isBookmarked // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DetailState].
extension DetailStatePatterns on DetailState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetailState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetailState value)  $default,){
final _that = this;
switch (_that) {
case _DetailState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetailState value)?  $default,){
final _that = this;
switch (_that) {
case _DetailState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DetailStatus status, @JsonKey(includeFromJson: false, includeToJson: false)  Movie? movie, @JsonKey(includeFromJson: false, includeToJson: false)  List<EpisodeServer> servers,  bool isBookmarked,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetailState() when $default != null:
return $default(_that.status,_that.movie,_that.servers,_that.isBookmarked,_that.errorMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DetailStatus status, @JsonKey(includeFromJson: false, includeToJson: false)  Movie? movie, @JsonKey(includeFromJson: false, includeToJson: false)  List<EpisodeServer> servers,  bool isBookmarked,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _DetailState():
return $default(_that.status,_that.movie,_that.servers,_that.isBookmarked,_that.errorMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DetailStatus status, @JsonKey(includeFromJson: false, includeToJson: false)  Movie? movie, @JsonKey(includeFromJson: false, includeToJson: false)  List<EpisodeServer> servers,  bool isBookmarked,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _DetailState() when $default != null:
return $default(_that.status,_that.movie,_that.servers,_that.isBookmarked,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DetailState implements DetailState {
  const _DetailState({this.status = DetailStatus.initial, @JsonKey(includeFromJson: false, includeToJson: false) this.movie, @JsonKey(includeFromJson: false, includeToJson: false)  List<EpisodeServer> servers = const [], this.isBookmarked = false, this.errorMessage}): _servers = servers;
  factory _DetailState.fromJson(Map<String, dynamic> json) => _$DetailStateFromJson(json);

@override@JsonKey() final  DetailStatus status;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  Movie? movie;
 final  List<EpisodeServer> _servers;
@override@JsonKey(includeFromJson: false, includeToJson: false) List<EpisodeServer> get servers {
  if (_servers is EqualUnmodifiableListView) return _servers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_servers);
}

@override@JsonKey() final  bool isBookmarked;
@override final  String? errorMessage;

/// Create a copy of DetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetailStateCopyWith<_DetailState> get copyWith => __$DetailStateCopyWithImpl<_DetailState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DetailStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetailState&&(identical(other.status, status) || other.status == status)&&(identical(other.movie, movie) || other.movie == movie)&&const DeepCollectionEquality().equals(other.servers, _servers)&&(identical(other.isBookmarked, isBookmarked) || other.isBookmarked == isBookmarked)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,movie,const DeepCollectionEquality().hash(_servers),isBookmarked,errorMessage);
}

@override
String toString() {
    return 'DetailState(status: $status, movie: $movie, servers: $servers, isBookmarked: $isBookmarked, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$DetailStateCopyWith<$Res> implements $DetailStateCopyWith<$Res> {
  factory _$DetailStateCopyWith(_DetailState value, $Res Function(_DetailState) _then) = __$DetailStateCopyWithImpl;
@override @useResult
$Res call({
 DetailStatus status,@JsonKey(includeFromJson: false, includeToJson: false) Movie? movie,@JsonKey(includeFromJson: false, includeToJson: false) List<EpisodeServer> servers, bool isBookmarked, String? errorMessage
});




}
/// @nodoc
class __$DetailStateCopyWithImpl<$Res>
    implements _$DetailStateCopyWith<$Res> {
  __$DetailStateCopyWithImpl(this._self, this._then);

  final _DetailState _self;
  final $Res Function(_DetailState) _then;

/// Create a copy of DetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? movie = freezed,Object? servers = null,Object? isBookmarked = null,Object? errorMessage = freezed,}) {
  return _then(_DetailState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DetailStatus,movie: freezed == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as Movie?,servers: null == servers ? _self._servers : servers // ignore: cast_nullable_to_non_nullable
as List<EpisodeServer>,isBookmarked: null == isBookmarked ? _self.isBookmarked : isBookmarked // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
