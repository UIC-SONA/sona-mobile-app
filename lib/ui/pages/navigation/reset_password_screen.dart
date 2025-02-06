import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/theme/backgrounds.dart';
import 'package:sona/ui/theme/colors.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/widgets/loading_button.dart';

import '../../theme/icons.dart';

@RoutePage()
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final userService = injector.get<UserService>();
  final formKey = GlobalKey<FormBuilderState>();
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        gradient: bgGradientLight,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: FormBuilder(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recuperar Contraseña',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  name: 'emailOrUsername',
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico o nombre de usuario',
                    prefixIcon: Icon(SonaIcons.messageCard),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(3),
                  ]),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: LoadingButton(
                    onPressed: _resetPassword,
                    loading: _isLoading,
                    child: const Text('Recuperar contraseña'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (!formKey.currentState!.saveAndValidate()) {
      return;
    }

    final formData = formKey.currentState!.value;
    final emailOrUsername = formData['emailOrUsername'];

    setState(() => _isLoading = true);
    try {
      final message = await userService.resetPassword(emailOrUsername: emailOrUsername);
      if (!mounted) return;
      showAlertDialog(
        context,
        title: 'Éxito',
        message: message.message,
      );
    } catch (e) {
      showAlertErrorDialog(context, error: e);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
