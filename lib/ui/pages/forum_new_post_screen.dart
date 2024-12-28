import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/image_builder.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class ForumNewPostScreen extends StatefulWidget {
  const ForumNewPostScreen({super.key});

  @override
  State<ForumNewPostScreen> createState() => _ForumNewPostScreenState();
}

class _ForumNewPostScreenState extends FullState<ForumNewPostScreen> {
  final _postService = injector.get<ForumService>();
  final _userService = injector.get<UserService>();

  bool? _anonymous;

  final _controller = TextEditingController();

  bool get anonymous {
    if (_anonymous == null) {
      return _userService.currentUser.anonymous;
    }
    return _anonymous!;
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Input text area that expands
                      _Input(
                        controller: _controller,
                        enabled: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _confirmAnonymousOrVisible,
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(const EdgeInsets.all(10)),
                    ),
                    child: Text(anonymous ? 'Usuario' : 'Anónimo'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _createPost,
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(const EdgeInsets.all(10)),
                    ),
                    child: const Text('Publicar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      appBarTittle: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (anonymous) ...const [
            Icon(Icons.person),
            Text(
              "Anónimo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ] else ...[
            CircleAvatar(
              radius: 20,
              child: ImageBuilder(
                provider: _userService.profilePicture(),
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
              ),
            ),
            Text(
              _userService.currentUser.representation.username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
      padding: 0,
      showLeading: false,
    );
  }

  Future<void> _createPost() async {
    if (_controller.text.isEmpty) {
      showSnackBarError(context, 'El contenido no puede estar vacío');
      return;
    }

    _showLoadingDialog();
    try {
      var dto = ForumDto(anonymous: anonymous, content: _controller.text);
      await _postService.create(dto);
      if (!mounted) return;
      AutoRouter.of(context).popUntil((route) => route.settings.name == ForumRoute.name);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      showAlertErrorDialog(context, error: e);
      rethrow;
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: SizedBox(
            height: 100,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Publicando...'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmAnonymousOrVisible() async {
    showAlertDialog(
      context,
      title: anonymous ? '¿Quieres publicar como usuario?' : '¿Quieres publicar como anónimo?',
      message: anonymous ? 'Estás a punto de compartir contenido bajo tu nombre de usuario registrado. Tu identidad será visible para los demás usuarios.' : 'Este espacio garantiza la protección total de tu identidad. Toda la información que compartas aquí será completamente anonima.',
      actions: {
        'Cancelar': () => Navigator.of(context).pop(),
        'Aceptar': () {
          _anonymous = !anonymous;
          refresh();
          Navigator.of(context).pop();
        },
      },
    );
  }
}

class _Input extends StatefulWidget {
  final bool? enabled;
  final TextEditingController controller;

  const _Input({
    this.enabled,
    required this.controller,
  });

  @override
  State<_Input> createState() => _InputState();
}

class _InputState extends State<_Input> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: const InputDecoration(
        fillColor: Colors.transparent,
        filled: true,
        hintText: 'Escribe tu historia aquí...',
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
        focusColor: Colors.transparent,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
    );
  }
}
