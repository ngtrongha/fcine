// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'replay_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReplayEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplayEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ReplayEvent()';
}


}

/// @nodoc
class $ReplayEventCopyWith<$Res>  {
$ReplayEventCopyWith(ReplayEvent _, $Res Function(ReplayEvent) __);
}


/// Adds pattern-matching-related methods to [ReplayEvent].
extension ReplayEventPatterns on ReplayEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ReplayStarted value)?  started,TResult Function( ReplaySeekRequested value)?  seekRequested,TResult Function( ReplayRequested value)?  replayRequested,TResult Function( ReplayCompleted value)?  completed,TResult Function( ReplayReset value)?  reset,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ReplayStarted() when started != null:
return started(_that);case ReplaySeekRequested() when seekRequested != null:
return seekRequested(_that);case ReplayRequested() when replayRequested != null:
return replayRequested(_that);case ReplayCompleted() when completed != null:
return completed(_that);case ReplayReset() when reset != null:
return reset(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ReplayStarted value)  started,required TResult Function( ReplaySeekRequested value)  seekRequested,required TResult Function( ReplayRequested value)  replayRequested,required TResult Function( ReplayCompleted value)  completed,required TResult Function( ReplayReset value)  reset,}){
final _that = this;
switch (_that) {
case ReplayStarted():
return started(_that);case ReplaySeekRequested():
return seekRequested(_that);case ReplayRequested():
return replayRequested(_that);case ReplayCompleted():
return completed(_that);case ReplayReset():
return reset(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ReplayStarted value)?  started,TResult? Function( ReplaySeekRequested value)?  seekRequested,TResult? Function( ReplayRequested value)?  replayRequested,TResult? Function( ReplayCompleted value)?  completed,TResult? Function( ReplayReset value)?  reset,}){
final _that = this;
switch (_that) {
case ReplayStarted() when started != null:
return started(_that);case ReplaySeekRequested() when seekRequested != null:
return seekRequested(_that);case ReplayRequested() when replayRequested != null:
return replayRequested(_that);case ReplayCompleted() when completed != null:
return completed(_that);case ReplayReset() when reset != null:
return reset(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String movieSlug,  String episodeSlug,  String serverName)?  started,TResult Function( Duration position)?  seekRequested,TResult Function()?  replayRequested,TResult Function()?  completed,TResult Function()?  reset,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ReplayStarted() when started != null:
return started(_that.movieSlug,_that.episodeSlug,_that.serverName);case ReplaySeekRequested() when seekRequested != null:
return seekRequested(_that.position);case ReplayRequested() when replayRequested != null:
return replayRequested();case ReplayCompleted() when completed != null:
return completed();case ReplayReset() when reset != null:
return reset();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String movieSlug,  String episodeSlug,  String serverName)  started,required TResult Function( Duration position)  seekRequested,required TResult Function()  replayRequested,required TResult Function()  completed,required TResult Function()  reset,}) {final _that = this;
switch (_that) {
case ReplayStarted():
return started(_that.movieSlug,_that.episodeSlug,_that.serverName);case ReplaySeekRequested():
return seekRequested(_that.position);case ReplayRequested():
return replayRequested();case ReplayCompleted():
return completed();case ReplayReset():
return reset();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String movieSlug,  String episodeSlug,  String serverName)?  started,TResult? Function( Duration position)?  seekRequested,TResult? Function()?  replayRequested,TResult? Function()?  completed,TResult? Function()?  reset,}) {final _that = this;
switch (_that) {
case ReplayStarted() when started != null:
return started(_that.movieSlug,_that.episodeSlug,_that.serverName);case ReplaySeekRequested() when seekRequested != null:
return seekRequested(_that.position);case ReplayRequested() when replayRequested != null:
return replayRequested();case ReplayCompleted() when completed != null:
return completed();case ReplayReset() when reset != null:
return reset();case _:
  return null;

}
}

}

/// @nodoc


class ReplayStarted implements ReplayEvent {
  const ReplayStarted({required this.movieSlug, required this.episodeSlug, required this.serverName});
  

 final  String movieSlug;
 final  String episodeSlug;
 final  String serverName;

/// Create a copy of ReplayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplayStartedCopyWith<ReplayStarted> get copyWith => _$ReplayStartedCopyWithImpl<ReplayStarted>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplayStarted&&(identical(other.movieSlug, movieSlug) || other.movieSlug == movieSlug)&&(identical(other.episodeSlug, episodeSlug) || other.episodeSlug == episodeSlug)&&(identical(other.serverName, serverName) || other.serverName == serverName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,movieSlug,episodeSlug,serverName);
}

@override
String toString() {
    return 'ReplayEvent.started(movieSlug: $movieSlug, episodeSlug: $episodeSlug, serverName: $serverName)';
}


}

/// @nodoc
abstract mixin class $ReplayStartedCopyWith<$Res> implements $ReplayEventCopyWith<$Res> {
  factory $ReplayStartedCopyWith(ReplayStarted value, $Res Function(ReplayStarted) _then) = _$ReplayStartedCopyWithImpl;
@useResult
$Res call({
 String movieSlug, String episodeSlug, String serverName
});




}
/// @nodoc
class _$ReplayStartedCopyWithImpl<$Res>
    implements $ReplayStartedCopyWith<$Res> {
  _$ReplayStartedCopyWithImpl(this._self, this._then);

  final ReplayStarted _self;
  final $Res Function(ReplayStarted) _then;

/// Create a copy of ReplayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? movieSlug = null,Object? episodeSlug = null,Object? serverName = null,}) {
  return _then(ReplayStarted(
movieSlug: null == movieSlug ? _self.movieSlug : movieSlug // ignore: cast_nullable_to_non_nullable
as String,episodeSlug: null == episodeSlug ? _self.episodeSlug : episodeSlug // ignore: cast_nullable_to_non_nullable
as String,serverName: null == serverName ? _self.serverName : serverName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ReplaySeekRequested implements ReplayEvent {
  const ReplaySeekRequested({required this.position});
  

 final  Duration position;

/// Create a copy of ReplayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplaySeekRequestedCopyWith<ReplaySeekRequested> get copyWith => _$ReplaySeekRequestedCopyWithImpl<ReplaySeekRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplaySeekRequested&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode {
    return Object.hash(runtimeType,position);
}

@override
String toString() {
    return 'ReplayEvent.seekRequested(position: $position)';
}


}

/// @nodoc
abstract mixin class $ReplaySeekRequestedCopyWith<$Res> implements $ReplayEventCopyWith<$Res> {
  factory $ReplaySeekRequestedCopyWith(ReplaySeekRequested value, $Res Function(ReplaySeekRequested) _then) = _$ReplaySeekRequestedCopyWithImpl;
@useResult
$Res call({
 Duration position
});




}
/// @nodoc
class _$ReplaySeekRequestedCopyWithImpl<$Res>
    implements $ReplaySeekRequestedCopyWith<$Res> {
  _$ReplaySeekRequestedCopyWithImpl(this._self, this._then);

  final ReplaySeekRequested _self;
  final $Res Function(ReplaySeekRequested) _then;

/// Create a copy of ReplayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? position = null,}) {
  return _then(ReplaySeekRequested(
position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc


class ReplayRequested implements ReplayEvent {
  const ReplayRequested();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplayRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ReplayEvent.replayRequested()';
}


}




/// @nodoc


class ReplayCompleted implements ReplayEvent {
  const ReplayCompleted();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplayCompleted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ReplayEvent.completed()';
}


}




/// @nodoc


class ReplayReset implements ReplayEvent {
  const ReplayReset();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplayReset);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ReplayEvent.reset()';
}


}




// dart format on
