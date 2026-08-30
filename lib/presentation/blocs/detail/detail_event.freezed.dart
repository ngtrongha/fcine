// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detail_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DetailEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DetailEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DetailEvent()';
}


}

/// @nodoc
class $DetailEventCopyWith<$Res>  {
$DetailEventCopyWith(DetailEvent _, $Res Function(DetailEvent) __);
}


/// Adds pattern-matching-related methods to [DetailEvent].
extension DetailEventPatterns on DetailEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DetailLoad value)?  load,TResult Function( DetailToggleBookmark value)?  toggleBookmark,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DetailLoad() when load != null:
return load(_that);case DetailToggleBookmark() when toggleBookmark != null:
return toggleBookmark(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DetailLoad value)  load,required TResult Function( DetailToggleBookmark value)  toggleBookmark,}){
final _that = this;
switch (_that) {
case DetailLoad():
return load(_that);case DetailToggleBookmark():
return toggleBookmark(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DetailLoad value)?  load,TResult? Function( DetailToggleBookmark value)?  toggleBookmark,}){
final _that = this;
switch (_that) {
case DetailLoad() when load != null:
return load(_that);case DetailToggleBookmark() when toggleBookmark != null:
return toggleBookmark(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String slug)?  load,TResult Function()?  toggleBookmark,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DetailLoad() when load != null:
return load(_that.slug);case DetailToggleBookmark() when toggleBookmark != null:
return toggleBookmark();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String slug)  load,required TResult Function()  toggleBookmark,}) {final _that = this;
switch (_that) {
case DetailLoad():
return load(_that.slug);case DetailToggleBookmark():
return toggleBookmark();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String slug)?  load,TResult? Function()?  toggleBookmark,}) {final _that = this;
switch (_that) {
case DetailLoad() when load != null:
return load(_that.slug);case DetailToggleBookmark() when toggleBookmark != null:
return toggleBookmark();case _:
  return null;

}
}

}

/// @nodoc


class DetailLoad extends DetailEvent {
  const DetailLoad(this.slug): super._();
  

 final  String slug;

/// Create a copy of DetailEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetailLoadCopyWith<DetailLoad> get copyWith => _$DetailLoadCopyWithImpl<DetailLoad>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DetailLoad&&(identical(other.slug, slug) || other.slug == slug));
}


@override
int get hashCode {
    return Object.hash(runtimeType,slug);
}

@override
String toString() {
    return 'DetailEvent.load(slug: $slug)';
}


}

/// @nodoc
abstract mixin class $DetailLoadCopyWith<$Res> implements $DetailEventCopyWith<$Res> {
  factory $DetailLoadCopyWith(DetailLoad value, $Res Function(DetailLoad) _then) = _$DetailLoadCopyWithImpl;
@useResult
$Res call({
 String slug
});




}
/// @nodoc
class _$DetailLoadCopyWithImpl<$Res>
    implements $DetailLoadCopyWith<$Res> {
  _$DetailLoadCopyWithImpl(this._self, this._then);

  final DetailLoad _self;
  final $Res Function(DetailLoad) _then;

/// Create a copy of DetailEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? slug = null,}) {
  return _then(DetailLoad(
null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DetailToggleBookmark extends DetailEvent {
  const DetailToggleBookmark(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DetailToggleBookmark);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DetailEvent.toggleBookmark()';
}


}




// dart format on
