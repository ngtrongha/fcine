import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:replay_bloc/replay_bloc.dart' as replay;

part 'detail_event.freezed.dart';

@freezed
class DetailEvent extends replay.ReplayEvent with _$DetailEvent {
  const DetailEvent._() : super();
  const factory DetailEvent.load(String slug) = DetailLoad;
  const factory DetailEvent.toggleBookmark() = DetailToggleBookmark;
}
