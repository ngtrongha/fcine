// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchState _$SearchStateFromJson(Map<String, dynamic> json) => _SearchState(
  status:
      $enumDecodeNullable(_$SearchStatusEnumMap, json['status']) ??
      SearchStatus.initial,
  keyword: json['keyword'] as String? ?? '',
  page: (json['page'] as num?)?.toInt() ?? 1,
  totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
  category: json['category'] as String?,
  country: json['country'] as String?,
  year: json['year'] as String?,
  type: json['type'] as String?,
  recentSearches:
      (json['recentSearches'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$SearchStateToJson(_SearchState instance) =>
    <String, dynamic>{
      'status': _$SearchStatusEnumMap[instance.status]!,
      'keyword': instance.keyword,
      'page': instance.page,
      'totalPages': instance.totalPages,
      'category': instance.category,
      'country': instance.country,
      'year': instance.year,
      'type': instance.type,
      'recentSearches': instance.recentSearches,
      'errorMessage': instance.errorMessage,
    };

const _$SearchStatusEnumMap = {
  SearchStatus.initial: 'initial',
  SearchStatus.loading: 'loading',
  SearchStatus.success: 'success',
  SearchStatus.failure: 'failure',
  SearchStatus.loadingMore: 'loadingMore',
};
