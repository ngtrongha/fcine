import 'package:flutter/material.dart';

class PlayerTopBar extends StatelessWidget {
  final String title;
  final String serverName;
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final VoidCallback? onPip;

  const PlayerTopBar({
    super.key,
    required this.title,
    required this.serverName,
    required this.onBack,
    required this.onSettings,
    this.onPip,
  });

  Widget _buildBackButton() {
    return CircleAvatar(
      backgroundColor: Colors.white.withValues(alpha: 0.10),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
        onPressed: onBack,
      ),
    );
  }

  Widget _buildServerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xCC16A34A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        serverName,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        _buildServerBadge(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC000000), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: 12),
          Expanded(child: _buildTitle()),
          IconButton(
            icon: const Icon(Icons.lock_open_rounded, color: Colors.white70, size: 20),
            onPressed: () {},
          ),
          if (onPip != null)
            IconButton(
              tooltip: 'Cửa sổ nhỏ (PiP)',
              icon: const Icon(Icons.picture_in_picture_alt_rounded, color: Colors.white70, size: 20),
              onPressed: onPip,
            ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white70, size: 20),
            onPressed: onSettings,
          ),
        ],
      ),
    );
  }
}
