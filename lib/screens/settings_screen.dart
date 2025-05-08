import 'package:flutter/material.dart';
import 'package:jp_learning/theme_notifier.dart'; // 匯入 ThemeNotifier
import 'package:provider/provider.dart'; // 匯入 Provider

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showHiragana = true;
  bool _enableNotifications = true;

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
        bottom: 8.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColorDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 從 Provider 獲取 ThemeNotifier
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: <Widget>[
          _buildSectionTitle(context, '顯示'),
          SwitchListTile(
            title: const Text('暗黑模式'),
            subtitle: Text(themeNotifier.isDarkMode ? '已啟用' : '已停用'),
            value: themeNotifier.isDarkMode, // 從 Notifier 獲取狀態
            onChanged: (bool value) {
              themeNotifier.toggleTheme(value); // 更新 Notifier 中的狀態
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('暗黑模式已${value ? "啟用" : "停用"}')),
              );
            },
            secondary: Icon(
              themeNotifier.isDarkMode
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
          ),
          const Divider(height: 0),
          SwitchListTile(
            title: const Text('顯示平假名'),
            subtitle: Text(_showHiragana ? '在漢字上方或旁邊顯示' : '不顯示額外的平假名'),
            value: _showHiragana,
            onChanged: (bool value) {
              setState(() {
                _showHiragana = value;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('顯示平假名已${_showHiragana ? "啟用" : "停用"}'),
                  ),
                );
              });
            },
            secondary: const Icon(Icons.translate_outlined),
          ),
          const Divider(height: 0),
          _buildSectionTitle(context, '通知'),
          SwitchListTile(
            title: const Text('啟用通知'),
            subtitle: Text(_enableNotifications ? '接收應用程式通知' : '不接收通知'),
            value: _enableNotifications,
            onChanged: (bool value) {
              setState(() {
                _enableNotifications = value;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('通知已${_enableNotifications ? "啟用" : "停用"}'),
                  ),
                );
              });
            },
            secondary: Icon(
              _enableNotifications
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
            ),
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }
}
