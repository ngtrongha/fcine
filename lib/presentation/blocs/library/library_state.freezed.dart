// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LibraryState {

 int get selectedTab;@JsonKey(includeFromJson: false, includeToJson: false) List<WatchHistoryData> get history;@JsonKey(includeFromJson: false, includeToJson: false) List<Bookmark> get bookmarks;@JsonKey(includeFromJson: false, includeToJson: false) List<Download> get downloads; bool get isLoading; String? get errorMessage;
/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryStateCopyWith<LibraryState> get copyWith => _$LibraryStateCopyWithImpl<LibraryState>(this as LibraryState, _$identity);

  /// Serializes this LibraryState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LibraryState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryState&&(identical(other.selectedTab, _this.selectedTab) || other.selectedTab == _this.selectedTab)&&const DeepCollectionEquality().equals(other.history, _this.history)&&const DeepCollectionEquality().equals(other.bookmarks, _this.bookmarks)&&const DeepCollectionEquality().equals(other.downloads, _this.downloads)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LibraryState;
  return Object.hash(runtimeType,_this.selectedTab,const DeepCollectionEquality().hash(_this.history),const DeepCollectionEquality().hash(_this.bookmarks),const DeepCollectionEquality().hash(_this.downloads),_this.isLoading,_this.errorMessage);
}

@override
String toString() {
  final _this = this as LibraryState;
  return 'LibraryState(selectedTab: ${_this.selectedTab}, history: ${_this.history}, bookmarks: ${_this.bookmarks}, downloads: ${_this.downloads}, isLoading: ${_this.isLoading}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $LibraryStateCopyWith<$Res>  {
  factory $LibraryStateCopyWith(LibraryState value, $Res Function(LibraryState) _then) = _$LibraryStateCopyWithImpl;
@useResult
$Res call({
 int selectedTab,@JsonKey(includeFromJson: false, includeToJson: false) List<WatchHistoryData> history,@JsonKey(includeFromJson: false, includeToJson: false) List<Bookmark> bookmarks,@JsonKey(includeFromJson: false, includeToJson: false) List<Download> downloads, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$LibraryStateCopyWithImpl<$Res>
    implements $LibraryStateCopyWith<$Res> {
  _$LibraryStateCopyWithImpl(this._self, this._then);

  final LibraryState _self;
  final $Res Function(LibraryState) _then;

/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedTab = null,Object? history = null,Object? bookmarks = null,Object? downloads = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(LibraryState(
selectedTab: null == selectedTab ? _self.selectedTab : selectedTab // ignore: cast_nullable_to_non_nullable
as int,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<WatchHistoryData>,bookmarks: null == bookmarks ? _self.bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as List<Bookmark>,downloads: null == downloads ? _self.downloads : downloads // ignore: cast_nullable_to_non_nullable
as List<Download>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LibraryState].
extension LibraryStatePatterns on LibraryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LibraryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LibraryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LibraryState value)  $default,){
final _that = this;
switch (_that) {
case _LibraryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LibraryState value)?  $default,){
final _that = this;
switch (_that) {
case _LibraryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int selectedTab, @JsonKey(includeFromJson: false, includeToJson: false)  List<WatchHistoryData> history, @JsonKey(includeFromJson: false, includeToJson: false)  List<Bookmark> bookmarks, @JsonKey(includeFromJson: false, includeToJson: false)  List<Download> downloads,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LibraryState() when $default != null:
return $default(_that.selectedTab,_that.history,_that.bookmarks,_that.downloads,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int selectedTab, @JsonKey(includeFromJson: false, includeToJson: false)  List<WatchHistoryData> history, @JsonKey(includeFromJson: false, includeToJson: false)  List<Bookmark> bookmarks, @JsonKey(includeFromJson: false, includeToJson: false)  List<Download> downloads,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _LibraryState():
return $default(_that.selectedTab,_that.history,_that.bookmarks,_that.downloads,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int selectedTab, @JsonKey(includeFromJson: false, includeToJson: false)  List<WatchHistoryData> history, @JsonKey(includeFromJson: false, includeToJson: false)  List<Bookmark> bookmarks, @JsonKey(includeFromJson: false, includeToJson: false)  List<Download> downloads,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _LibraryState() when $default != null:
return $default(_that.selectedTab,_that.history,_that.bookmarks,_that.downloads,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LibraryState implements LibraryState {
  const _LibraryState({this.selectedTab = 0, @JsonKey(includeFromJson: false, includeToJson: false)  List<WatchHistoryData> history = const [], @JsonKey(includeFromJson: false, includeToJson: false)  List<Bookmark> bookmarks = const [], @JsonKey(includeFromJson: false, includeToJson: false)  List<Download> downloads = const [], this.isLoading = false, this.errorMessage}): _history = history,_bookmarks = bookmarks,_downloads = downloads;
  factory _LibraryState.fromJson(Map<String, dynamic> json) => _$LibraryStateFromJson(json);

@override@JsonKey() final  int selectedTab;
 final  List<WatchHistoryData> _history;
@override@JsonKey(includeFromJson: false, includeToJson: false) List<WatchHistoryData> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

 final  List<Bookmark> _bookmarks;
@override@JsonKey(includeFromJson: false, includeToJson: false) List<Bookmark> get bookmarks {
  if (_bookmarks is EqualUnmodifiableListView) return _bookmarks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookmarks);
}

 final  List<Download> _downloads;
@override@JsonKey(includeFromJson: false, includeToJson: false) List<Download> get downloads {
  if (_downloads is EqualUnmodifiableListView) return _downloads;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_downloads);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LibraryStateCopyWith<_LibraryState> get copyWith => __$LibraryStateCopyWithImpl<_LibraryState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LibraryStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LibraryState&&(identical(other.selectedTab, selectedTab) || other.selectedTab == selectedTab)&&const DeepCollectionEquality().equals(other.history, _history)&&const DeepCollectionEquality().equals(other.bookmarks, _bookmarks)&&const DeepCollectionEquality().equals(other.downloads, _downloads)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,selectedTab,const DeepCollectionEquality().hash(_history),const DeepCollectionEquality().hash(_bookmarks),const DeepCollectionEquality().hash(_downloads),isLoading,errorMessage);
}

@override
String toString() {
    return 'LibraryState(selectedTab: $selectedTab, history: $history, bookmarks: $bookmarks, downloads: $downloads, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$LibraryStateCopyWith<$Res> implements $LibraryStateCopyWith<$Res> {
  factory _$LibraryStateCopyWith(_LibraryState value, $Res Function(_LibraryState) _then) = __$LibraryStateCopyWithImpl;
@override @useResult
$Res call({
 int selectedTab,@JsonKey(includeFromJson: false, includeToJson: false) List<WatchHistoryData> history,@JsonKey(includeFromJson: false, includeToJson: false) List<Bookmark> bookmarks,@JsonKey(includeFromJson: false, includeToJson: false) List<Download> downloads, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$LibraryStateCopyWithImpl<$Res>
    implements _$LibraryStateCopyWith<$Res> {
  __$LibraryStateCopyWithImpl(this._self, this._then);

  final _LibraryState _self;
  final $Res Function(_LibraryState) _then;

/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedTab = null,Object? history = null,Object? bookmarks = null,Object? downloads = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_LibraryState(
selectedTab: null == selectedTab ? _self.selectedTab : selectedTab // ignore: cast_nullable_to_non_nullable
as int,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<WatchHistoryData>,bookmarks: null == bookmarks ? _self._bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as List<Bookmark>,downloads: null == downloads ? _self._downloads : downloads // ignore: cast_nullable_to_non_nullable
as List<Download>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
