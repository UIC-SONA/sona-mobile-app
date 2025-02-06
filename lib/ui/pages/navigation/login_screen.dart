import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/validation/forms.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/theme/backgrounds.dart';
import 'package:sona/ui/theme/colors.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/loading_button.dart';
import 'package:sona/ui/widgets/sized_text_button.dart';

import '../../theme/icons.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

const invalidGrantError = 'OAuth authorization error (invalid_grant):';

class _LoginScreenState extends FullState<LoginScreen> {
  final authProvider = injector.get<AuthProvider>();
  final formKey = GlobalKey<FormBuilderState>();
  var _loading = false;
  var _obscurePasswordText = true;

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
        gradient: bgGradientLight,
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
                          gradient: bgGradientMagenta, // Define bgGradientMagenta
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
      child: Icon(SonaIcons.fillUser, color: Theme.of(context).primaryColor, size: 35),
    );
  }

  Widget _buildForm() {
    return FormBuilder(
      key: formKey,
      child: Column(
        children: [
          FormBuilderTextField(
            name: 'emailOrUsername',
            decoration: InputDecoration(
              labelText: 'Correo o usuario',
              enabled: !_loading,
              prefixIcon: Icon(SonaIcons.messageCard),
            ),
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 10),
          FormBuilderTextField(
            name: 'password',
            obscureText: _obscurePasswordText,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(SonaIcons.padlock),
              suffixIcon: IconButton(
                onPressed: _togglePasswordVisibility,
                icon: Icon(_obscurePasswordText ? SonaIcons.eye : SonaIcons.eyeOff),
              ),
            ),
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 30),
          LoadingButton(
            icon: const Icon(Icons.login),
            onPressed: _loginUser,
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
          onPressed: () => AutoRouter.of(context).push(const ResetPasswordRoute()),
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
          onPressed: () => AutoRouter.of(context).push(const SignUpRoute()),
          height: 30,
          enabled: !_loading,
        ),
      ],
    );
  }

  Future<void> _loginUser() async {
    if (!formKey.currentState!.saveAndValidate()) {
      return;
    }

    final formState = formKey.currentState!;

    setState(() => _loading = true);
    final formData = formState.value;
    final email = formData['emailOrUsername'];
    final password = formData['password'];

    try {
      await authProvider.login(email, password);
      final userService = injector.get<UserService>();
      await userService.refreshCurrentUser();
      final currentUser = userService.currentUser;
      if (!currentUser.authorities.contains(Authority.user)) {
        throw 'No tienes permisos para acceder a la aplicación';
      }

      if (mounted) {
        AutoRouter.of(context).replaceAll([const HomeRoute()]);
      }
    } catch (error) {
      if (!mounted) return;
      final message = error.toString();
      if (message.contains(invalidGrantError)) {
        final error = message.split(invalidGrantError)[1].trim();
        if (error == 'Invalid user credentials.') {
          showAlertDialog(context, title: 'Error', message: 'Usuario o contraseña incorrectos');
        } else {
          showAlertDialog(context, title: 'Error', message: error);
        }
      } else {
        formStateInvalidator(context, formState: formState, error: error);
      }
      setState(() => _loading = false);
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePasswordText = !_obscurePasswordText;
    });
  }
}
