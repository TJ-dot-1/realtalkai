import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gradient_button.dart';

/// Login screen with email + Google sign-in
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Navigate on successful auth
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppConstants.routeHome);
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  // Logo / Branding
                  _buildLogo(),
                  const SizedBox(height: 48),
                  // Auth form
                  _buildForm(authState),
                  const SizedBox(height: 24),
                  // Divider
                  _buildDivider(),
                  const SizedBox(height: 24),
                  // Google Sign In
                  _buildGoogleButton(authState),
                  const SizedBox(height: 24),
                  // Toggle sign up / sign in
                  _buildToggle(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Animated logo container
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('🎙️', style: TextStyle(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'RealTalk AI',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Master Real Conversations',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AuthState authState) {
    return Column(
      children: [
        if (_isSignUp) ...[
          // Name field
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Your name',
              prefixIcon: Icon(Icons.person_outline, color: AppTheme.textTertiary),
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 16),
        ],
        // Email field
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Email address',
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textTertiary),
          ),
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 16),
        // Password field
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon:
                const Icon(Icons.lock_outline, color: AppTheme.textTertiary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textTertiary,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 24),
        // Error message
        if (authState.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              authState.error!,
              style: const TextStyle(color: AppTheme.error, fontSize: 13),
            ),
          ),
        // Submit button
        GradientButton(
          text: _isSignUp ? 'Create Account' : 'Sign In',
          isLoading: authState.isLoading,
          icon: _isSignUp ? Icons.person_add : Icons.login,
          onPressed: _handleSubmit,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
            child: Divider(color: AppTheme.cardBorder.withOpacity(0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
            child: Divider(color: AppTheme.cardBorder.withOpacity(0.3))),
      ],
    );
  }

  Widget _buildGoogleButton(AuthState authState) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: authState.isLoading
            ? null
            : () => ref.read(authProvider.notifier).signInWithGoogle(),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.cardBorder.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
        icon: const Text('G',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            )),
        label: const Text(
          'Google',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return TextButton(
      onPressed: () => setState(() => _isSignUp = !_isSignUp),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14),
          children: [
            TextSpan(
              text: _isSignUp
                  ? 'Already have an account? '
                  : "Don't have an account? ",
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            TextSpan(
              text: _isSignUp ? 'Sign In' : 'Sign Up',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    if (_isSignUp) {
      final name = _nameController.text.trim();
      if (name.isEmpty) return;
      ref.read(authProvider.notifier).signUpWithEmail(email, password, name);
    } else {
      ref.read(authProvider.notifier).signInWithEmail(email, password);
    }
  }
}
