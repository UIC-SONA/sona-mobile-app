import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/user.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/theme/backgrounds.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/loading_button.dart';
import 'package:sona/ui/widgets/sized_text_button.dart';

@RoutePage()
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends FullState<SignUpScreen> {
  //
  final UserService userService = injector.get<UserService>();

  late final _signUpState = fetchState(([positionalArguments, namedArguments]) => userService.signUp(
        username: namedArguments![#username],
        password: namedArguments[#password],
        firstName: namedArguments[#firstName],
        lastName: namedArguments[#lastName],
        email: namedArguments[#email],
      ));

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
      body: Background(
        child: SafeArea(
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
                      onPressed: AutoRouter.of(context).back,
                      height: 30,
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

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _firstNameController,
            enabled: !_signUpState.isLoading,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _lastNameController,
            enabled: !_signUpState.isLoading,
            decoration: const InputDecoration(
              labelText: 'Apellido',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _userNameController,
            enabled: !_signUpState.isLoading,
            decoration: const InputDecoration(
              labelText: 'Nombre de usuario',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            enabled: !_signUpState.isLoading,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            enabled: !_signUpState.isLoading,
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
            enabled: !_signUpState.isLoading,
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
            loading: _signUpState.isLoading,
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

    await _signUpState.fetch(
      null,
      {
        #username: _userNameController.text,
        #password: _passwordController.text,
        #firstName: _firstNameController.text,
        #lastName: _lastNameController.text,
        #email: _emailController.text,
      },
    );

    if (_signUpState.hasError) {
      showAlertErrorDialog(this, error: _signUpState.error!, errorDetailExtractor: httpErrorDetailExtractor);
      return;
    }

    showAlertDialog(
      title: 'Registro Exitoso',
      message: _signUpState.data!.message,
      actions: {'Aceptar': () => AutoRouter.of(context).replace(const LoginRoute())},
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
