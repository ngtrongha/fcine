// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LibraryState _$LibraryStateFromJson(Map<String, dynamic> json) =>
    _LibraryState(
      selectedTab: (json['selectedTab'] as num?)?.toInt() ?? 0,
      isLoading: json['isLoading'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$LibraryStateToJson(_LibraryState instance) =>
    <String, dynamic>{
      'selectedTab': instance.selectedTab,
      'isLoading': instance.isLoading,
      'errorMessage': instance.errorMessage,
    };
