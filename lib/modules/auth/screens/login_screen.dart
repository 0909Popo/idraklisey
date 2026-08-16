import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/theme/app_colors.dart';
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
      // If auto-login successful, UI will automatically switch due to Provider
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

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Capture the root navigator before login: a successful login makes
    // MainScreen swap this screen for the dashboard, disposing our context.
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    final appState = Provider.of<AppState>(context, listen: false);
    final error = appState.login(
      userToLogin,
      passToLogin,
      saveCredentials: false, // Stored only if the user opts into biometrics
    );

    if (error == null) {
      // Login successful, offer biometric login for next time
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

  /// Asks the user to enable biometric login. Credentials for auto-login
  /// are stored only when the user accepts.
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
            Icon(
              types.contains(BiometricType.face)
                  ? Icons.face_rounded
                  : Icons.fingerprint_rounded,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Biometrik Giriş',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          '$biometricName istifadə edərək növbəti girişlərdə daha sürətli və təhlükəsiz giriş edə bilərsiniz. Aktivləşdirmək istəyirsiniz?',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Xeyr',
              style: TextStyle(color: AppColors.textSecondary),
            ),
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
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Aktivləşdir',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking auto-login
    if (_isCheckingAutoLogin) {
      return const Scaffold(
        backgroundColor: Color(0xFF070E1E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IdrakLogo(size: 80, showText: false, isLightText: true),
              SizedBox(height: 24),
              CircularProgressIndicator(
                color: AppColors.goldLight,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Yüklənir...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF070E1E),
      body: Stack(
        children: [
          // Background subtle ambient light orbs
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryAccent.withAlpha(30),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withAlpha(25),
              ),
            ),
          ),

          // Main Login Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Official School Logo & Title
                  const IdrakLogo(size: 76, showText: true, isLightText: true),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withAlpha(80)),
                    ),
                    child: const Text(
                      'BEYNƏLXALQ TƏHSİL PORTALI',
                      style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Login Form Card
                  Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(100),
                          blurRadius: 35,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sistemə Giriş',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Şəxsi istifadəçi məlumatlarınızla portala daxil olun.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 22),

                        // Error Banner
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.danger.withAlpha(60)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 18),
                                const SizedBox(width: 10),
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
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _usernameCtrl,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'İstifadəçi adınızı və ya İdrak kodunuzu daxil edin',
                            hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Password Input
                        Text(
                          'Şifrə',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(),
                          decoration: InputDecoration(
                            hintText: 'Şifrənizi daxil edin',
                            hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 3,
                            ),
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Daxil Ol',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
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

                  const SizedBox(height: 28),

                  // Official School Support & Security Info Footer
                  Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.security_rounded, color: AppColors.goldLight, size: 16),
                        SizedBox(width: 8),
                        Text(
                          '256-Bit SSL Təhlükəsiz Şifrələmə • İdrak Liseyi',
                          style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
