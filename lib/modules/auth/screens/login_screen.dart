import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/idrak_logo.dart';
import '../../../providers/app_state.dart';
import '../../../services/auth_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final AuthStorageService _authStorage = AuthStorageService();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isCheckingAutoLogin = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    setState(() => _isCheckingAutoLogin = true);

    debugPrint('[LoginScreen] Starting auto-login check...');

    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.tryAutoLogin();
    debugPrint('[LoginScreen] Auto-login result: $success');

    if (mounted) {
      setState(() => _isCheckingAutoLogin = false);
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final userToLogin = _usernameCtrl.text.trim();
    final passToLogin = _passwordCtrl.text.trim();

    if (userToLogin.isEmpty || passToLogin.isEmpty) {
      setState(() {
        _errorMessage = 'Zəhmət olmasa istifadəçi adı və şifrəni daxil edin.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final appState = Provider.of<AppState>(context, listen: false);
    final error = appState.login(
      userToLogin,
      passToLogin,
      saveCredentials: false,
    );

    if (error == null) {
      final biometricAvailable = await _authStorage.isBiometricAvailable();
      final biometricEnabled = await _authStorage.isBiometricEnabled();

      if (biometricAvailable && !biometricEnabled && rootContext.mounted) {
        final types = await _authStorage.getAvailableBiometrics();
        if (rootContext.mounted) {
          await _showBiometricSetupDialog(
            rootContext,
            userToLogin,
            passToLogin,
            types,
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    }
  }

  Future<void> _showBiometricSetupDialog(
    BuildContext dialogContext,
    String username,
    String password,
    List<BiometricType> types,
  ) async {
    final biometricName = _authStorage.getBiometricName(types);

    await showDialog<bool>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                types.contains(BiometricType.face)
                    ? Icons.face_rounded
                    : Icons.fingerprint_rounded,
                color: AppColors.primaryAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Biometrik Giriş',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          '$biometricName istifadə edərək növbəti girişlərdə daha sürətli və təhlükəsiz giriş edə bilərsiniz. Aktivləşdirmək istəyirsiniz?',
          style: TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Xeyr', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _authStorage.setBiometricEnabled(true);
              await _authStorage.saveCredentials(username, password);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Aktivləşdir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAutoLogin) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IdrakLogo(size: 80, showText: false, isLightText: true),
              SizedBox(height: 24),
              CircularProgressIndicator(
                color: AppColors.primaryAccent,
                strokeWidth: 2.5,
              ),
              SizedBox(height: 16),
              Text(
                'Yüklənir...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & Brand Header
                  const SizedBox(height: 12),
                  const IdrakLogo(size: 84, showText: true, isLightText: false),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryAccent.withAlpha(40)),
                    ),
                    child: const Text(
                      'BEYNƏLXALQ TƏHSİL PORTALI',
                      style: TextStyle(
                        color: AppColors.primaryAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: AppShadows.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sistemə Giriş',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Şəxsi istifadəçi məlumatlarınızla portala daxil olun.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),

                        // Error Banner
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withAlpha(15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.danger.withAlpha(40)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Username / Idrak Code Input
                        Text(
                          'İstifadəçi Adı və ya İdrak Kodu',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _usernameCtrl,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Məs: 10A-04 və ya teacher.ali',
                            hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryAccent, size: 20),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.cardBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Password Input
                        Text(
                          'Şifrə',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(),
                          decoration: InputDecoration(
                            hintText: 'Şifrənizi daxil edin',
                            hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryAccent, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: AppColors.textMuted,
                                size: 19,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.cardBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Login Action Button (Gradient Modern Button)
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppShadows.sm,
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Daxil Ol',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Security Badge
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_outlined, color: AppColors.primaryAccent, size: 15),
                        const SizedBox(width: 6),
                        Text(
                          '256-Bit SSL Təhlükəsiz Şifrələmə • İdrak Liseyi',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
