import 'package:flutter/material.dart';
import 'package:sona/application/common/utils/dialogs.dart';
import 'package:sona/application/widgets/full_state_widget.dart';
import 'package:sona/application/widgets/sized_text_button.dart';
import 'package:sona/application/common/auth/users.dart' as users;

import '../widgets/loading_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends FullState<SignUpPage> {
  //
  late final _signupState = fetchState(users.signup);

  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  var _obscurePassword = true;
  var _obscureConfirmPassword = true;

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
                children: <Widget>[
                  Image.asset('assets/images/logo.png', width: MediaQuery.of(context).size.height * 0.3),
                  const SizedBox(height: 30),
                  _buildForm(),
                  const SizedBox(height: 30),
                  const Text(
                    '¿Ya tienes cuenta?',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedTextbutton(
                    'Ingresar',
                    onPressed: Navigator.of(context).pop,
                    height: 30,
                  ),
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
            controller: _firstNameController,
            enabled: !_signupState.isLoading,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _lastNameController,
            enabled: !_signupState.isLoading,
            decoration: const InputDecoration(
              labelText: 'Apellido',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _userNameController,
            enabled: !_signupState.isLoading,
            decoration: const InputDecoration(
              labelText: 'Nombre de usuario',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            enabled: !_signupState.isLoading,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            enabled: !_signupState.isLoading,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: _togglePasswordVisibility,
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _confirmPasswordController,
            enabled: !_signupState.isLoading,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: _toggleConfirmPasswordVisibility,
                icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
              ),
            ),
          ),
          const SizedBox(height: 30),
          LoadingButton(
            icon: const Icon(Icons.person_add),
            onPressed: _singUp,
            loading: _signupState.isLoading,
            child: const Text(
              'Registrarse',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _singUp() async {
    if (!_formKey.currentState!.validate()) return;

    await _signupState.fetch(
      null,
      {
        #username: _userNameController.text,
        #password: _passwordController.text,
        #firstName: _firstNameController.text,
        #lastName: _lastNameController.text,
        #email: _emailController.text,
      },
    );

    if (_signupState.hasError) {
      showAlertErrorDialog(this, _signupState.error!);
      return;
    }

    showAlertDialog(
      title: 'Registro Exitoso',
      message: _signupState.data!.message,
      actions: {'Aceptar': () => Navigator.of(context).pushReplacementNamed('/login')},
    );
  }

  void _togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    refresh();
  }

  void _toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    refresh();
  }
}
