import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Page;
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
  final pagingController = PagingQueryController<PostWithUser>(firstPage: 0);

  @override
  void initState() {
    super.initState();
    pagingController.configurePageRequestListener(_loadPagePostWithUser);
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

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: const Text(
          'Foro',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
