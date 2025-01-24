import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/user.dart';
import 'package:sona/shared/validation/forms.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/theme/backgrounds.dart';
import 'package:sona/ui/theme/colors.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/widgets/loading_button.dart';
import 'package:sona/ui/widgets/sized_text_button.dart';

@RoutePage()
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final userService = injector.get<UserService>();
  final formKey = GlobalKey<FormBuilderState>();

  var _isLoading = false;
  var _obscurePassword = true;
  var _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        gradient: bgGradientLight,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/logo.png',
                      width: MediaQuery.of(context).size.height * 0.3,
                    ),
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
    return FormBuilder(
      key: formKey,
      child: Column(
        children: [
          FormBuilderTextField(
            name: 'firstName',
            decoration: const InputDecoration(
              labelText: 'Nombre',
              prefixIcon: Icon(Icons.person),
            ),
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 10),
          FormBuilderTextField(
            name: 'lastName',
            decoration: const InputDecoration(
              labelText: 'Apellido',
              prefixIcon: Icon(Icons.person),
            ),
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 10),
          FormBuilderTextField(
            name: 'username',
            decoration: const InputDecoration(
              labelText: 'Nombre de usuario',
              prefixIcon: Icon(Icons.person),
            ),
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 10),
          FormBuilderTextField(
            name: 'email',
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.email(),
            ]),
          ),
          const SizedBox(height: 10),
          FormBuilderTextField(
            name: 'password',
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: _togglePasswordVisibility,
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: FormBuilderValidators.password(
              checkNullOrEmpty: true,
              minLength: 6,
              minLowercaseCount: 1,
              minUppercaseCount: 1,
              minSpecialCharCount: 1,
              minNumberCount: 1,
            ),
          ),
          const SizedBox(height: 10),
          FormBuilderTextField(
            name: 'confirmPassword',
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: _toggleConfirmPasswordVisibility,
                icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: (value) {
              if (value != formKey.currentState?.fields['password']?.value) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          LoadingButton(
            icon: const Icon(Icons.person_add),
            onPressed: _signUp,
            loading: _isLoading,
            child: const Text(
              'Registrarse',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    if (!formKey.currentState!.saveAndValidate()) return;
    setState(() => _isLoading = true);

    final formData = formKey.currentState!.value;

    try {
      final message = await userService.signUp(
        username: formData['username'],
        password: formData['password'],
        firstName: formData['firstName'],
        lastName: formData['lastName'],
        email: formData['email'],
      );

      if (!mounted) return;

      showAlertDialog(
        context,
        title: 'Registro Exitoso',
        message: message.message,
        actions: {
          'Aceptar': () => AutoRouter.of(context).replace(const LoginRoute()),
        },
      );
    } catch (error) {
      formStateInvalidator(context, formState: formKey.currentState!, error: error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
  }
}
