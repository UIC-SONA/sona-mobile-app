import 'package:auto_route/annotations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/validation/forms.dart';
import 'package:sona/ui/theme/icons.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/widgets/loading_button.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

@RoutePage()
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _userService = injector.get<UserService>();
  final _formKey = GlobalKey<FormBuilderState>();

  var _isLoading = false;
  var _obscurePassword = true;
  var _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cambiar Contraseña',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FormBuilderTextField(
                name: 'newPassword',
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: Icon(SonaIcons.padlock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? SonaIcons.eye : SonaIcons.eyeOff,
                    ),
                    onPressed: () => setState(() {
                      _obscurePassword = !_obscurePassword;
                    }),
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
              const SizedBox(height: 20),
              FormBuilderTextField(
                name: 'confirmNewPassword',
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  prefixIcon: Icon(SonaIcons.padlock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? SonaIcons.eye : SonaIcons.eyeOff,
                    ),
                    onPressed: () => setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    }),
                  ),
                ),
                validator: (value) {
                  final password = _formKey.currentState?.fields['newPassword']?.value;
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirma tu contraseña.';
                  }
                  if (value != password) {
                    return 'Las contraseñas no coinciden.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  onPressed: _changePassword,
                  loading: _isLoading,
                  child: const Text(
                    'Cambiar Contraseña',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.saveAndValidate()) return;
    final FormBuilderState formState = _formKey.currentState!;

    final formData = formState.value;
    final newPassword = formData['newPassword'] as String;

    setState(() => _isLoading = true);

    try {
      final message = await _userService.changePassword(newPassword: newPassword);
      if (!mounted) return;

      showAlertDialog(
        context,
        title: 'Contraseña Cambiada',
        message: message.message,
      );

      formState.reset();
    } catch (error) {
      formStateInvalidator(context, formState: formState, error: error);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
