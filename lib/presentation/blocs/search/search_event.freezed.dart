// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SearchEvent()';
}


}

/// @nodoc
class $SearchEventCopyWith<$Res>  {
$SearchEventCopyWith(SearchEvent _, $Res Function(SearchEvent) __);
}


/// Adds pattern-matching-related methods to [SearchEvent].
extension SearchEventPatterns on SearchEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SearchKeywordChanged value)?  keywordChanged,TResult Function( SearchFilterChanged value)?  filterChanged,TResult Function( SearchLoadMore value)?  loadMore,TResult Function( SearchClear value)?  clear,TResult Function( SearchRecentLoaded value)?  recentLoaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SearchKeywordChanged() when keywordChanged != null:
return keywordChanged(_that);case SearchFilterChanged() when filterChanged != null:
return filterChanged(_that);case SearchLoadMore() when loadMore != null:
return loadMore(_that);case SearchClear() when clear != null:
return clear(_that);case SearchRecentLoaded() when recentLoaded != null:
return recentLoaded(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SearchKeywordChanged value)  keywordChanged,required TResult Function( SearchFilterChanged value)  filterChanged,required TResult Function( SearchLoadMore value)  loadMore,required TResult Function( SearchClear value)  clear,required TResult Function( SearchRecentLoaded value)  recentLoaded,}){
final _that = this;
switch (_that) {
case SearchKeywordChanged():
return keywordChanged(_that);case SearchFilterChanged():
return filterChanged(_that);case SearchLoadMore():
return loadMore(_that);case SearchClear():
return clear(_that);case SearchRecentLoaded():
return recentLoaded(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SearchKeywordChanged value)?  keywordChanged,TResult? Function( SearchFilterChanged value)?  filterChanged,TResult? Function( SearchLoadMore value)?  loadMore,TResult? Function( SearchClear value)?  clear,TResult? Function( SearchRecentLoaded value)?  recentLoaded,}){
final _that = this;
switch (_that) {
case SearchKeywordChanged() when keywordChanged != null:
return keywordChanged(_that);case SearchFilterChanged() when filterChanged != null:
return filterChanged(_that);case SearchLoadMore() when loadMore != null:
return loadMore(_that);case SearchClear() when clear != null:
return clear(_that);case SearchRecentLoaded() when recentLoaded != null:
return recentLoaded(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String keyword)?  keywordChanged,TResult Function( String? category,  String? country,  String? year,  String? type)?  filterChanged,TResult Function()?  loadMore,TResult Function()?  clear,TResult Function( List<String> recent)?  recentLoaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SearchKeywordChanged() when keywordChanged != null:
return keywordChanged(_that.keyword);case SearchFilterChanged() when filterChanged != null:
return filterChanged(_that.category,_that.country,_that.year,_that.type);case SearchLoadMore() when loadMore != null:
return loadMore();case SearchClear() when clear != null:
return clear();case SearchRecentLoaded() when recentLoaded != null:
return recentLoaded(_that.recent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String keyword)  keywordChanged,required TResult Function( String? category,  String? country,  String? year,  String? type)  filterChanged,required TResult Function()  loadMore,required TResult Function()  clear,required TResult Function( List<String> recent)  recentLoaded,}) {final _that = this;
switch (_that) {
case SearchKeywordChanged():
return keywordChanged(_that.keyword);case SearchFilterChanged():
return filterChanged(_that.category,_that.country,_that.year,_that.type);case SearchLoadMore():
return loadMore();case SearchClear():
return clear();case SearchRecentLoaded():
return recentLoaded(_that.recent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String keyword)?  keywordChanged,TResult? Function( String? category,  String? country,  String? year,  String? type)?  filterChanged,TResult? Function()?  loadMore,TResult? Function()?  clear,TResult? Function( List<String> recent)?  recentLoaded,}) {final _that = this;
switch (_that) {
case SearchKeywordChanged() when keywordChanged != null:
return keywordChanged(_that.keyword);case SearchFilterChanged() when filterChanged != null:
return filterChanged(_that.category,_that.country,_that.year,_that.type);case SearchLoadMore() when loadMore != null:
return loadMore();case SearchClear() when clear != null:
return clear();case SearchRecentLoaded() when recentLoaded != null:
return recentLoaded(_that.recent);case _:
  return null;

}
}

}

/// @nodoc


class SearchKeywordChanged extends SearchEvent {
  const SearchKeywordChanged(this.keyword): super._();
  

 final  String keyword;

/// Create a copy of SearchEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchKeywordChangedCopyWith<SearchKeywordChanged> get copyWith => _$SearchKeywordChangedCopyWithImpl<SearchKeywordChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchKeywordChanged&&(identical(other.keyword, keyword) || other.keyword == keyword));
}


@override
int get hashCode {
    return Object.hash(runtimeType,keyword);
}

@override
String toString() {
    return 'SearchEvent.keywordChanged(keyword: $keyword)';
}


}

/// @nodoc
abstract mixin class $SearchKeywordChangedCopyWith<$Res> implements $SearchEventCopyWith<$Res> {
  factory $SearchKeywordChangedCopyWith(SearchKeywordChanged value, $Res Function(SearchKeywordChanged) _then) = _$SearchKeywordChangedCopyWithImpl;
@useResult
$Res call({
 String keyword
});




}
/// @nodoc
class _$SearchKeywordChangedCopyWithImpl<$Res>
    implements $SearchKeywordChangedCopyWith<$Res> {
  _$SearchKeywordChangedCopyWithImpl(this._self, this._then);

  final SearchKeywordChanged _self;
  final $Res Function(SearchKeywordChanged) _then;

/// Create a copy of SearchEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? keyword = null,}) {
  return _then(SearchKeywordChanged(
null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SearchFilterChanged extends SearchEvent {
  const SearchFilterChanged({this.category, this.country, this.year, this.type}): super._();
  

 final  String? category;
 final  String? country;
 final  String? year;
 final  String? type;

/// Create a copy of SearchEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchFilterChangedCopyWith<SearchFilterChanged> get copyWith => _$SearchFilterChangedCopyWithImpl<SearchFilterChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFilterChanged&&(identical(other.category, category) || other.category == category)&&(identical(other.country, country) || other.country == country)&&(identical(other.year, year) || other.year == year)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode {
    return Object.hash(runtimeType,category,country,year,type);
}

@override
String toString() {
    return 'SearchEvent.filterChanged(category: $category, country: $country, year: $year, type: $type)';
}


}

/// @nodoc
abstract mixin class $SearchFilterChangedCopyWith<$Res> implements $SearchEventCopyWith<$Res> {
  factory $SearchFilterChangedCopyWith(SearchFilterChanged value, $Res Function(SearchFilterChanged) _then) = _$SearchFilterChangedCopyWithImpl;
@useResult
$Res call({
 String? category, String? country, String? year, String? type
});




}
/// @nodoc
class _$SearchFilterChangedCopyWithImpl<$Res>
    implements $SearchFilterChangedCopyWith<$Res> {
  _$SearchFilterChangedCopyWithImpl(this._self, this._then);

  final SearchFilterChanged _self;
  final $Res Function(SearchFilterChanged) _then;

/// Create a copy of SearchEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? category = freezed,Object? country = freezed,Object? year = freezed,Object? type = freezed,}) {
  return _then(SearchFilterChanged(
category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class SearchLoadMore extends SearchEvent {
  const SearchLoadMore(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchLoadMore);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SearchEvent.loadMore()';
}


}




/// @nodoc


class SearchClear extends SearchEvent {
  const SearchClear(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchClear);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SearchEvent.clear()';
}


}




/// @nodoc


class SearchRecentLoaded extends SearchEvent {
  const SearchRecentLoaded( List<String> recent): _recent = recent,super._();
  

 final  List<String> _recent;
 List<String> get recent {
  if (_recent is EqualUnmodifiableListView) return _recent;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recent);
}


/// Create a copy of SearchEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchRecentLoadedCopyWith<SearchRecentLoaded> get copyWith => _$SearchRecentLoadedCopyWithImpl<SearchRecentLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchRecentLoaded&&const DeepCollectionEquality().equals(other.recent, _recent));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_recent));
}

@override
String toString() {
    return 'SearchEvent.recentLoaded(recent: $recent)';
}


}

/// @nodoc
abstract mixin class $SearchRecentLoadedCopyWith<$Res> implements $SearchEventCopyWith<$Res> {
  factory $SearchRecentLoadedCopyWith(SearchRecentLoaded value, $Res Function(SearchRecentLoaded) _then) = _$SearchRecentLoadedCopyWithImpl;
@useResult
$Res call({
 List<String> recent
});




}
/// @nodoc
class _$SearchRecentLoadedCopyWithImpl<$Res>
    implements $SearchRecentLoadedCopyWith<$Res> {
  _$SearchRecentLoadedCopyWithImpl(this._self, this._then);

  final SearchRecentLoaded _self;
  final $Res Function(SearchRecentLoaded) _then;

/// Create a copy of SearchEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? recent = null,}) {
  return _then(SearchRecentLoaded(
null == recent ? _self._recent : recent // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
