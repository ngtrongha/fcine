// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DetailState _$DetailStateFromJson(Map<String, dynamic> json) => _DetailState(
  status:
      $enumDecodeNullable(_$DetailStatusEnumMap, json['status']) ??
      DetailStatus.initial,
  isBookmarked: json['isBookmarked'] as bool? ?? false,
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$DetailStateToJson(_DetailState instance) =>
    <String, dynamic>{
      'status': _$DetailStatusEnumMap[instance.status]!,
      'isBookmarked': instance.isBookmarked,
      'errorMessage': instance.errorMessage,
    };

const _$DetailStatusEnumMap = {
  DetailStatus.initial: 'initial',
  DetailStatus.loading: 'loading',
  DetailStatus.success: 'success',
  DetailStatus.failure: 'failure',
};
