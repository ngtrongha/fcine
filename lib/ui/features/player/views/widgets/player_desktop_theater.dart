import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../presentation/theme/app_theme.dart';
import '../../logic/player_logic.dart';
import 'player_error_overlay.dart';

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
  final Future<void> Function(dynamic ep, String server) onSelectEpisode;
  final String title;
  final VoidCallback onCast;
  final VoidCallback onPip;
  final VoidCallback onExternal;
  final bool muted;
  final VoidCallback onToggleMute;

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
    required this.onSelectEpisode,
    required this.title,
    required this.onCast,
    required this.onPip,
    required this.onExternal,
    required this.muted,
    required this.onToggleMute,
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
  final Future<void> Function(dynamic ep, String server) onSelectEpisode;

  const DesktopEpisodeList({
    super.key,
    required this.flatEpisodes,
    required this.currentEpisode,
    required this.currentServer,
    required this.onSelectEpisode,
  });

  @override
  State<DesktopEpisodeList> createState() => _DesktopEpisodeListState();
}

class _DesktopEpisodeListState extends State<DesktopEpisodeList> {
  late final ScrollController _scrollController;
  final FocusNode _currentFocusNode = FocusNode();
  final GlobalKey _currentKey = GlobalKey();

  static const double _estimatedItemHeight = 56.0;
  static const double _estimatedViewportHeight = 400.0;

  @override
  void initState() {
    super.initState();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToAndFocusCurrent();
    });
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
    int slugMatch = -1;
    for (int i = 0; i < widget.flatEpisodes.length; i++) {
      final item = widget.flatEpisodes[i];
      final ep = item['ep'];
      final bool matchSlug = ep.slug == widget.currentEpisode.slug;
      final bool matchServer = item['server'] == widget.currentServer;
      if (matchSlug && matchServer) return i;
      if (matchSlug && slugMatch == -1) slugMatch = i;
    }
    return slugMatch;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _findCurrentIndex();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: widget.flatEpisodes.length,
      itemBuilder: (context, i) {
        final item = widget.flatEpisodes[i];
        final ep = item['ep'];
        final isCurrent = (i == currentIndex);
        return _DesktopEpisodeTile(
          key: isCurrent ? _currentKey : null,
          item: item,
          ep: ep,
          isCurrent: isCurrent,
          focusNode: isCurrent ? _currentFocusNode : null,
          onSelectEpisode: widget.onSelectEpisode,
        );
      },
    );
  }
}

class _DesktopEpisodeTile extends StatefulWidget {
  final dynamic item;
  final dynamic ep;
  final bool isCurrent;
  final FocusNode? focusNode;
  final Future<void> Function(dynamic ep, String server) onSelectEpisode;

  const _DesktopEpisodeTile({
    super.key,
    required this.item,
    required this.ep,
    required this.isCurrent,
    this.focusNode,
    required this.onSelectEpisode,
  });

  @override
  State<_DesktopEpisodeTile> createState() => _DesktopEpisodeTileState();
}

class _DesktopEpisodeTileState extends State<_DesktopEpisodeTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isCurrent = widget.isCurrent;
    final isHighlighted = isCurrent || _isFocused;

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
          subtitle: Text(
            widget.item['server'],
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
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
