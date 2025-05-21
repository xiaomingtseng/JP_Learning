import 'package:flutter/material.dart';

class FunctionIconsRow extends StatelessWidget {
  final VoidCallback onNotebookPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onMicPressed;
  final VoidCallback? onRealtimeTranslatePressed; // 新增即時翻譯按鈕的回調

  const FunctionIconsRow({
    super.key,
    required this.onNotebookPressed,
    required this.onCameraPressed,
    required this.onMicPressed,
    this.onRealtimeTranslatePressed, // 讓其可選，以便舊的用法不受影響
  });

  Widget _buildFunctionIcon(
    BuildContext context, // Added context
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 30.0),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildFunctionIcon(
              context,
              Icons.note_alt_outlined,
              '筆記',
              onNotebookPressed,
            ),
            _buildFunctionIcon(
              context,
              Icons.camera_alt_outlined,
              '圖片文字擷取',
              onCameraPressed,
            ),
            _buildFunctionIcon(
              context,
              Icons.mic_none_outlined,
              '即時翻譯',
              onRealtimeTranslatePressed ?? onMicPressed, // 如果提供了新的回調則使用，否則使用舊的
            ),
            // 您可以繼續添加更多圖示
          ],
        ),
      ),
    );
  }
}
