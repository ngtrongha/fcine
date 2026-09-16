import 'package:flutter/material.dart';

import '../../../../../presentation/theme/app_theme.dart';

/// Glassmorphism episode list drawer for mobile player.
/// Reused in both mobile overlay and desktop theater.
/// Shows current episode highlight with equalizer icon.
/// Handles tap to switch episode via [onSelect].

class EpisodeDrawer extends StatefulWidget {
  final List flatEpisodes;
  final dynamic currentEpisode;
  final String currentServer;
  final VoidCallback onClose;
  final Function(dynamic ep, String server) onSelect;

  const EpisodeDrawer({
    super.key,
    required this.flatEpisodes,
    required this.currentEpisode,
    required this.currentServer,
    required this.onClose,
    required this.onSelect,
  });

  @override
  State<EpisodeDrawer> createState() => _EpisodeDrawerState();
}

class _EpisodeDrawerState extends State<EpisodeDrawer> {
  late final ScrollController _scrollController;
  final FocusNode _currentFocusNode = FocusNode();
  final GlobalKey _currentKey = GlobalKey();

  static const double _estimatedItemHeight = 44.0;
  static const double _estimatedViewportHeight = 160.0;

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
  void didUpdateWidget(covariant EpisodeDrawer oldWidget) {
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Text(
            'Danh Sách Tập',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white54,
              size: 16,
            ),
            onPressed: widget.onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _findCurrentIndex();
    return Container(
      width: 280,
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 16),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, color: Color(0xFF1E293B)),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: widget.flatEpisodes.length,
              itemBuilder: (context, i) {
                final item = widget.flatEpisodes[i];
                final isCurrent = (i == currentIndex);
                return _EpisodeDrawerTile(
                  key: isCurrent ? _currentKey : null,
                  ep: item['ep'],
                  server: item['server'],
                  isCurrent: isCurrent,
                  focusNode: isCurrent ? _currentFocusNode : null,
                  onSelect: widget.onSelect,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeDrawerTile extends StatefulWidget {
  final dynamic ep;
  final String server;
  final bool isCurrent;
  final FocusNode? focusNode;
  final Function(dynamic ep, String server) onSelect;

  const _EpisodeDrawerTile({
    super.key,
    required this.ep,
    required this.server,
    required this.isCurrent,
    this.focusNode,
    required this.onSelect,
  });

  @override
  State<_EpisodeDrawerTile> createState() => _EpisodeDrawerTileState();
}

class _EpisodeDrawerTileState extends State<_EpisodeDrawerTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isCurrent = widget.isCurrent;
    final isHighlighted = isCurrent || _isFocused;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        focusNode: widget.focusNode,
        autofocus: isCurrent,
        onFocusChange: (focused) {
          if (mounted) setState(() => _isFocused = focused);
        },
        onTap: () => widget.onSelect(widget.ep, widget.server),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _isFocused
                ? AppColors.primary.withValues(alpha: 0.35)
                : (isCurrent
                      ? AppColors.primary.withValues(alpha: 0.20)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isFocused
                  ? Colors.white
                  : (isCurrent
                        ? AppColors.primary.withValues(alpha: 0.60)
                        : Colors.transparent),
              width: _isFocused ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.ep.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isHighlighted ? AppColors.primary : Colors.white70,
                    fontWeight: isHighlighted
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              Icon(
                isCurrent ? Icons.graphic_eq_rounded : Icons.play_arrow_rounded,
                color: isHighlighted ? AppColors.primary : Colors.white38,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
