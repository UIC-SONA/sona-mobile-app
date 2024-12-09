import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/theme/backgrounds.dart';
import 'package:sona/ui/theme/colors.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/loading_button.dart';
import 'package:sona/ui/widgets/sized_text_button.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends FullState<LoginScreen> {
  final AuthProvider _authProvider = injector.get<AuthProvider>();

  late final _login = fetchState(([positionalArguments, namedArguments]) => _authProvider.login(
        positionalArguments![0],
        positionalArguments[1],
      ));

  final _formKey = GlobalKey<FormState>();

  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();

  var _obscurePasswordText = true;

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const radius = 25.0;
    const BorderRadius borderRadius = BorderRadius.only(
      topLeft: Radius.zero,
      topRight: Radius.zero,
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );

    final height = MediaQuery.of(context).size.height * 0.5;

    return Scaffold(
      body: Background(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 5,
              expandedHeight: height,
              collapsedHeight: 100,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final double imageSize = height * 0.6;
                  return Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: bgGradientMagenta, // Asegúrate de definir bgGradientMagenta
                          borderRadius: borderRadius,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 35, bottom: 10),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: imageSize,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Column(
                    children: [
                      const SizedBox(height: 25),
                      _userIcon(),
                      Padding(
                        padding: const EdgeInsets.all(25),
                        child: _buildForm(),
                      ),
                      _buildFooter(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userIcon() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 35),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailOrUsernameController,
            decoration: InputDecoration(
              labelText: 'Correo o usuario',
              enabled: !_login.isLoading,
              prefixIcon: const Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePasswordText,
            enabled: !_login.isLoading,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: _togglePasswordVisibility,
                icon: Icon(_obscurePasswordText ? Icons.visibility : Icons.visibility_off),
              ),
            ),
          ),
          const SizedBox(height: 30),
          LoadingButton(
            icon: const Icon(Icons.login),
            onPressed: _loginUser,
            loading: _login.isLoading,
            child: const Text(
              'Ingresar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const SizedBox(height: 30),
        const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        SizedTextbutton(
          'Recuperar contraseña',
          onPressed: () {},
          height: 30,
          enabled: !_login.isLoading,
        ),
        const SizedBox(height: 10),
        const Text(
          '¿No tienes cuenta?',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        SizedTextbutton(
          'Crear cuenta',
          onPressed: () => AutoRouter.of(context).push(const SignUpRoute()),
          height: 30,
          enabled: !_login.isLoading,
        ),
      ],
    );
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailOrUsernameController.text.trim();
    final password = _passwordController.text;

    await _login.fetch([email, password]);

    if (!mounted) return;

    if (_login.hasError) {
      final error = _login.error!;
      final message = error.toString();
      if (message.contains('invalid_grant')) {
        showAlertDialog(context, title: 'Error', message: 'Credenciales inválidas');
      } else {
        showAlertErrorDialog(context, error: error);
      }
      return;
    }

    if (mounted) {
      AutoRouter.of(context).replaceAll([const HomeRoute()]);
    }
  }

  void _togglePasswordVisibility() {
    _obscurePasswordText = !_obscurePasswordText;
    refresh();
  }
}
