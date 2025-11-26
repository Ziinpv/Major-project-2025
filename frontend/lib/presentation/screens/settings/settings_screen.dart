import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
        const SnackBar(content: Text('Không thể mở đường dẫn')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeProvider);
    final language = ref.watch(languageProvider);
    final textScale = ref.watch(textScaleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Thông tin ứng dụng',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Phiên bản'),
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
                title: const Text('Trạng thái server'),
                subtitle: Text(_checkingServer
                    ? 'Đang kiểm tra...'
                    : _serverOk == true
                        ? 'Hoạt động bình thường'
                        : 'Không thể kết nối'),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _checkingServer ? null : _checkServer,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Website'),
                onTap: () => _openUrl('https://example.com'),
              ),
              ListTile(
                leading: const Icon(Icons.policy_outlined),
                title: const Text('Chính sách & Điều khoản'),
                onTap: () => _openUrl('https://example.com/policy'),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('FAQ / Tài liệu hướng dẫn'),
                onTap: () => _openUrl('https://example.com/faq'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bạn đang sử dụng phiên bản mới nhất.')),
                  );
                },
                icon: const Icon(Icons.system_update),
                label: const Text('Kiểm tra cập nhật'),
              ),
            ],
          ),
          _buildSection(
            title: 'Tài khoản & bảo mật',
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Chỉnh sửa email'),
                subtitle: const Text('Chức năng đang phát triển'),
                onTap: () => _showComingSoon(),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Đổi mật khẩu'),
                subtitle: const Text('Chức năng đang phát triển'),
                onTap: () => _showComingSoon(),
              ),
            ],
          ),
          _buildSection(
            title: 'Ngôn ngữ & giao diện',
            children: [
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('Ngôn ngữ'),
                trailing: DropdownButton<String>(
                  value: language,
                  items: const [
                    DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
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
                title: const Text('Giao diện'),
                subtitle: const Text('Chọn chế độ sáng/tối hoặc theo hệ thống'),
                trailing: DropdownButton<ThemeMode>(
                  value: themeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Theo hệ thống'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Sáng'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Tối'),
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
                title: const Text('Kích thước chữ'),
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
            title: 'Trung tâm trợ giúp',
            children: [
              ListTile(
                leading: const Icon(Icons.question_answer_outlined),
                title: const Text('FAQ'),
                onTap: () => _openUrl('https://example.com/faq'),
              ),
              ListTile(
                leading: const Icon(Icons.support_agent),
                title: const Text('Liên hệ hỗ trợ'),
                onTap: () => _openUrl('mailto:support@example.com'),
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: const Text('Báo cáo sự cố / Gửi phản hồi'),
                onTap: () => _openUrl('https://example.com/support'),
              ),
            ],
          ),
          _buildSection(
            title: 'Tài khoản',
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Đăng xuất'),
                onTap: _confirmLogout,
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Xóa tài khoản'),
                subtitle: const Text('Tất cả dữ liệu sẽ bị xóa vĩnh viễn'),
                onTap: _confirmDelete,
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

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng đang được phát triển.')),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đăng xuất'),
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

  Future<void> _confirmDelete() async {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản'),
        content: const Text(
          'Tính năng đang trong quá trình phát triển. Vui lòng liên hệ hỗ trợ nếu bạn cần xóa tài khoản.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openUrl('mailto:support@example.com');
            },
            child: const Text('Liên hệ hỗ trợ'),
          ),
        ],
      ),
    );
  }
}

