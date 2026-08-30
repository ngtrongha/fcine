import 'package:flutter/material.dart';
import '../../../../../presentation/theme/app_theme.dart';

/// Overlay shown when player fails to load stream.
/// Provides retry, switch server and report actions.
/// Used in both mobile and desktop layouts.
/// Keeps UI consistent with design system.
/// Handles network errors and fallback logic.
/// Wraps actions in Wrap for responsive layout.

class PlayerErrorOverlay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSwitchServer;
  final VoidCallback onReport;

  const PlayerErrorOverlay({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onSwitchServer,
    required this.onReport,
  });

  Widget _buildIcon() {
    return const Icon(Icons.error_outline, color: AppColors.primary, size: 48);
  }

  Widget _buildMessage() {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
    );
  }

  Widget _buildActions() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Thử lại'),
          onPressed: onRetry,
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.swap_horiz, size: 16),
          label: const Text('Đổi server'),
          onPressed: onSwitchServer,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white38),
          ),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.bug_report, size: 16),
          label: const Text('Báo lỗi'),
          onPressed: onReport,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.amber,
            side: const BorderSide(color: Colors.amber),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(height: 12),
          _buildMessage(),
          const SizedBox(height: 16),
          _buildActions(),
        ],
      ),
    );
  }
}
