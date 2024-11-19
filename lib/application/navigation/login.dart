import 'package:flutter/material.dart';
import 'package:sona/application/common/utils/dialogs.dart';
import 'package:sona/application/widgets/full_state_widget.dart';
import 'package:sona/application/common/auth/oauth2.dart' as oauth2;
import 'package:sona/application/theme/backgrounds.dart';
import 'package:sona/application/theme/colors.dart';
import 'package:sona/application/widgets/loading_button.dart';
import 'package:sona/application/widgets/sized_text_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends FullState<LoginPage> {
  //
  late final _loginState = fetchState(oauth2.authenticate);

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

                  //final double scrollPercent = ((constraints.maxHeight - kToolbarHeight) / (height - kToolbarHeight)).clamp(0.0, 1.0);
                  // final double textOpacity = (1 - scrollPercent).clamp(0.0, 1.0);

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
              enabled: !_loginState.isLoading,
              prefixIcon: const Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePasswordText,
            enabled: !_loginState.isLoading,
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
            onPressed: _login,
            loading: _loginState.isLoading,
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
          enabled: !_loginState.isLoading,
        ),
        const SizedBox(height: 10),
        const Text(
          '¿No tienes cuenta?',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        SizedTextbutton(
          'Crear cuenta',
          onPressed: () => Navigator.of(context).pushNamed('/register'),
          height: 30,
          enabled: !_loginState.isLoading,
        ),
      ],
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailOrUsernameController.text;
    final password = _passwordController.text;

    await _loginState.fetch([email, password]);

    if (_loginState.hasError) {
      final error = _loginState.error!;
      final message = error.toString();
      if (message.contains('invalid_grant')) {
        showAlertDialog(title: 'Error', message: 'Credenciales inválidas');
      } else {
        showAlertErrorDialog(this, error);
      }
      return;
    }

    if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  void _togglePasswordVisibility() {
    _obscurePasswordText = !_obscurePasswordText;
    refresh();
  }
}
