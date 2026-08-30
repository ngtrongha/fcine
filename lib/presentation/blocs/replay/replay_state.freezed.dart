// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'replay_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReplayState {

 String get movieSlug; String get episodeSlug; String get serverName; Duration get position; Duration get duration; bool get isReplaying; bool get isCompleted; int get replayCount;
/// Create a copy of ReplayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplayStateCopyWith<ReplayState> get copyWith => _$ReplayStateCopyWithImpl<ReplayState>(this as ReplayState, _$identity);

  /// Serializes this ReplayState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReplayState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplayState&&(identical(other.movieSlug, _this.movieSlug) || other.movieSlug == _this.movieSlug)&&(identical(other.episodeSlug, _this.episodeSlug) || other.episodeSlug == _this.episodeSlug)&&(identical(other.serverName, _this.serverName) || other.serverName == _this.serverName)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.isReplaying, _this.isReplaying) || other.isReplaying == _this.isReplaying)&&(identical(other.isCompleted, _this.isCompleted) || other.isCompleted == _this.isCompleted)&&(identical(other.replayCount, _this.replayCount) || other.replayCount == _this.replayCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReplayState;
  return Object.hash(runtimeType,_this.movieSlug,_this.episodeSlug,_this.serverName,_this.position,_this.duration,_this.isReplaying,_this.isCompleted,_this.replayCount);
}

@override
String toString() {
  final _this = this as ReplayState;
  return 'ReplayState(movieSlug: ${_this.movieSlug}, episodeSlug: ${_this.episodeSlug}, serverName: ${_this.serverName}, position: ${_this.position}, duration: ${_this.duration}, isReplaying: ${_this.isReplaying}, isCompleted: ${_this.isCompleted}, replayCount: ${_this.replayCount})';
}


}

/// @nodoc
abstract mixin class $ReplayStateCopyWith<$Res>  {
  factory $ReplayStateCopyWith(ReplayState value, $Res Function(ReplayState) _then) = _$ReplayStateCopyWithImpl;
@useResult
$Res call({
 String movieSlug, String episodeSlug, String serverName, Duration position, Duration duration, bool isReplaying, bool isCompleted, int replayCount
});




}
/// @nodoc
class _$ReplayStateCopyWithImpl<$Res>
    implements $ReplayStateCopyWith<$Res> {
  _$ReplayStateCopyWithImpl(this._self, this._then);

  final ReplayState _self;
  final $Res Function(ReplayState) _then;

/// Create a copy of ReplayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? movieSlug = null,Object? episodeSlug = null,Object? serverName = null,Object? position = null,Object? duration = null,Object? isReplaying = null,Object? isCompleted = null,Object? replayCount = null,}) {
  return _then(ReplayState(
movieSlug: null == movieSlug ? _self.movieSlug : movieSlug // ignore: cast_nullable_to_non_nullable
as String,episodeSlug: null == episodeSlug ? _self.episodeSlug : episodeSlug // ignore: cast_nullable_to_non_nullable
as String,serverName: null == serverName ? _self.serverName : serverName // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,isReplaying: null == isReplaying ? _self.isReplaying : isReplaying // ignore: cast_nullable_to_non_nullable
as bool,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,replayCount: null == replayCount ? _self.replayCount : replayCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReplayState].
extension ReplayStatePatterns on ReplayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReplayState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReplayState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReplayState value)  $default,){
final _that = this;
switch (_that) {
case _ReplayState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReplayState value)?  $default,){
final _that = this;
switch (_that) {
case _ReplayState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String movieSlug,  String episodeSlug,  String serverName,  Duration position,  Duration duration,  bool isReplaying,  bool isCompleted,  int replayCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReplayState() when $default != null:
return $default(_that.movieSlug,_that.episodeSlug,_that.serverName,_that.position,_that.duration,_that.isReplaying,_that.isCompleted,_that.replayCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String movieSlug,  String episodeSlug,  String serverName,  Duration position,  Duration duration,  bool isReplaying,  bool isCompleted,  int replayCount)  $default,) {final _that = this;
switch (_that) {
case _ReplayState():
return $default(_that.movieSlug,_that.episodeSlug,_that.serverName,_that.position,_that.duration,_that.isReplaying,_that.isCompleted,_that.replayCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String movieSlug,  String episodeSlug,  String serverName,  Duration position,  Duration duration,  bool isReplaying,  bool isCompleted,  int replayCount)?  $default,) {final _that = this;
switch (_that) {
case _ReplayState() when $default != null:
return $default(_that.movieSlug,_that.episodeSlug,_that.serverName,_that.position,_that.duration,_that.isReplaying,_that.isCompleted,_that.replayCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReplayState implements ReplayState {
  const _ReplayState({this.movieSlug = '', this.episodeSlug = '', this.serverName = '', this.position = Duration.zero, this.duration = Duration.zero, this.isReplaying = false, this.isCompleted = false, this.replayCount = 0});
  factory _ReplayState.fromJson(Map<String, dynamic> json) => _$ReplayStateFromJson(json);

@override@JsonKey() final  String movieSlug;
@override@JsonKey() final  String episodeSlug;
@override@JsonKey() final  String serverName;
@override@JsonKey() final  Duration position;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  bool isReplaying;
@override@JsonKey() final  bool isCompleted;
@override@JsonKey() final  int replayCount;

/// Create a copy of ReplayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplayStateCopyWith<_ReplayState> get copyWith => __$ReplayStateCopyWithImpl<_ReplayState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplayStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReplayState&&(identical(other.movieSlug, movieSlug) || other.movieSlug == movieSlug)&&(identical(other.episodeSlug, episodeSlug) || other.episodeSlug == episodeSlug)&&(identical(other.serverName, serverName) || other.serverName == serverName)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.isReplaying, isReplaying) || other.isReplaying == isReplaying)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.replayCount, replayCount) || other.replayCount == replayCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,movieSlug,episodeSlug,serverName,position,duration,isReplaying,isCompleted,replayCount);
}

@override
String toString() {
    return 'ReplayState(movieSlug: $movieSlug, episodeSlug: $episodeSlug, serverName: $serverName, position: $position, duration: $duration, isReplaying: $isReplaying, isCompleted: $isCompleted, replayCount: $replayCount)';
}


}

/// @nodoc
abstract mixin class _$ReplayStateCopyWith<$Res> implements $ReplayStateCopyWith<$Res> {
  factory _$ReplayStateCopyWith(_ReplayState value, $Res Function(_ReplayState) _then) = __$ReplayStateCopyWithImpl;
@override @useResult
$Res call({
 String movieSlug, String episodeSlug, String serverName, Duration position, Duration duration, bool isReplaying, bool isCompleted, int replayCount
});




}
/// @nodoc
class __$ReplayStateCopyWithImpl<$Res>
    implements _$ReplayStateCopyWith<$Res> {
  __$ReplayStateCopyWithImpl(this._self, this._then);

  final _ReplayState _self;
  final $Res Function(_ReplayState) _then;

/// Create a copy of ReplayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? movieSlug = null,Object? episodeSlug = null,Object? serverName = null,Object? position = null,Object? duration = null,Object? isReplaying = null,Object? isCompleted = null,Object? replayCount = null,}) {
  return _then(_ReplayState(
movieSlug: null == movieSlug ? _self.movieSlug : movieSlug // ignore: cast_nullable_to_non_nullable
as String,episodeSlug: null == episodeSlug ? _self.episodeSlug : episodeSlug // ignore: cast_nullable_to_non_nullable
as String,serverName: null == serverName ? _self.serverName : serverName // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,isReplaying: null == isReplaying ? _self.isReplaying : isReplaying // ignore: cast_nullable_to_non_nullable
as bool,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,replayCount: null == replayCount ? _self.replayCount : replayCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
