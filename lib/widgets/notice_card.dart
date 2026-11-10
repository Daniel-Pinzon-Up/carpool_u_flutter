import 'package:flutter/material.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.isError = false,
  });

  final String message;
  final IconData icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = isError ? scheme.error : scheme.primary;
    return Semantics(
      liveRegion: isError,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isError ? const Color(0xFFFFF0EE) : const Color(0xFFEAF2FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: foreground, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
