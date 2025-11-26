import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Sign in with Firebase
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final token = await userCredential.user?.getIdToken();

      if (token != null) {
        await ref.read(authProvider.notifier).loginWithFirebase(token);
        if (mounted) {
          // Router will handle redirect based on profile completion
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Đăng nhập thất bại';
        
        if (e.toString().contains('user-not-found')) {
          errorMessage = 'Email không tồn tại. Vui lòng đăng ký tài khoản mới.';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Mật khẩu không đúng. Vui lòng thử lại.';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Email không hợp lệ.';
        } else if (e.toString().contains('user-disabled')) {
          errorMessage = 'Tài khoản đã bị vô hiệu hóa.';
        } else if (e.toString().contains('too-many-requests')) {
          errorMessage = 'Quá nhiều lần thử. Vui lòng thử lại sau.';
        } else {
          errorMessage = 'Đăng nhập thất bại: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      debugPrint('=== GOOGLE LOGIN START ===');
      final GoogleSignIn googleSignIn = GoogleSignIn();
      
      debugPrint('=== Requesting Google Sign In ===');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('=== User cancelled Google Sign In ===');
        setState(() => _isLoading = false);
        return;
      }

      debugPrint('=== Google user obtained: ${googleUser.email} ===');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      debugPrint('=== Google auth obtained ===');
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      debugPrint('=== Firebase credential created ===');

      debugPrint('=== Signing in with Firebase credential ===');
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint('=== Firebase sign in successful ===');
      
      // Test: Print Firebase user info
      print("=== FIREBASE USER ===");
      print("UID: ${userCredential.user?.uid}");
      print("Email: ${userCredential.user?.email}");
      print("Display Name: ${userCredential.user?.displayName}");
      print("Photo URL: ${userCredential.user?.photoURL}");
      debugPrint("=== FIREBASE USER UID: ${userCredential.user?.uid} ===");
      
      debugPrint('=== Getting Firebase ID token ===');
      final token = await userCredential.user?.getIdToken();
      debugPrint('=== Firebase token obtained, length: ${token?.length} ===');
      print("=== FIREBASE TOKEN LENGTH: ${token?.length} ===");

      if (token != null) {
        try {
          debugPrint('=== Calling authProvider.loginWithFirebase ===');
          await ref.read(authProvider.notifier).loginWithFirebase(token);
          if (mounted) {
            debugPrint('=== Login successful, redirecting... ===');
            // Router will handle redirect based on profile completion
            context.go('/home');
          }
        } catch (e, stackTrace) {
          debugPrint('=== Backend login error: $e ===');
          debugPrint('=== Stack trace: $stackTrace ===');
          if (mounted) {
            String errorMessage = 'Không thể kết nối đến server. ';
            if (e.toString().contains('SocketException') || 
                e.toString().contains('Failed host lookup') ||
                e.toString().contains('Connection refused')) {
              errorMessage += 'Vui lòng kiểm tra:\n'
                  '1. Backend server đang chạy (http://localhost:3000)\n'
                  '2. Đã cấu hình đúng IP trong app_config.dart\n'
                  '3. Emulator: dùng 10.0.2.2\n'
                  '4. Thiết bị thật: dùng IP máy tính (ipconfig/ifconfig)';
            } else {
              errorMessage += e.toString();
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                duration: const Duration(seconds: 6),
              ),
            );
          }
        }
      } else {
        debugPrint('=== ERROR: Cannot get Firebase token ===');
        throw Exception('Không thể lấy Firebase token');
      }
    } catch (e, stackTrace) {
      debugPrint('=== Google Login Exception: $e ===');
      debugPrint('=== Stack trace: $stackTrace ===');
      if (mounted) {
        String errorMessage = 'Đăng nhập với Google thất bại';
        
        if (e.toString().contains('sign_in_failed') || e.toString().contains('ApiException: 10')) {
          errorMessage = 'Lỗi cấu hình Google Sign-In. Vui lòng kiểm tra:\n'
              '1. Đã thêm SHA-1 fingerprint vào Firebase Console\n'
              '2. Đã tải google-services.json mới\n'
              '3. Đã enable Google Sign-In trong Firebase Authentication';
        } else if (e.toString().contains('network_error')) {
          errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
        } else if (e.toString().contains('sign_in_canceled')) {
          // User cancelled, don't show error
          setState(() => _isLoading = false);
          return;
        } else {
          errorMessage = 'Đăng nhập thất bại: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Logo
                const Icon(
                  Icons.favorite,
                  size: 80,
                  color: Color(0xFFE91E63),
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  'Welcome to Matcha',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find your perfect match',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _loginWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),
                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                // Google login button
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _loginWithGoogle,
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () => context.go('/auth/register'),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

