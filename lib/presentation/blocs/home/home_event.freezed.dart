// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'HomeEvent()';
}


}

/// @nodoc
class $HomeEventCopyWith<$Res>  {
$HomeEventCopyWith(HomeEvent _, $Res Function(HomeEvent) __);
}


/// Adds pattern-matching-related methods to [HomeEvent].
extension HomeEventPatterns on HomeEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HomeInitialLoad value)?  initialLoad,TResult Function( HomeCategoryChanged value)?  categoryChanged,TResult Function( HomeLoadMore value)?  loadMore,TResult Function( HomeRefresh value)?  refresh,TResult Function( HomeUndo value)?  undo,TResult Function( HomeRedo value)?  redo,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HomeInitialLoad() when initialLoad != null:
return initialLoad(_that);case HomeCategoryChanged() when categoryChanged != null:
return categoryChanged(_that);case HomeLoadMore() when loadMore != null:
return loadMore(_that);case HomeRefresh() when refresh != null:
return refresh(_that);case HomeUndo() when undo != null:
return undo(_that);case HomeRedo() when redo != null:
return redo(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HomeInitialLoad value)  initialLoad,required TResult Function( HomeCategoryChanged value)  categoryChanged,required TResult Function( HomeLoadMore value)  loadMore,required TResult Function( HomeRefresh value)  refresh,required TResult Function( HomeUndo value)  undo,required TResult Function( HomeRedo value)  redo,}){
final _that = this;
switch (_that) {
case HomeInitialLoad():
return initialLoad(_that);case HomeCategoryChanged():
return categoryChanged(_that);case HomeLoadMore():
return loadMore(_that);case HomeRefresh():
return refresh(_that);case HomeUndo():
return undo(_that);case HomeRedo():
return redo(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HomeInitialLoad value)?  initialLoad,TResult? Function( HomeCategoryChanged value)?  categoryChanged,TResult? Function( HomeLoadMore value)?  loadMore,TResult? Function( HomeRefresh value)?  refresh,TResult? Function( HomeUndo value)?  undo,TResult? Function( HomeRedo value)?  redo,}){
final _that = this;
switch (_that) {
case HomeInitialLoad() when initialLoad != null:
return initialLoad(_that);case HomeCategoryChanged() when categoryChanged != null:
return categoryChanged(_that);case HomeLoadMore() when loadMore != null:
return loadMore(_that);case HomeRefresh() when refresh != null:
return refresh(_that);case HomeUndo() when undo != null:
return undo(_that);case HomeRedo() when redo != null:
return redo(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initialLoad,TResult Function( String category)?  categoryChanged,TResult Function()?  loadMore,TResult Function()?  refresh,TResult Function()?  undo,TResult Function()?  redo,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HomeInitialLoad() when initialLoad != null:
return initialLoad();case HomeCategoryChanged() when categoryChanged != null:
return categoryChanged(_that.category);case HomeLoadMore() when loadMore != null:
return loadMore();case HomeRefresh() when refresh != null:
return refresh();case HomeUndo() when undo != null:
return undo();case HomeRedo() when redo != null:
return redo();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initialLoad,required TResult Function( String category)  categoryChanged,required TResult Function()  loadMore,required TResult Function()  refresh,required TResult Function()  undo,required TResult Function()  redo,}) {final _that = this;
switch (_that) {
case HomeInitialLoad():
return initialLoad();case HomeCategoryChanged():
return categoryChanged(_that.category);case HomeLoadMore():
return loadMore();case HomeRefresh():
return refresh();case HomeUndo():
return undo();case HomeRedo():
return redo();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initialLoad,TResult? Function( String category)?  categoryChanged,TResult? Function()?  loadMore,TResult? Function()?  refresh,TResult? Function()?  undo,TResult? Function()?  redo,}) {final _that = this;
switch (_that) {
case HomeInitialLoad() when initialLoad != null:
return initialLoad();case HomeCategoryChanged() when categoryChanged != null:
return categoryChanged(_that.category);case HomeLoadMore() when loadMore != null:
return loadMore();case HomeRefresh() when refresh != null:
return refresh();case HomeUndo() when undo != null:
return undo();case HomeRedo() when redo != null:
return redo();case _:
  return null;

}
}

}

/// @nodoc


class HomeInitialLoad extends HomeEvent {
  const HomeInitialLoad(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeInitialLoad);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'HomeEvent.initialLoad()';
}


}




/// @nodoc


class HomeCategoryChanged extends HomeEvent {
  const HomeCategoryChanged(this.category): super._();
  

 final  String category;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeCategoryChangedCopyWith<HomeCategoryChanged> get copyWith => _$HomeCategoryChangedCopyWithImpl<HomeCategoryChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeCategoryChanged&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode {
    return Object.hash(runtimeType,category);
}

@override
String toString() {
    return 'HomeEvent.categoryChanged(category: $category)';
}


}

/// @nodoc
abstract mixin class $HomeCategoryChangedCopyWith<$Res> implements $HomeEventCopyWith<$Res> {
  factory $HomeCategoryChangedCopyWith(HomeCategoryChanged value, $Res Function(HomeCategoryChanged) _then) = _$HomeCategoryChangedCopyWithImpl;
@useResult
$Res call({
 String category
});




}
/// @nodoc
class _$HomeCategoryChangedCopyWithImpl<$Res>
    implements $HomeCategoryChangedCopyWith<$Res> {
  _$HomeCategoryChangedCopyWithImpl(this._self, this._then);

  final HomeCategoryChanged _self;
  final $Res Function(HomeCategoryChanged) _then;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? category = null,}) {
  return _then(HomeCategoryChanged(
null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class HomeLoadMore extends HomeEvent {
  const HomeLoadMore(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeLoadMore);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'HomeEvent.loadMore()';
}


}




/// @nodoc


class HomeRefresh extends HomeEvent {
  const HomeRefresh(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeRefresh);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'HomeEvent.refresh()';
}


}




/// @nodoc


class HomeUndo extends HomeEvent {
  const HomeUndo(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeUndo);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'HomeEvent.undo()';
}


}




/// @nodoc


class HomeRedo extends HomeEvent {
  const HomeRedo(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeRedo);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'HomeEvent.redo()';
}


}




// dart format on
