import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/extensions/localization_extension.dart';
import '../../../core/providers/app_theme_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/text_scale_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/user_provider.dart';
import 'change_password_dialog.dart';
import 'change_firebase_password_dialog.dart';

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
                leading: const Icon(Icons.lock_outline),
                title: Text(l10n.settings_change_password),
                subtitle: Text(l10n.settings_change_password_subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Check if user is authenticated with Firebase
                  final firebaseUser = FirebaseAuth.instance.currentUser;
                  
                  showDialog(
                    context: context,
                    builder: (context) {
                      // Use Firebase password dialog for Firebase-authenticated users
                      if (firebaseUser != null) {
                        return const ChangeFirebasePasswordDialog();
                      }
                      // Use MongoDB password dialog for email/password users
                      return const ChangePasswordDialog();
                    },
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text(
                  l10n.settings_delete_account,
                  style: const TextStyle(color: Colors.red),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                onTap: _confirmDeleteAccount,
              ),
              const Divider(),
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

  Future<void> _confirmDeleteAccount() async {
    final l10n = context.l10n;
    final passwordController = TextEditingController();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    bool isLoading = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.settings_delete_account_warning,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settings_delete_account_message,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: l10n.settings_delete_account_password_hint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  onChanged: (value) {
                    // Trigger rebuild to enable/disable button
                    setState(() {});
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
                child: Text(l10n.common_cancel),
              ),
              ElevatedButton(
                onPressed: (isLoading || passwordController.text.isEmpty)
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          // Step 1: Verify password with appropriate method
                          if (firebaseUser != null && firebaseUser.email != null) {
                            print('🔐 Verifying Firebase password...');
                            // For Firebase users: Re-authenticate with Firebase first
                            final credential = EmailAuthProvider.credential(
                              email: firebaseUser.email!,
                              password: passwordController.text,
                            );
                            
                            await firebaseUser.reauthenticateWithCredential(credential);
                            print('✅ Firebase password verified');
                          }
                          
                          // Step 2: Call backend to delete account data
                          print('🗑️ Calling backend to delete account data...');
                          final userRepository = ref.read(userRepositoryProvider);
                          await userRepository.deleteAccount(
                            password: passwordController.text,
                          );
                          print('✅ Account data deleted from backend');
                          
                          // Step 3: Delete Firebase account
                          if (firebaseUser != null) {
                            print('🔥 Deleting Firebase account...');
                            await firebaseUser.delete();
                            print('✅ Firebase account deleted');
                          }
                          
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        } on FirebaseAuthException catch (e) {
                          print('❌ Firebase auth error: ${e.code}');
                          if (context.mounted) {
                            setState(() {
                              isLoading = false;
                            });
                            
                            String errorMessage = 'Incorrect password';
                            if (e.code == 'wrong-password') {
                              errorMessage = 'Current password is incorrect';
                            } else if (e.code == 'too-many-requests') {
                              errorMessage = 'Too many failed attempts. Please try again later';
                            }
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        } catch (e) {
                          print('❌ Error: $e');
                          if (context.mounted) {
                            setState(() {
                              isLoading = false;
                            });
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.settings_delete_permanently),
              ),
            ],
          );
        },
      ),
    );

    passwordController.dispose();

    if (result == true) {
      // Account deleted successfully
      await ref.read(authProvider.notifier).logout();
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settings_account_deleted_success),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Redirect to login
        context.go('/auth/login');
      }
    }
  }
}
