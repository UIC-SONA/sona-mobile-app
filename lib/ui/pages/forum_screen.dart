import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/schemas/direction.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/utils/helpers/post_service_widget_helper.dart';
import 'package:sona/ui/utils/helpers/user_service_widget_helper.dart';
import 'package:sona/ui/utils/paging.dart';

import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/post_paged_list.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

import '../theme/icons.dart';

@RoutePage()
class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends FullState<ForumScreen> with UserServiceWidgetHelper, PostServiceWidgetHelper {
  @override
  final userService = injector.get<UserService>();
  @override
  final postService = injector.get<PostService>();
  final storage = injector.get<FlutterSecureStorage>();
  final pagingController = PagingQueryController<PostWithUser>(firstPage: 0);

  @override
  void initState() {
    super.initState();
    pagingController.configurePageRequestListener(_loadPagePostWithUser);
    tryImportantMessage();
  }

  Future<List<PostWithUser>> _loadPagePostWithUser(int page) async {
    final result = await pagePostWithUser(PageQuery(
      page: page,
      sort: [
        Sort('createdAt', Direction.desc),
      ],
    ));
    return result.content;
  }

  Future<void> tryImportantMessage() async {
    final currentUser = userService.currentUser;
    final message = await storage.read(key: 'notShowImportantMessage:$currentUser') == 'true';
    if (!mounted) return;
    if (!message) {
      final showAgain = await showImportantMessage(context);
      if (showAgain == true) {
        await storage.write(key: 'notShowImportantMessage:$currentUser', value: 'true');
      }
    }
  }

  Future<bool?> showImportantMessage(BuildContext context) async {
    bool doNotShowAgain = false; // Estado del checkbox

    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('IMPORTANTE',
            style: TextStyle(fontWeight: FontWeight.bold),),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del contenido para evitar el desbordamiento
            children: [
              const Text('Este foro es un espacio de apoyo y respeto mutuo. No se permitirán insultos, acoso, contenido discriminatorio o comentarios ofensivos de ningún tipo. Las publicaciones que no cumplan con estas normas serán eliminadas y los usuarios pueden ser sancionados.',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 14),),
              const SizedBox(height: 12), // Espacio entre el texto y el checkbox
              Row(
                children: [
                  StatefulBuilder(builder: (context, setState) {
                    return Checkbox(
                      value: doNotShowAgain,
                      onChanged: (value) {
                        setState(() {
                          doNotShowAgain = value ?? false;
                        });
                      },
                    );
                  }),
                  Expanded(
                    // Esto permite que el texto se ajuste al espacio disponible
                    child: Text(
                      'No mostrar este mensaje de nuevo',
                      softWrap: true, // Ajusta el texto al tamaño del contenedor
                      style: TextStyle(fontSize: 12), // Texto más pequeño
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(doNotShowAgain); // Devuelve el estado del checkbox
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: PostListView(controller: pagingController),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.router.push(const ForumNewPostRoute());
          pagingController.refresh();
        },
        child: Icon(SonaIcons.plusSquare),
      ),
    );
  }
}
