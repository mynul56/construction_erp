import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/enterprise_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/animations/animation_utils.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event_state.dart';
import '../widgets/role_selector.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.admin;
  bool _obscurePass = true;

  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );
    _logoRotate = Tween<double>(begin: -0.05, end: 0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutQuart),
    );
    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _doLogin(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(LoginRequested(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          role: _selectedRole,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/dashboard');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ));
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // ── Background ─────────────────────────────────
            _Background(isDark: isDark),
            // ── Content ────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // Logo
                    ScaleTransition(
                      scale: _logoScale,
                      child: RotationTransition(
                        turns: _logoRotate,
                        child: _Logo(),
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Form card
                    StaggeredFadeSlide(
                      delay: const Duration(milliseconds: 300),
                      child: GlassmorphicCard(
                        borderRadius: 24,
                        blurSigma: 16,
                        padding: const EdgeInsets.all(28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sign in to your workspace',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withAlpha(153),
                                    ),
                              ),
                              const SizedBox(height: 28),
                              // Role selector
                              RoleSelector(
                                selected: _selectedRole,
                                onChanged: (r) =>
                                    setState(() => _selectedRole = r),
                              ),
                              const SizedBox(height: 22),
                              // Email
                              _GlassField(
                                controller: _emailCtrl,
                                label: 'Email address',
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) =>
                                    (v == null || !v.contains('@'))
                                        ? 'Enter a valid email'
                                        : null,
                              ),
                              const SizedBox(height: 14),
                              // Password
                              _GlassField(
                                controller: _passCtrl,
                                label: 'Password',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePass,
                                suffix: IconButton(
                                  onPressed: () => setState(
                                      () => _obscurePass = !_obscurePass),
                                  icon: Icon(
                                    _obscurePass
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white54,
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Min 6 characters'
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Forgot password?',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(color: AppColors.cyan),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Submit button
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return EnterpriseButton(
                                    label: 'Sign In',
                                    icon: Icons.arrow_forward_rounded,
                                    isLoading: state is AuthLoading,
                                    onPressed: state is AuthLoading
                                        ? null
                                        : () => _doLogin(context),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    StaggeredFadeSlide(
                      delay: const Duration(milliseconds: 600),
                      child: Center(
                        child: Text(
                          'Constructio ERP v1.0.0',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withAlpha(77),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private Widgets ──────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  const _Background({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF050915), AppColors.navyDeep]
                  : [const Color(0xFF1A2744), const Color(0xFF0A0F1E)],
            ),
          ),
        ),
        // Cyan glow orb top-right
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.cyan.withAlpha(51),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Purple orb bottom-left
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.purple.withAlpha(38),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: AppColors.cyanGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withAlpha(77),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.construction_rounded,
            color: AppColors.navyDeep,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'CONSTRUCTIO',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enterprise Resource Platform',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.cyan,
                letterSpacing: 1.5,
              ),
        ),
      ],
    );
  }
}

class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withAlpha(153)),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withAlpha(13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(38)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
