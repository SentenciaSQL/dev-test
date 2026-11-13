import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _asDeveloper = true;
  bool _asTester = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final roles = <String>{
      if (_asDeveloper) 'DEVELOPER',
      if (_asTester) 'TESTER',
    };
    if (roles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un rol')),
      );
      return;
    }
    try {
      await ref.read(authControllerProvider.notifier).register(
            email: _email.text.trim(),
            password: _password.text,
            displayName: _name.text.trim(),
            roles: roles,
          );
      if (mounted) context.go('/home');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      body: AppScaffoldBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IconButton(
                        alignment: Alignment.centerLeft,
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Text('Crear cuenta', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 6),
                      Text(
                        'Empieza a publicar campañas o a probar apps en minutos.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppCard(
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _name,
                              label: 'Nombre',
                              prefixIcon: Icons.person_outline_rounded,
                              validator: (v) =>
                                  v == null || v.trim().length < 2 ? 'Nombre requerido' : null,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            CustomTextField(
                              controller: _email,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.mail_outline_rounded,
                              validator: (v) =>
                                  v == null || !v.contains('@') ? 'Email inválido' : null,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            CustomTextField(
                              controller: _password,
                              label: 'Contraseña',
                              obscureText: true,
                              prefixIcon: Icons.lock_outline_rounded,
                              validator: (v) =>
                                  v == null || v.length < 8 ? 'Mínimo 8 caracteres' : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _RoleTile(
                              selected: _asDeveloper,
                              title: 'Soy desarrollador',
                              subtitle: 'Publico apps y campañas de testing',
                              icon: Icons.code_rounded,
                              onTap: () => setState(() => _asDeveloper = !_asDeveloper),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            _RoleTile(
                              selected: _asTester,
                              title: 'Quiero ser tester',
                              subtitle: 'Me uno a campañas y gano TestCredits',
                              icon: Icons.phone_android_rounded,
                              onTap: () => setState(() => _asTester = !_asTester),
                            ),
                            if (auth.error != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                auth.error!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            PrimaryButton(
                              label: 'Registrarme',
                              loading: auth.loading,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Ya tengo cuenta'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySoft : const Color(0xFFF7F8FB),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.inkMuted),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? AppColors.primary : AppColors.inkFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
