// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayerState {

 String get movieSlug; String get episodeSlug; String get serverName; String get linkM3u8; Duration get position; Duration get duration; PlayerStatus get status; bool get isDownloading; String? get errorMessage; String? get localM3u8;
/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerStateCopyWith<PlayerState> get copyWith => _$PlayerStateCopyWithImpl<PlayerState>(this as PlayerState, _$identity);

  /// Serializes this PlayerState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlayerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerState&&(identical(other.movieSlug, _this.movieSlug) || other.movieSlug == _this.movieSlug)&&(identical(other.episodeSlug, _this.episodeSlug) || other.episodeSlug == _this.episodeSlug)&&(identical(other.serverName, _this.serverName) || other.serverName == _this.serverName)&&(identical(other.linkM3u8, _this.linkM3u8) || other.linkM3u8 == _this.linkM3u8)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.isDownloading, _this.isDownloading) || other.isDownloading == _this.isDownloading)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.localM3u8, _this.localM3u8) || other.localM3u8 == _this.localM3u8));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlayerState;
  return Object.hash(runtimeType,_this.movieSlug,_this.episodeSlug,_this.serverName,_this.linkM3u8,_this.position,_this.duration,_this.status,_this.isDownloading,_this.errorMessage,_this.localM3u8);
}

@override
String toString() {
  final _this = this as PlayerState;
  return 'PlayerState(movieSlug: ${_this.movieSlug}, episodeSlug: ${_this.episodeSlug}, serverName: ${_this.serverName}, linkM3u8: ${_this.linkM3u8}, position: ${_this.position}, duration: ${_this.duration}, status: ${_this.status}, isDownloading: ${_this.isDownloading}, errorMessage: ${_this.errorMessage}, localM3u8: ${_this.localM3u8})';
}


}

/// @nodoc
abstract mixin class $PlayerStateCopyWith<$Res>  {
  factory $PlayerStateCopyWith(PlayerState value, $Res Function(PlayerState) _then) = _$PlayerStateCopyWithImpl;
@useResult
$Res call({
 String movieSlug, String episodeSlug, String serverName, String linkM3u8, Duration position, Duration duration, PlayerStatus status, bool isDownloading, String? errorMessage, String? localM3u8
});




}
/// @nodoc
class _$PlayerStateCopyWithImpl<$Res>
    implements $PlayerStateCopyWith<$Res> {
  _$PlayerStateCopyWithImpl(this._self, this._then);

  final PlayerState _self;
  final $Res Function(PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? movieSlug = null,Object? episodeSlug = null,Object? serverName = null,Object? linkM3u8 = null,Object? position = null,Object? duration = null,Object? status = null,Object? isDownloading = null,Object? errorMessage = freezed,Object? localM3u8 = freezed,}) {
  return _then(PlayerState(
movieSlug: null == movieSlug ? _self.movieSlug : movieSlug // ignore: cast_nullable_to_non_nullable
as String,episodeSlug: null == episodeSlug ? _self.episodeSlug : episodeSlug // ignore: cast_nullable_to_non_nullable
as String,serverName: null == serverName ? _self.serverName : serverName // ignore: cast_nullable_to_non_nullable
as String,linkM3u8: null == linkM3u8 ? _self.linkM3u8 : linkM3u8 // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlayerStatus,isDownloading: null == isDownloading ? _self.isDownloading : isDownloading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,localM3u8: freezed == localM3u8 ? _self.localM3u8 : localM3u8 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerState].
extension PlayerStatePatterns on PlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerState value)  $default,){
final _that = this;
switch (_that) {
case _PlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String movieSlug,  String episodeSlug,  String serverName,  String linkM3u8,  Duration position,  Duration duration,  PlayerStatus status,  bool isDownloading,  String? errorMessage,  String? localM3u8)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.movieSlug,_that.episodeSlug,_that.serverName,_that.linkM3u8,_that.position,_that.duration,_that.status,_that.isDownloading,_that.errorMessage,_that.localM3u8);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String movieSlug,  String episodeSlug,  String serverName,  String linkM3u8,  Duration position,  Duration duration,  PlayerStatus status,  bool isDownloading,  String? errorMessage,  String? localM3u8)  $default,) {final _that = this;
switch (_that) {
case _PlayerState():
return $default(_that.movieSlug,_that.episodeSlug,_that.serverName,_that.linkM3u8,_that.position,_that.duration,_that.status,_that.isDownloading,_that.errorMessage,_that.localM3u8);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String movieSlug,  String episodeSlug,  String serverName,  String linkM3u8,  Duration position,  Duration duration,  PlayerStatus status,  bool isDownloading,  String? errorMessage,  String? localM3u8)?  $default,) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.movieSlug,_that.episodeSlug,_that.serverName,_that.linkM3u8,_that.position,_that.duration,_that.status,_that.isDownloading,_that.errorMessage,_that.localM3u8);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerState implements PlayerState {
  const _PlayerState({this.movieSlug = '', this.episodeSlug = '', this.serverName = '', this.linkM3u8 = '', this.position = Duration.zero, this.duration = Duration.zero, this.status = PlayerStatus.initial, this.isDownloading = false, this.errorMessage, this.localM3u8});
  factory _PlayerState.fromJson(Map<String, dynamic> json) => _$PlayerStateFromJson(json);

@override@JsonKey() final  String movieSlug;
@override@JsonKey() final  String episodeSlug;
@override@JsonKey() final  String serverName;
@override@JsonKey() final  String linkM3u8;
@override@JsonKey() final  Duration position;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  PlayerStatus status;
@override@JsonKey() final  bool isDownloading;
@override final  String? errorMessage;
@override final  String? localM3u8;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerStateCopyWith<_PlayerState> get copyWith => __$PlayerStateCopyWithImpl<_PlayerState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerState&&(identical(other.movieSlug, movieSlug) || other.movieSlug == movieSlug)&&(identical(other.episodeSlug, episodeSlug) || other.episodeSlug == episodeSlug)&&(identical(other.serverName, serverName) || other.serverName == serverName)&&(identical(other.linkM3u8, linkM3u8) || other.linkM3u8 == linkM3u8)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.status, status) || other.status == status)&&(identical(other.isDownloading, isDownloading) || other.isDownloading == isDownloading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.localM3u8, localM3u8) || other.localM3u8 == localM3u8));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,movieSlug,episodeSlug,serverName,linkM3u8,position,duration,status,isDownloading,errorMessage,localM3u8);
}

@override
String toString() {
    return 'PlayerState(movieSlug: $movieSlug, episodeSlug: $episodeSlug, serverName: $serverName, linkM3u8: $linkM3u8, position: $position, duration: $duration, status: $status, isDownloading: $isDownloading, errorMessage: $errorMessage, localM3u8: $localM3u8)';
}


}

/// @nodoc
abstract mixin class _$PlayerStateCopyWith<$Res> implements $PlayerStateCopyWith<$Res> {
  factory _$PlayerStateCopyWith(_PlayerState value, $Res Function(_PlayerState) _then) = __$PlayerStateCopyWithImpl;
@override @useResult
$Res call({
 String movieSlug, String episodeSlug, String serverName, String linkM3u8, Duration position, Duration duration, PlayerStatus status, bool isDownloading, String? errorMessage, String? localM3u8
});




}
/// @nodoc
class __$PlayerStateCopyWithImpl<$Res>
    implements _$PlayerStateCopyWith<$Res> {
  __$PlayerStateCopyWithImpl(this._self, this._then);

  final _PlayerState _self;
  final $Res Function(_PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? movieSlug = null,Object? episodeSlug = null,Object? serverName = null,Object? linkM3u8 = null,Object? position = null,Object? duration = null,Object? status = null,Object? isDownloading = null,Object? errorMessage = freezed,Object? localM3u8 = freezed,}) {
  return _then(_PlayerState(
movieSlug: null == movieSlug ? _self.movieSlug : movieSlug // ignore: cast_nullable_to_non_nullable
as String,episodeSlug: null == episodeSlug ? _self.episodeSlug : episodeSlug // ignore: cast_nullable_to_non_nullable
as String,serverName: null == serverName ? _self.serverName : serverName // ignore: cast_nullable_to_non_nullable
as String,linkM3u8: null == linkM3u8 ? _self.linkM3u8 : linkM3u8 // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlayerStatus,isDownloading: null == isDownloading ? _self.isDownloading : isDownloading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,localM3u8: freezed == localM3u8 ? _self.localM3u8 : localM3u8 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
