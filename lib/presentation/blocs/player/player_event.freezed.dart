// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PlayerEvent()';
}


}

/// @nodoc
class $PlayerEventCopyWith<$Res>  {
$PlayerEventCopyWith(PlayerEvent _, $Res Function(PlayerEvent) __);
}


/// Adds pattern-matching-related methods to [PlayerEvent].
extension PlayerEventPatterns on PlayerEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PlayerStarted value)?  started,TResult Function( PlayerPositionChanged value)?  positionChanged,TResult Function( PlayerSaveProgress value)?  saveProgress,TResult Function( PlayerDownloadRequested value)?  downloadRequested,TResult Function( PlayerPlayNext value)?  playNext,TResult Function( PlayerSeek value)?  seek,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PlayerStarted() when started != null:
return started(_that);case PlayerPositionChanged() when positionChanged != null:
return positionChanged(_that);case PlayerSaveProgress() when saveProgress != null:
return saveProgress(_that);case PlayerDownloadRequested() when downloadRequested != null:
return downloadRequested(_that);case PlayerPlayNext() when playNext != null:
return playNext(_that);case PlayerSeek() when seek != null:
return seek(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PlayerStarted value)  started,required TResult Function( PlayerPositionChanged value)  positionChanged,required TResult Function( PlayerSaveProgress value)  saveProgress,required TResult Function( PlayerDownloadRequested value)  downloadRequested,required TResult Function( PlayerPlayNext value)  playNext,required TResult Function( PlayerSeek value)  seek,}){
final _that = this;
switch (_that) {
case PlayerStarted():
return started(_that);case PlayerPositionChanged():
return positionChanged(_that);case PlayerSaveProgress():
return saveProgress(_that);case PlayerDownloadRequested():
return downloadRequested(_that);case PlayerPlayNext():
return playNext(_that);case PlayerSeek():
return seek(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PlayerStarted value)?  started,TResult? Function( PlayerPositionChanged value)?  positionChanged,TResult? Function( PlayerSaveProgress value)?  saveProgress,TResult? Function( PlayerDownloadRequested value)?  downloadRequested,TResult? Function( PlayerPlayNext value)?  playNext,TResult? Function( PlayerSeek value)?  seek,}){
final _that = this;
switch (_that) {
case PlayerStarted() when started != null:
return started(_that);case PlayerPositionChanged() when positionChanged != null:
return positionChanged(_that);case PlayerSaveProgress() when saveProgress != null:
return saveProgress(_that);case PlayerDownloadRequested() when downloadRequested != null:
return downloadRequested(_that);case PlayerPlayNext() when playNext != null:
return playNext(_that);case PlayerSeek() when seek != null:
return seek(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String movieSlug,  String movieName,  String? posterUrl,  String episodeSlug,  String episodeName,  String serverName,  String linkM3u8)?  started,TResult Function( Duration position,  Duration duration)?  positionChanged,TResult Function()?  saveProgress,TResult Function()?  downloadRequested,TResult Function()?  playNext,TResult Function( Duration position)?  seek,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PlayerStarted() when started != null:
return started(_that.movieSlug,_that.movieName,_that.posterUrl,_that.episodeSlug,_that.episodeName,_that.serverName,_that.linkM3u8);case PlayerPositionChanged() when positionChanged != null:
return positionChanged(_that.position,_that.duration);case PlayerSaveProgress() when saveProgress != null:
return saveProgress();case PlayerDownloadRequested() when downloadRequested != null:
return downloadRequested();case PlayerPlayNext() when playNext != null:
return playNext();case PlayerSeek() when seek != null:
return seek(_that.position);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String movieSlug,  String movieName,  String? posterUrl,  String episodeSlug,  String episodeName,  String serverName,  String linkM3u8)  started,required TResult Function( Duration position,  Duration duration)  positionChanged,required TResult Function()  saveProgress,required TResult Function()  downloadRequested,required TResult Function()  playNext,required TResult Function( Duration position)  seek,}) {final _that = this;
switch (_that) {
case PlayerStarted():
return started(_that.movieSlug,_that.movieName,_that.posterUrl,_that.episodeSlug,_that.episodeName,_that.serverName,_that.linkM3u8);case PlayerPositionChanged():
return positionChanged(_that.position,_that.duration);case PlayerSaveProgress():
return saveProgress();case PlayerDownloadRequested():
return downloadRequested();case PlayerPlayNext():
return playNext();case PlayerSeek():
return seek(_that.position);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String movieSlug,  String movieName,  String? posterUrl,  String episodeSlug,  String episodeName,  String serverName,  String linkM3u8)?  started,TResult? Function( Duration position,  Duration duration)?  positionChanged,TResult? Function()?  saveProgress,TResult? Function()?  downloadRequested,TResult? Function()?  playNext,TResult? Function( Duration position)?  seek,}) {final _that = this;
switch (_that) {
case PlayerStarted() when started != null:
return started(_that.movieSlug,_that.movieName,_that.posterUrl,_that.episodeSlug,_that.episodeName,_that.serverName,_that.linkM3u8);case PlayerPositionChanged() when positionChanged != null:
return positionChanged(_that.position,_that.duration);case PlayerSaveProgress() when saveProgress != null:
return saveProgress();case PlayerDownloadRequested() when downloadRequested != null:
return downloadRequested();case PlayerPlayNext() when playNext != null:
return playNext();case PlayerSeek() when seek != null:
return seek(_that.position);case _:
  return null;

}
}

}

/// @nodoc


class PlayerStarted extends PlayerEvent {
  const PlayerStarted({required this.movieSlug, required this.movieName, this.posterUrl, required this.episodeSlug, required this.episodeName, required this.serverName, required this.linkM3u8}): super._();
  

 final  String movieSlug;
 final  String movieName;
 final  String? posterUrl;
 final  String episodeSlug;
 final  String episodeName;
 final  String serverName;
 final  String linkM3u8;

/// Create a copy of PlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerStartedCopyWith<PlayerStarted> get copyWith => _$PlayerStartedCopyWithImpl<PlayerStarted>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerStarted&&(identical(other.movieSlug, movieSlug) || other.movieSlug == movieSlug)&&(identical(other.movieName, movieName) || other.movieName == movieName)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.episodeSlug, episodeSlug) || other.episodeSlug == episodeSlug)&&(identical(other.episodeName, episodeName) || other.episodeName == episodeName)&&(identical(other.serverName, serverName) || other.serverName == serverName)&&(identical(other.linkM3u8, linkM3u8) || other.linkM3u8 == linkM3u8));
}


@override
int get hashCode {
    return Object.hash(runtimeType,movieSlug,movieName,posterUrl,episodeSlug,episodeName,serverName,linkM3u8);
}

@override
String toString() {
    return 'PlayerEvent.started(movieSlug: $movieSlug, movieName: $movieName, posterUrl: $posterUrl, episodeSlug: $episodeSlug, episodeName: $episodeName, serverName: $serverName, linkM3u8: $linkM3u8)';
}


}

/// @nodoc
abstract mixin class $PlayerStartedCopyWith<$Res> implements $PlayerEventCopyWith<$Res> {
  factory $PlayerStartedCopyWith(PlayerStarted value, $Res Function(PlayerStarted) _then) = _$PlayerStartedCopyWithImpl;
@useResult
$Res call({
 String movieSlug, String movieName, String? posterUrl, String episodeSlug, String episodeName, String serverName, String linkM3u8
});




}
/// @nodoc
class _$PlayerStartedCopyWithImpl<$Res>
    implements $PlayerStartedCopyWith<$Res> {
  _$PlayerStartedCopyWithImpl(this._self, this._then);

  final PlayerStarted _self;
  final $Res Function(PlayerStarted) _then;

/// Create a copy of PlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? movieSlug = null,Object? movieName = null,Object? posterUrl = freezed,Object? episodeSlug = null,Object? episodeName = null,Object? serverName = null,Object? linkM3u8 = null,}) {
  return _then(PlayerStarted(
movieSlug: null == movieSlug ? _self.movieSlug : movieSlug // ignore: cast_nullable_to_non_nullable
as String,movieName: null == movieName ? _self.movieName : movieName // ignore: cast_nullable_to_non_nullable
as String,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,episodeSlug: null == episodeSlug ? _self.episodeSlug : episodeSlug // ignore: cast_nullable_to_non_nullable
as String,episodeName: null == episodeName ? _self.episodeName : episodeName // ignore: cast_nullable_to_non_nullable
as String,serverName: null == serverName ? _self.serverName : serverName // ignore: cast_nullable_to_non_nullable
as String,linkM3u8: null == linkM3u8 ? _self.linkM3u8 : linkM3u8 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PlayerPositionChanged extends PlayerEvent {
  const PlayerPositionChanged(this.position, this.duration): super._();
  

 final  Duration position;
 final  Duration duration;

/// Create a copy of PlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerPositionChangedCopyWith<PlayerPositionChanged> get copyWith => _$PlayerPositionChangedCopyWithImpl<PlayerPositionChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerPositionChanged&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration));
}


@override
int get hashCode {
    return Object.hash(runtimeType,position,duration);
}

@override
String toString() {
    return 'PlayerEvent.positionChanged(position: $position, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $PlayerPositionChangedCopyWith<$Res> implements $PlayerEventCopyWith<$Res> {
  factory $PlayerPositionChangedCopyWith(PlayerPositionChanged value, $Res Function(PlayerPositionChanged) _then) = _$PlayerPositionChangedCopyWithImpl;
@useResult
$Res call({
 Duration position, Duration duration
});




}
/// @nodoc
class _$PlayerPositionChangedCopyWithImpl<$Res>
    implements $PlayerPositionChangedCopyWith<$Res> {
  _$PlayerPositionChangedCopyWithImpl(this._self, this._then);

  final PlayerPositionChanged _self;
  final $Res Function(PlayerPositionChanged) _then;

/// Create a copy of PlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? position = null,Object? duration = null,}) {
  return _then(PlayerPositionChanged(
null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc


class PlayerSaveProgress extends PlayerEvent {
  const PlayerSaveProgress(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerSaveProgress);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PlayerEvent.saveProgress()';
}


}




/// @nodoc


class PlayerDownloadRequested extends PlayerEvent {
  const PlayerDownloadRequested(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerDownloadRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PlayerEvent.downloadRequested()';
}


}




/// @nodoc


class PlayerPlayNext extends PlayerEvent {
  const PlayerPlayNext(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerPlayNext);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PlayerEvent.playNext()';
}


}




/// @nodoc


class PlayerSeek extends PlayerEvent {
  const PlayerSeek(this.position): super._();
  

 final  Duration position;

/// Create a copy of PlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerSeekCopyWith<PlayerSeek> get copyWith => _$PlayerSeekCopyWithImpl<PlayerSeek>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerSeek&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode {
    return Object.hash(runtimeType,position);
}

@override
String toString() {
    return 'PlayerEvent.seek(position: $position)';
}


}

/// @nodoc
abstract mixin class $PlayerSeekCopyWith<$Res> implements $PlayerEventCopyWith<$Res> {
  factory $PlayerSeekCopyWith(PlayerSeek value, $Res Function(PlayerSeek) _then) = _$PlayerSeekCopyWithImpl;
@useResult
$Res call({
 Duration position
});




}
/// @nodoc
class _$PlayerSeekCopyWithImpl<$Res>
    implements $PlayerSeekCopyWith<$Res> {
  _$PlayerSeekCopyWithImpl(this._self, this._then);

  final PlayerSeek _self;
  final $Res Function(PlayerSeek) _then;

/// Create a copy of PlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? position = null,}) {
  return _then(PlayerSeek(
null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on
