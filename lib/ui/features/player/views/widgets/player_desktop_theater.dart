import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../data/repositories/history_repository.dart';
import '../../../../../presentation/theme/app_theme.dart';
import '../../logic/player_logic.dart';
import 'player_error_overlay.dart';
import 'skip_outro_button.dart';

class PlayerDesktopTheater extends StatelessWidget {
  final VideoController controller;
  final BoxFit fit;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onSwitchServer;
  final VoidCallback onReport;
  final Duration position;
  final Duration duration;
  final ValueChanged<double> onSeek;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final VoidCallback onSeekBack;
  final VoidCallback onSeekForward;
  final List qualities;
  final ValueChanged<dynamic> onQualitySelected;
  final VoidCallback onChangeSpeed;
  final VoidCallback onCycleFit;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;
  final List flatEpisodes;
  final dynamic currentEpisode;
  final String currentServer;
  final String movieSlug;
  final Future<void> Function(dynamic ep, String server) onSelectEpisode;
  final String title;
  final VoidCallback onCast;
  final VoidCallback onPip;
  final VoidCallback onExternal;
  final bool muted;
  final VoidCallback onToggleMute;
  final bool showSkipOutro;
  final VoidCallback onSkipOutro;

  const PlayerDesktopTheater({
    super.key,
    required this.controller,
    required this.fit,
    required this.error,
    required this.onRetry,
    required this.onSwitchServer,
    required this.onReport,
    required this.position,
    required this.duration,
    required this.onSeek,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onSeekBack,
    required this.onSeekForward,
    required this.qualities,
    required this.onQualitySelected,
    required this.onChangeSpeed,
    required this.onCycleFit,
    required this.isFullscreen,
    required this.onToggleFullscreen,
    required this.flatEpisodes,
    required this.currentEpisode,
    required this.currentServer,
    required this.movieSlug,
    required this.onSelectEpisode,
    required this.title,
    required this.onCast,
    required this.onPip,
    required this.onExternal,
    required this.muted,
    required this.onToggleMute,
    required this.showSkipOutro,
    required this.onSkipOutro,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.cast, size: 20), onPressed: onCast),
          IconButton(
            icon: const Icon(Icons.picture_in_picture_alt, size: 20),
            onPressed: onPip,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 20),
            onPressed: onExternal,
          ),
          IconButton(
            icon: Icon(muted ? Icons.volume_off : Icons.volume_up, size: 20),
            onPressed: onToggleMute,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Video(
                  controller: controller,
                  fit: fit,
                  controls: NoVideoControls,
                ),
                if (error != null)
                  PlayerErrorOverlay(
                    message: error!,
                    onRetry: onRetry,
                    onSwitchServer: onSwitchServer,
                    onReport: onReport,
                  ),
                if (showSkipOutro && error == null)
                  Positioned(
                    bottom: 96,
                    right: 16,
                    child: SkipOutroButton(onTap: onSkipOutro),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Slider(
                          value: position.inMilliseconds.toDouble().clamp(
                            0,
                            duration.inMilliseconds.toDouble(),
                          ),
                          max: duration.inMilliseconds.toDouble() > 0
                              ? duration.inMilliseconds.toDouble()
                              : 1,
                          activeColor: AppColors.primary,
                          inactiveColor: Colors.white24,
                          onChanged: onSeek,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: onTogglePlay,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.replay_10_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: onSeekBack,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.forward_10_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: onSeekForward,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${formatDuration(position)} / ${formatDuration(duration)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                PopupMenuButton<dynamic>(
                                  icon: const Icon(
                                    Icons.high_quality_rounded,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  tooltip: 'Chất lượng',
                                  onSelected: onQualitySelected,
                                  itemBuilder: (_) => [
                                    for (final q in qualities)
                                      PopupMenuItem(
                                        value: q,
                                        child: Text((q as dynamic).label),
                                      ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.speed_rounded,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  onPressed: onChangeSpeed,
                                ),
                                IconButton(
                                  icon: Icon(
                                    fit == BoxFit.contain
                                        ? Icons.fit_screen_rounded
                                        : Icons.fullscreen_rounded,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  onPressed: onCycleFit,
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFullscreen
                                        ? Icons.fullscreen_exit_rounded
                                        : Icons.fullscreen_rounded,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  onPressed: onToggleFullscreen,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 380,
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Danh sách tập',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${flatEpisodes.length} tập',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFF1E293B)),
                Expanded(
                  child: DesktopEpisodeList(
                    flatEpisodes: flatEpisodes,
                    currentEpisode: currentEpisode,
                    currentServer: currentServer,
                    movieSlug: movieSlug,
                    onSelectEpisode: onSelectEpisode,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopEpisodeList extends StatefulWidget {
  final List flatEpisodes;
  final dynamic currentEpisode;
  final String currentServer;
  final String movieSlug;
  final Future<void> Function(dynamic ep, String server) onSelectEpisode;

  const DesktopEpisodeList({
    super.key,
    required this.flatEpisodes,
    required this.currentEpisode,
    required this.currentServer,
    required this.movieSlug,
    required this.onSelectEpisode,
  });

  @override
  State<DesktopEpisodeList> createState() => _DesktopEpisodeListState();
}

class _DesktopEpisodeListState extends State<DesktopEpisodeList> {
  late final ScrollController _scrollController;
  final FocusNode _currentFocusNode = FocusNode();
  final GlobalKey _currentKey = GlobalKey();

  /// Server đang xem trong tab (mặc định bám theo tập đang phát).
  late String _tab;

  /// Cache progress for episodes
  final Map<String, WatchHistoryData?> _progressCache = {};

  static const double _estimatedItemHeight = 56.0;
  static const double _estimatedViewportHeight = 400.0;

  /// Các server theo thứ tự xuất hiện trong danh sách.
  List<String> get _tabs {
    final out = <String>[];
    for (final item in widget.flatEpisodes) {
      final s = (item['server'] as String?) ?? '';
      if (!out.contains(s)) out.add(s);
    }
    return out;
  }

  bool get _hasTabs => _tabs.length > 1;

  /// Tập hiển thị: lọc theo tab server đang chọn (1 server -> giữ nguyên).
  List get _visibleItems {
    if (!_hasTabs) return widget.flatEpisodes;
    return widget.flatEpisodes
        .where((i) => ((i['server'] as String?) ?? '') == _tab)
        .toList();
  }

  int _countOf(String server) => widget.flatEpisodes
      .where((i) => ((i['server'] as String?) ?? '') == server)
      .length;

  String _initialTab() {
    final tabs = _tabs;
    if (tabs.contains(widget.currentServer)) return widget.currentServer;
    return tabs.isEmpty ? '' : tabs.first;
  }

  @override
  void initState() {
    super.initState();
    _tab = _initialTab();
    final currentIndex = _findCurrentIndex();
    double initialOffset = 0.0;
    if (currentIndex > 0) {
      initialOffset =
          ((currentIndex * _estimatedItemHeight) -
                  (_estimatedViewportHeight / 2) +
                  (_estimatedItemHeight / 2))
              .clamp(0.0, double.infinity);
    }
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _loadAllProgress();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToAndFocusCurrent();
    });
  }

  Future<void> _loadAllProgress() async {
    try {
      final repo = getIt<HistoryRepository>();
      final allHistory = await repo.db.getAllHistory();
      for (final h in allHistory) {
        if (h.movieSlug == widget.movieSlug) {
          final key = '${h.episodeSlug}::${h.serverName}';
          _progressCache[key] = h;
        }
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  void _scrollToAndFocusCurrent() {
    if (_currentKey.currentContext != null) {
      Scrollable.ensureVisible(
        _currentKey.currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
      );
    }
    _currentFocusNode.requestFocus();
  }

  @override
  void didUpdateWidget(covariant DesktopEpisodeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Phát sang server khác (auto-next / đổi server): tab bám theo.
    if (widget.currentServer != oldWidget.currentServer &&
        _tabs.contains(widget.currentServer)) {
      setState(() => _tab = widget.currentServer);
    }
    if (widget.currentEpisode.slug != oldWidget.currentEpisode.slug ||
        widget.currentServer != oldWidget.currentServer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scrollToAndFocusCurrent();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _currentFocusNode.dispose();
    super.dispose();
  }

  int _findCurrentIndex() {
    final items = _visibleItems;
    int slugMatch = -1;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final ep = item['ep'];
      final bool matchSlug = ep.slug == widget.currentEpisode.slug;
      final bool matchServer = item['server'] == widget.currentServer;
      if (matchSlug && matchServer) return i;
      if (matchSlug && slugMatch == -1) slugMatch = i;
    }
    return slugMatch;
  }

  void _switchTab(String server) {
    if (_tab == server) return;
    setState(() => _tab = server);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  Widget _buildServerTabs() {
    if (!_hasTabs) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.map((t) {
            final selected = t == _tab;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  '$t (${_countOf(t)})',
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: selected,
                onSelected: (_) => _switchTab(t),
                selectedColor: AppColors.primary,
                backgroundColor: const Color(0xFF1E293B),
                side: BorderSide(
                  color: selected
                      ? AppColors.primary
                      : const Color(0xFF334155),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;
    final currentIndex = _findCurrentIndex();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildServerTabs(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final ep = item['ep'];
              final isCurrent = (i == currentIndex);
              final progressKey = '${ep.slug}::${item['server']}';
              final progress = _progressCache[progressKey];
              return _DesktopEpisodeTile(
                key: isCurrent ? _currentKey : null,
                item: item,
                ep: ep,
                isCurrent: isCurrent,
                progress: progress,
                focusNode: isCurrent ? _currentFocusNode : null,
                onSelectEpisode: widget.onSelectEpisode,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DesktopEpisodeTile extends StatefulWidget {
  final dynamic item;
  final dynamic ep;
  final bool isCurrent;
  final WatchHistoryData? progress;
  final FocusNode? focusNode;
  final Future<void> Function(dynamic ep, String server) onSelectEpisode;

  const _DesktopEpisodeTile({
    super.key,
    required this.item,
    required this.ep,
    required this.isCurrent,
    this.progress,
    this.focusNode,
    required this.onSelectEpisode,
  });

  @override
  State<_DesktopEpisodeTile> createState() => _DesktopEpisodeTileState();
}

class _DesktopEpisodeTileState extends State<_DesktopEpisodeTile> {
  bool _isFocused = false;

  String _formatProgress(WatchHistoryData? p) {
    if (p == null || p.durationMs <= 0) return '';
    final percent = (p.positionMs / p.durationMs * 100).round();
    if (percent >= 95) return '✓ Xem xong';
    if (percent > 0) return '$percent%';
    return '';
  }

  Color _getProgressColor(WatchHistoryData? p) {
    if (p == null || p.durationMs <= 0) return Colors.white38;
    final percent = p.positionMs / p.durationMs;
    if (percent >= 0.95) return Colors.greenAccent;
    if (percent > 0) return Colors.amber;
    return Colors.white38;
  }

  @override
  Widget build(BuildContext context) {
    final isCurrent = widget.isCurrent;
    final isHighlighted = isCurrent || _isFocused;
    final progressText = _formatProgress(widget.progress);
    final progressColor = _getProgressColor(widget.progress);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: _isFocused
            ? AppColors.primary.withValues(alpha: 0.30)
            : (isCurrent
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: _isFocused
                ? Colors.white
                : (isCurrent
                      ? AppColors.primary.withValues(alpha: 0.50)
                      : Colors.transparent),
            width: _isFocused ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          focusNode: widget.focusNode,
          autofocus: isCurrent,
          onFocusChange: (focused) {
            if (mounted) setState(() => _isFocused = focused);
          },
          leading: Container(
            width: 48,
            height: 32,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.primary
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isCurrent
                  ? Icons.play_arrow_rounded
                  : Icons.play_circle_outline_rounded,
              color: isHighlighted ? Colors.white : Colors.white70,
              size: 18,
            ),
          ),
          title: Text(
            widget.ep.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isHighlighted ? Colors.white : Colors.white70,
              fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item['server'],
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
              ),
              if (progressText.isNotEmpty)
                Text(
                  progressText,
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          trailing: isCurrent
              ? const Icon(
                  Icons.equalizer_rounded,
                  color: AppColors.primary,
                  size: 16,
                )
              : null,
          onTap: () => widget.onSelectEpisode(widget.ep, widget.item['server']),
        ),
      ),
    );
  }
}
