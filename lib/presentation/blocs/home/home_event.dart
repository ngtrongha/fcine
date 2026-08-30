import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:replay_bloc/replay_bloc.dart' as replay;

part 'home_event.freezed.dart';

@freezed
class HomeEvent extends replay.ReplayEvent with _$HomeEvent {
  const HomeEvent._() : super();
  const factory HomeEvent.initialLoad() = HomeInitialLoad;
  const factory HomeEvent.categoryChanged(String category) = HomeCategoryChanged;
  const factory HomeEvent.loadMore() = HomeLoadMore;
  const factory HomeEvent.refresh() = HomeRefresh;
  const factory HomeEvent.undo() = HomeUndo;
  const factory HomeEvent.redo() = HomeRedo;
}
