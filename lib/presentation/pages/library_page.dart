import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../core/database/app_database.dart';
import '../../core/download/download_service.dart';
import '../blocs/library/library_bloc.dart';
import '../blocs/library/library_event.dart';
import '../blocs/library/library_state.dart';
import '../../ui/features/library/views/widgets/storage_meter.dart';
import '../../ui/features/library/views/widgets/history_tab.dart';
import '../../ui/features/library/views/widgets/bookmarks_tab.dart';
import '../../ui/features/library/views/widgets/downloads_tab.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with SingleTickerProviderStateMixin {
  late TabController _tab;
  late final LibraryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = LibraryBloc(db: getIt<AppDatabase>(), downloadService: getIt<DownloadService>())..add(const LibraryEvent.started());
    _tab = TabController(length: 3, vsync: this, initialIndex: _bloc.state.selectedTab);
    _tab.addListener(() {
      if (_tab.indexIsChanging) _bloc.add(LibraryEvent.tabChanged(_tab.index));
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (_tab.index != state.selectedTab) _tab.index = state.selectedTab;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tủ Phim'),
              bottom: TabBar(
                controller: _tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF94A3B8),
                indicatorColor: const Color(0xFFE50914),
                tabs: [
                  Tab(text: 'Lịch Sử (${state.history.length})'),
                  Tab(text: 'Yêu Thích (${state.bookmarks.length})'),
                  Tab(text: 'Đã Tải (${state.downloads.length})'),
                ],
              ),
            ),
            body: Column(children: [
              StorageMeter(downloads: state.downloads),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    HistoryTab(items: state.history),
                    BookmarksTab(items: state.bookmarks),
                    DownloadsTab(items: state.downloads),
                  ],
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}
