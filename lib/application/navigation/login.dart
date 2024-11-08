import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sona/application/common/utils/full_state_widget.dart';
import 'package:sona/application/common/auth/oauth2.dart' as oauth2;
import 'package:sona/application/widgets/loading_button.dart';
import 'package:sona/application/widgets/sized_text_button.dart';

final _log = Logger();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends FullState<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();

  var _loading = false;
  var _obscurePasswordText = true;

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', width: MediaQuery.of(context).size.height * 0.3),
                  const SizedBox(height: 30),
                  _buildForm(),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
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
              enabled: !_loading,
              prefixIcon: const Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePasswordText,
            enabled: !_loading,
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
            onPressed: _login,
            loading: _loading,
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
          enabled: !_loading,
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
          enabled: !_loading,
        ),
      ],
    );
  }

  Future<void> _login() async {
    _log.d('Logging in...');
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      _loading = true;
      refresh();

      final email = _emailOrUsernameController.text;
      final password = _passwordController.text;

      await oauth2.authenticate(email, password);

      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (error, stackTrace) {
      _log.e('Error while logging in: $error', error: error, stackTrace: stackTrace);
      final message = error.toString();
      if (message.contains('invalid_grant')) {
        showAlertDialog(title: 'Error', message: 'Credenciales inválidas');
      } else {
        showAlertDialog(title: 'Error', message: message);
      }
    } finally {
      _loading = false;
      refresh();
    }
  }

  void _togglePasswordVisibility() {
    _obscurePasswordText = !_obscurePasswordText;
    refresh();
  }
}
