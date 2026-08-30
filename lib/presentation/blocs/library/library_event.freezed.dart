// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LibraryEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LibraryEvent()';
}


}

/// @nodoc
class $LibraryEventCopyWith<$Res>  {
$LibraryEventCopyWith(LibraryEvent _, $Res Function(LibraryEvent) __);
}


/// Adds pattern-matching-related methods to [LibraryEvent].
extension LibraryEventPatterns on LibraryEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LibraryStarted value)?  started,TResult Function( LibraryTabChanged value)?  tabChanged,TResult Function( LibraryHistoryUpdated value)?  historyUpdated,TResult Function( LibraryBookmarksUpdated value)?  bookmarksUpdated,TResult Function( LibraryDownloadsUpdated value)?  downloadsUpdated,TResult Function( LibraryDeleteHistory value)?  deleteHistory,TResult Function( LibraryDeleteBookmark value)?  deleteBookmark,TResult Function( LibraryDeleteDownload value)?  deleteDownload,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LibraryStarted() when started != null:
return started(_that);case LibraryTabChanged() when tabChanged != null:
return tabChanged(_that);case LibraryHistoryUpdated() when historyUpdated != null:
return historyUpdated(_that);case LibraryBookmarksUpdated() when bookmarksUpdated != null:
return bookmarksUpdated(_that);case LibraryDownloadsUpdated() when downloadsUpdated != null:
return downloadsUpdated(_that);case LibraryDeleteHistory() when deleteHistory != null:
return deleteHistory(_that);case LibraryDeleteBookmark() when deleteBookmark != null:
return deleteBookmark(_that);case LibraryDeleteDownload() when deleteDownload != null:
return deleteDownload(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LibraryStarted value)  started,required TResult Function( LibraryTabChanged value)  tabChanged,required TResult Function( LibraryHistoryUpdated value)  historyUpdated,required TResult Function( LibraryBookmarksUpdated value)  bookmarksUpdated,required TResult Function( LibraryDownloadsUpdated value)  downloadsUpdated,required TResult Function( LibraryDeleteHistory value)  deleteHistory,required TResult Function( LibraryDeleteBookmark value)  deleteBookmark,required TResult Function( LibraryDeleteDownload value)  deleteDownload,}){
final _that = this;
switch (_that) {
case LibraryStarted():
return started(_that);case LibraryTabChanged():
return tabChanged(_that);case LibraryHistoryUpdated():
return historyUpdated(_that);case LibraryBookmarksUpdated():
return bookmarksUpdated(_that);case LibraryDownloadsUpdated():
return downloadsUpdated(_that);case LibraryDeleteHistory():
return deleteHistory(_that);case LibraryDeleteBookmark():
return deleteBookmark(_that);case LibraryDeleteDownload():
return deleteDownload(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LibraryStarted value)?  started,TResult? Function( LibraryTabChanged value)?  tabChanged,TResult? Function( LibraryHistoryUpdated value)?  historyUpdated,TResult? Function( LibraryBookmarksUpdated value)?  bookmarksUpdated,TResult? Function( LibraryDownloadsUpdated value)?  downloadsUpdated,TResult? Function( LibraryDeleteHistory value)?  deleteHistory,TResult? Function( LibraryDeleteBookmark value)?  deleteBookmark,TResult? Function( LibraryDeleteDownload value)?  deleteDownload,}){
final _that = this;
switch (_that) {
case LibraryStarted() when started != null:
return started(_that);case LibraryTabChanged() when tabChanged != null:
return tabChanged(_that);case LibraryHistoryUpdated() when historyUpdated != null:
return historyUpdated(_that);case LibraryBookmarksUpdated() when bookmarksUpdated != null:
return bookmarksUpdated(_that);case LibraryDownloadsUpdated() when downloadsUpdated != null:
return downloadsUpdated(_that);case LibraryDeleteHistory() when deleteHistory != null:
return deleteHistory(_that);case LibraryDeleteBookmark() when deleteBookmark != null:
return deleteBookmark(_that);case LibraryDeleteDownload() when deleteDownload != null:
return deleteDownload(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( int index)?  tabChanged,TResult Function( List<WatchHistoryData> items)?  historyUpdated,TResult Function( List<Bookmark> items)?  bookmarksUpdated,TResult Function( List<Download> items)?  downloadsUpdated,TResult Function( String movieSlug,  String episodeSlug,  String serverName)?  deleteHistory,TResult Function( String movieSlug)?  deleteBookmark,TResult Function( Download download)?  deleteDownload,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LibraryStarted() when started != null:
return started();case LibraryTabChanged() when tabChanged != null:
return tabChanged(_that.index);case LibraryHistoryUpdated() when historyUpdated != null:
return historyUpdated(_that.items);case LibraryBookmarksUpdated() when bookmarksUpdated != null:
return bookmarksUpdated(_that.items);case LibraryDownloadsUpdated() when downloadsUpdated != null:
return downloadsUpdated(_that.items);case LibraryDeleteHistory() when deleteHistory != null:
return deleteHistory(_that.movieSlug,_that.episodeSlug,_that.serverName);case LibraryDeleteBookmark() when deleteBookmark != null:
return deleteBookmark(_that.movieSlug);case LibraryDeleteDownload() when deleteDownload != null:
return deleteDownload(_that.download);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( int index)  tabChanged,required TResult Function( List<WatchHistoryData> items)  historyUpdated,required TResult Function( List<Bookmark> items)  bookmarksUpdated,required TResult Function( List<Download> items)  downloadsUpdated,required TResult Function( String movieSlug,  String episodeSlug,  String serverName)  deleteHistory,required TResult Function( String movieSlug)  deleteBookmark,required TResult Function( Download download)  deleteDownload,}) {final _that = this;
switch (_that) {
case LibraryStarted():
return started();case LibraryTabChanged():
return tabChanged(_that.index);case LibraryHistoryUpdated():
return historyUpdated(_that.items);case LibraryBookmarksUpdated():
return bookmarksUpdated(_that.items);case LibraryDownloadsUpdated():
return downloadsUpdated(_that.items);case LibraryDeleteHistory():
return deleteHistory(_that.movieSlug,_that.episodeSlug,_that.serverName);case LibraryDeleteBookmark():
return deleteBookmark(_that.movieSlug);case LibraryDeleteDownload():
return deleteDownload(_that.download);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( int index)?  tabChanged,TResult? Function( List<WatchHistoryData> items)?  historyUpdated,TResult? Function( List<Bookmark> items)?  bookmarksUpdated,TResult? Function( List<Download> items)?  downloadsUpdated,TResult? Function( String movieSlug,  String episodeSlug,  String serverName)?  deleteHistory,TResult? Function( String movieSlug)?  deleteBookmark,TResult? Function( Download download)?  deleteDownload,}) {final _that = this;
switch (_that) {
case LibraryStarted() when started != null:
return started();case LibraryTabChanged() when tabChanged != null:
return tabChanged(_that.index);case LibraryHistoryUpdated() when historyUpdated != null:
return historyUpdated(_that.items);case LibraryBookmarksUpdated() when bookmarksUpdated != null:
return bookmarksUpdated(_that.items);case LibraryDownloadsUpdated() when downloadsUpdated != null:
return downloadsUpdated(_that.items);case LibraryDeleteHistory() when deleteHistory != null:
return deleteHistory(_that.movieSlug,_that.episodeSlug,_that.serverName);case LibraryDeleteBookmark() when deleteBookmark != null:
return deleteBookmark(_that.movieSlug);case LibraryDeleteDownload() when deleteDownload != null:
return deleteDownload(_that.download);case _:
  return null;

}
}

}

/// @nodoc


class LibraryStarted extends LibraryEvent {
  const LibraryStarted(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryStarted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LibraryEvent.started()';
}


}




/// @nodoc


class LibraryTabChanged extends LibraryEvent {
  const LibraryTabChanged(this.index): super._();
  

 final  int index;

/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryTabChangedCopyWith<LibraryTabChanged> get copyWith => _$LibraryTabChangedCopyWithImpl<LibraryTabChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryTabChanged&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode {
    return Object.hash(runtimeType,index);
}

@override
String toString() {
    return 'LibraryEvent.tabChanged(index: $index)';
}


}

/// @nodoc
abstract mixin class $LibraryTabChangedCopyWith<$Res> implements $LibraryEventCopyWith<$Res> {
  factory $LibraryTabChangedCopyWith(LibraryTabChanged value, $Res Function(LibraryTabChanged) _then) = _$LibraryTabChangedCopyWithImpl;
@useResult
$Res call({
 int index
});




}
/// @nodoc
class _$LibraryTabChangedCopyWithImpl<$Res>
    implements $LibraryTabChangedCopyWith<$Res> {
  _$LibraryTabChangedCopyWithImpl(this._self, this._then);

  final LibraryTabChanged _self;
  final $Res Function(LibraryTabChanged) _then;

/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,}) {
  return _then(LibraryTabChanged(
null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class LibraryHistoryUpdated extends LibraryEvent {
  const LibraryHistoryUpdated( List<WatchHistoryData> items): _items = items,super._();
  

 final  List<WatchHistoryData> _items;
 List<WatchHistoryData> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryHistoryUpdatedCopyWith<LibraryHistoryUpdated> get copyWith => _$LibraryHistoryUpdatedCopyWithImpl<LibraryHistoryUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryHistoryUpdated&&const DeepCollectionEquality().equals(other.items, _items));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'LibraryEvent.historyUpdated(items: $items)';
}


}

/// @nodoc
abstract mixin class $LibraryHistoryUpdatedCopyWith<$Res> implements $LibraryEventCopyWith<$Res> {
  factory $LibraryHistoryUpdatedCopyWith(LibraryHistoryUpdated value, $Res Function(LibraryHistoryUpdated) _then) = _$LibraryHistoryUpdatedCopyWithImpl;
@useResult
$Res call({
 List<WatchHistoryData> items
});




}
/// @nodoc
class _$LibraryHistoryUpdatedCopyWithImpl<$Res>
    implements $LibraryHistoryUpdatedCopyWith<$Res> {
  _$LibraryHistoryUpdatedCopyWithImpl(this._self, this._then);

  final LibraryHistoryUpdated _self;
  final $Res Function(LibraryHistoryUpdated) _then;

/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(LibraryHistoryUpdated(
null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<WatchHistoryData>,
  ));
}


}

/// @nodoc


class LibraryBookmarksUpdated extends LibraryEvent {
  const LibraryBookmarksUpdated( List<Bookmark> items): _items = items,super._();
  

 final  List<Bookmark> _items;
 List<Bookmark> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryBookmarksUpdatedCopyWith<LibraryBookmarksUpdated> get copyWith => _$LibraryBookmarksUpdatedCopyWithImpl<LibraryBookmarksUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryBookmarksUpdated&&const DeepCollectionEquality().equals(other.items, _items));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'LibraryEvent.bookmarksUpdated(items: $items)';
}


}

/// @nodoc
abstract mixin class $LibraryBookmarksUpdatedCopyWith<$Res> implements $LibraryEventCopyWith<$Res> {
  factory $LibraryBookmarksUpdatedCopyWith(LibraryBookmarksUpdated value, $Res Function(LibraryBookmarksUpdated) _then) = _$LibraryBookmarksUpdatedCopyWithImpl;
@useResult
$Res call({
 List<Bookmark> items
});




}
/// @nodoc
class _$LibraryBookmarksUpdatedCopyWithImpl<$Res>
    implements $LibraryBookmarksUpdatedCopyWith<$Res> {
  _$LibraryBookmarksUpdatedCopyWithImpl(this._self, this._then);

  final LibraryBookmarksUpdated _self;
  final $Res Function(LibraryBookmarksUpdated) _then;

/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(LibraryBookmarksUpdated(
null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Bookmark>,
  ));
}


}

/// @nodoc


class LibraryDownloadsUpdated extends LibraryEvent {
  const LibraryDownloadsUpdated( List<Download> items): _items = items,super._();
  

 final  List<Download> _items;
 List<Download> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryDownloadsUpdatedCopyWith<LibraryDownloadsUpdated> get copyWith => _$LibraryDownloadsUpdatedCopyWithImpl<LibraryDownloadsUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryDownloadsUpdated&&const DeepCollectionEquality().equals(other.items, _items));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'LibraryEvent.downloadsUpdated(items: $items)';
}


}

/// @nodoc
abstract mixin class $LibraryDownloadsUpdatedCopyWith<$Res> implements $LibraryEventCopyWith<$Res> {
  factory $LibraryDownloadsUpdatedCopyWith(LibraryDownloadsUpdated value, $Res Function(LibraryDownloadsUpdated) _then) = _$LibraryDownloadsUpdatedCopyWithImpl;
@useResult
$Res call({
 List<Download> items
});




}
/// @nodoc
class _$LibraryDownloadsUpdatedCopyWithImpl<$Res>
    implements $LibraryDownloadsUpdatedCopyWith<$Res> {
  _$LibraryDownloadsUpdatedCopyWithImpl(this._self, this._then);

  final LibraryDownloadsUpdated _self;
  final $Res Function(LibraryDownloadsUpdated) _then;

/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(LibraryDownloadsUpdated(
null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Download>,
  ));
}


}

/// @nodoc


class LibraryDeleteHistory extends LibraryEvent {
  const LibraryDeleteHistory(this.movieSlug, this.episodeSlug, this.serverName): super._();
  

 final  String movieSlug;
 final  String episodeSlug;
 final  String serverName;

/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryDeleteHistoryCopyWith<LibraryDeleteHistory> get copyWith => _$LibraryDeleteHistoryCopyWithImpl<LibraryDeleteHistory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryDeleteHistory&&(identical(other.movieSlug, movieSlug) || other.movieSlug == movieSlug)&&(identical(other.episodeSlug, episodeSlug) || other.episodeSlug == episodeSlug)&&(identical(other.serverName, serverName) || other.serverName == serverName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,movieSlug,episodeSlug,serverName);
}

@override
String toString() {
    return 'LibraryEvent.deleteHistory(movieSlug: $movieSlug, episodeSlug: $episodeSlug, serverName: $serverName)';
}


}

/// @nodoc
abstract mixin class $LibraryDeleteHistoryCopyWith<$Res> implements $LibraryEventCopyWith<$Res> {
  factory $LibraryDeleteHistoryCopyWith(LibraryDeleteHistory value, $Res Function(LibraryDeleteHistory) _then) = _$LibraryDeleteHistoryCopyWithImpl;
@useResult
$Res call({
 String movieSlug, String episodeSlug, String serverName
});




}
/// @nodoc
class _$LibraryDeleteHistoryCopyWithImpl<$Res>
    implements $LibraryDeleteHistoryCopyWith<$Res> {
  _$LibraryDeleteHistoryCopyWithImpl(this._self, this._then);

  final LibraryDeleteHistory _self;
  final $Res Function(LibraryDeleteHistory) _then;

/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? movieSlug = null,Object? episodeSlug = null,Object? serverName = null,}) {
  return _then(LibraryDeleteHistory(
null == movieSlug ? _self.movieSlug : movieSlug // ignore: cast_nullable_to_non_nullable
as String,null == episodeSlug ? _self.episodeSlug : episodeSlug // ignore: cast_nullable_to_non_nullable
as String,null == serverName ? _self.serverName : serverName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LibraryDeleteBookmark extends LibraryEvent {
  const LibraryDeleteBookmark(this.movieSlug): super._();
  

 final  String movieSlug;

/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryDeleteBookmarkCopyWith<LibraryDeleteBookmark> get copyWith => _$LibraryDeleteBookmarkCopyWithImpl<LibraryDeleteBookmark>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryDeleteBookmark&&(identical(other.movieSlug, movieSlug) || other.movieSlug == movieSlug));
}


@override
int get hashCode {
    return Object.hash(runtimeType,movieSlug);
}

@override
String toString() {
    return 'LibraryEvent.deleteBookmark(movieSlug: $movieSlug)';
}


}

/// @nodoc
abstract mixin class $LibraryDeleteBookmarkCopyWith<$Res> implements $LibraryEventCopyWith<$Res> {
  factory $LibraryDeleteBookmarkCopyWith(LibraryDeleteBookmark value, $Res Function(LibraryDeleteBookmark) _then) = _$LibraryDeleteBookmarkCopyWithImpl;
@useResult
$Res call({
 String movieSlug
});




}
/// @nodoc
class _$LibraryDeleteBookmarkCopyWithImpl<$Res>
    implements $LibraryDeleteBookmarkCopyWith<$Res> {
  _$LibraryDeleteBookmarkCopyWithImpl(this._self, this._then);

  final LibraryDeleteBookmark _self;
  final $Res Function(LibraryDeleteBookmark) _then;

/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? movieSlug = null,}) {
  return _then(LibraryDeleteBookmark(
null == movieSlug ? _self.movieSlug : movieSlug // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LibraryDeleteDownload extends LibraryEvent {
  const LibraryDeleteDownload(this.download): super._();
  

 final  Download download;

/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryDeleteDownloadCopyWith<LibraryDeleteDownload> get copyWith => _$LibraryDeleteDownloadCopyWithImpl<LibraryDeleteDownload>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryDeleteDownload&&const DeepCollectionEquality().equals(other.download, download));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(download));
}

@override
String toString() {
    return 'LibraryEvent.deleteDownload(download: $download)';
}


}

/// @nodoc
abstract mixin class $LibraryDeleteDownloadCopyWith<$Res> implements $LibraryEventCopyWith<$Res> {
  factory $LibraryDeleteDownloadCopyWith(LibraryDeleteDownload value, $Res Function(LibraryDeleteDownload) _then) = _$LibraryDeleteDownloadCopyWithImpl;
@useResult
$Res call({
 Download download
});




}
/// @nodoc
class _$LibraryDeleteDownloadCopyWithImpl<$Res>
    implements $LibraryDeleteDownloadCopyWith<$Res> {
  _$LibraryDeleteDownloadCopyWithImpl(this._self, this._then);

  final LibraryDeleteDownload _self;
  final $Res Function(LibraryDeleteDownload) _then;

/// Create a copy of LibraryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? download = freezed,}) {
  return _then(LibraryDeleteDownload(
freezed == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as Download,
  ));
}


}

// dart format on
