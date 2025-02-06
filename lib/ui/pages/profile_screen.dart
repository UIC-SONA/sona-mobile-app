import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/schemas/direction.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/utils/helpers/post_service_widget_helper.dart';
import 'package:sona/ui/utils/helpers/user_service_widget_helper.dart';
import 'package:sona/ui/utils/paging.dart';
import 'package:sona/ui/widgets/post_paged_list.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with UserServiceWidgetHelper, PostServiceWidgetHelper {
  @override
  final userService = injector.get<UserService>();
  @override
  final postService = injector.get<PostService>();
  final pagingController = PagingQueryController<PostWithUser>(firstPage: 0);
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    clearUserCaches();
    pagingController.configurePageRequestListener(_loadPagePostWihtUser);
  }

  Future<List<PostWithUser>> _loadPagePostWihtUser(int page) async {
    final result = await pagePostWithUser(PageQuery(
      page: page,
      sort: [
        Sort('createdAt', Direction.desc),
      ],
      params: {
        'author': [userService.currentUser.id.toString()],
      },
    ));
    return result.content;
  }

  Future<void> _onEditProfilePicture() async {
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Opcional: Reducir calidad para optimizar la carga
      );

      if (!mounted || pickedFile == null) return;
      final filePath = pickedFile.path;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Editar Imagen',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Editar Imagen',
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      if (!mounted || croppedFile == null) return;

      showLoadingDialog(context);
      final message = await userService.uploadProfilePicture(croppedFile.path);
      await refreshCurrentUser();
      if (!mounted) return;
      showSnackBar(context, content: Text(message.message));
      Navigator.of(context).pop();
      setState(() {});
    } catch (e) {
      showSnackBarFromError(context, error: e);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = userService.currentUser;
    final radius = 60.0;

    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Stack(
                  children: [
                    buildProfilePicture(radius: radius),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: IconButton(
                          iconSize: 15,
                          color: Theme.of(context).primaryColor,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.white),
                          ),
                          onPressed: _onEditProfilePicture,
                          icon: const Icon(Icons.camera_alt),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '@${user.username}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 24),
                _buildInfoCard(
                  context: context,
                  title: 'Información Personal',
                  children: [
                    _buildInfoRow('Email', user.email),
                    _buildInfoRow('Nombre', user.fullName),
                  ],
                ),
                const SizedBox(height: 14),
                if (user.anonymous) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Usuario Anónimo'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                const Divider(),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Tus publicaciones',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
          PostSliverList(controller: pagingController),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Divider(color: Colors.grey[300]),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
