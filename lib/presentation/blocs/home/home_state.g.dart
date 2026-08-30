// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeState _$HomeStateFromJson(Map<String, dynamic> json) => _HomeState(
  status:
      $enumDecodeNullable(_$HomeStatusEnumMap, json['status']) ??
      HomeStatus.initial,
  selectedCategory: json['selectedCategory'] as String? ?? 'Tất Cả',
  page: (json['page'] as num?)?.toInt() ?? 1,
  hasMore: json['hasMore'] as bool? ?? true,
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$HomeStateToJson(_HomeState instance) =>
    <String, dynamic>{
      'status': _$HomeStatusEnumMap[instance.status]!,
      'selectedCategory': instance.selectedCategory,
      'page': instance.page,
      'hasMore': instance.hasMore,
      'errorMessage': instance.errorMessage,
    };

const _$HomeStatusEnumMap = {
  HomeStatus.initial: 'initial',
  HomeStatus.loading: 'loading',
  HomeStatus.success: 'success',
  HomeStatus.failure: 'failure',
  HomeStatus.loadingMore: 'loadingMore',
};
