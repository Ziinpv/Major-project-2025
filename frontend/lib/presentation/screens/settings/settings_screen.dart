import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/extensions/localization_extension.dart';
import '../../../core/providers/app_theme_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/text_scale_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../data/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '-';
  bool? _serverOk;
  bool _checkingServer = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _checkServer();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _version = '${info.version}+${info.buildNumber}';
    });
  }

  Future<void> _checkServer() async {
    setState(() {
      _checkingServer = true;
    });
    try {
      final response = await ApiService().get('/health');
      final ok = response.statusCode == 200 &&
          response.data is Map &&
          response.data['status'] == 'ok';
      setState(() {
        _serverOk = ok;
      });
    } catch (_) {
      setState(() {
        _serverOk = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _checkingServer = false;
        });
      }
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.common_error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final themeMode = ref.watch(appThemeProvider);
    final language = ref.watch(languageProvider);
    final textScale = ref.watch(textScaleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: l10n.settings_app_info,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.settings_version),
                subtitle: Text(_version),
              ),
              ListTile(
                leading: Icon(
                  _serverOk == null
                      ? Icons.help_outline
                      : _serverOk == true
                          ? Icons.check_circle
                          : Icons.error_outline,
                  color: _serverOk == true
                      ? Colors.green
                      : _serverOk == false
                          ? Colors.red
                          : null,
                ),
                title: Text(l10n.settings_server_status),
                subtitle: Text(_checkingServer
                    ? l10n.settings_checking
                    : _serverOk == true
                        ? l10n.settings_server_ok
                        : l10n.settings_server_error),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _checkingServer ? null : _checkServer,
                ),
              ),
            ],
          ),
          _buildSection(
            title: l10n.settings_language_ui,
            children: [
              ListTile(
                leading: const Icon(Icons.translate),
                title: Text(l10n.settings_language),
                trailing: DropdownButton<String>(
                  value: language,
                  items: [
                    DropdownMenuItem(value: 'vi', child: Text(l10n.settings_language_vietnamese)),
                    DropdownMenuItem(value: 'en', child: Text(l10n.settings_language_english)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(languageProvider.notifier).setLanguage(value);
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: Text(l10n.settings_theme),
                subtitle: Text(l10n.settings_theme_subtitle),
                trailing: DropdownButton<ThemeMode>(
                  value: themeMode,
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(l10n.settings_theme_system),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(l10n.settings_theme_light),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(l10n.settings_theme_dark),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(appThemeProvider.notifier).setThemeMode(mode);
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.format_size),
                title: Text(l10n.settings_text_size),
                subtitle: Slider(
                  value: textScale,
                  min: 0.9,
                  max: 1.3,
                  divisions: 4,
                  label: textScale.toStringAsFixed(1),
                  onChanged: (value) =>
                      ref.read(textScaleProvider.notifier).setScale(value),
                ),
              ),
            ],
          ),
          _buildSection(
            title: l10n.settings_help_center,
            children: [
              ListTile(
                leading: const Icon(Icons.question_answer_outlined),
                title: Text(l10n.settings_faq),
                onTap: () => _openUrl('https://example.com/faq'),
              ),
              ListTile(
                leading: const Icon(Icons.support_agent),
                title: Text(l10n.settings_contact_support),
                onTap: () => _openUrl('mailto:support@example.com'),
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: Text(l10n.settings_report_bug),
                onTap: () => _openUrl('https://example.com/support'),
              ),
            ],
          ),
          _buildSection(
            title: l10n.settings_account,
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(l10n.settings_logout),
                onTap: _confirmLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settings_logout),
        content: Text(l10n.settings_logout_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.settings_logout),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go('/auth/login');
      }
    }
  }
}
