import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) =>
                          v == null || v.trim().length < 2 ? 'Nombre requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) =>
                          v == null || !v.contains('@') ? 'Email inválido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      validator: (v) =>
                          v == null || v.length < 8 ? 'Mínimo 8 caracteres' : null,
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: _asDeveloper,
                      onChanged: (v) => setState(() => _asDeveloper = v ?? false),
                      title: const Text('Soy desarrollador'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: _asTester,
                      onChanged: (v) => setState(() => _asTester = v ?? false),
                      title: const Text('Quiero ser tester'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (auth.error != null)
                      Text(
                        auth.error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: auth.loading ? null : _submit,
                      child: const Text('Registrarme'),
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
    );
  }
}
