import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/user.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/errors.dart';
import 'package:sona/shared/schemas/page.dart';
import 'package:sona/shared/utils/deboucing.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/utils/paging.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends FullState<ChatScreen> {
  final _controller = PageController();
  var _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          _currentPage = index;
          refresh();
        },
        children: const [
          ChatsPageView(),
          UsersPageView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Usuarios',
          ),
        ],
        onTap: (index) {
          _controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          _currentPage = index;
          refresh();
        },
      ),
    );
  }
}

class ChatsPageView extends StatefulWidget {
  const ChatsPageView({super.key});

  @override
  State<ChatsPageView> createState() => _ChatsPageViewState();
}

class _ChatsPageViewState extends State<ChatsPageView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class UsersPageView extends StatefulWidget {
  const UsersPageView({super.key});

  @override
  State<UsersPageView> createState() => _UsersPageViewState();
}

final Map<Authority, dynamic> rolesData = {
  Authority.admin: {
    'name': 'Administrador',
    'icon': Icons.admin_panel_settings,
  },
  Authority.administrative: {
    'name': 'Administrativo',
    'icon': Icons.business,
  },
  Authority.professional: {
    'name': 'Profesional',
    'icon': Icons.book,
  },
  Authority.user: {
    'name': 'Usuario',
    'icon': Icons.person,
  },
};

class _UsersPageViewState extends FullState<UsersPageView> {
  //
  final _chatService = injector.get<ChatService>();
  final _usersService = injector.get<UserService>();
  final _pagingController = PagingQueryController<User>(firstPage: 0);
  final _searchController = TextEditingController();

  late final _profile = fetchState(([positionalArguments, namedArguments]) => _usersService.profile());

  Authority? _role;

  @override
  void initState() {
    super.initState();
    _profile.fetch();
    _pagingController.configureFetcher(_fetchPage);
    _searchController.addListener(_search());
  }

  void Function() _search() {
    return Debouncing.build(
      const Duration(milliseconds: 500),
      () => _pagingController.search(_searchController.text),
    );
  }

  Future<Page<User>> _fetchPage([PageQuery? query]) async {
    return _role != null ? _usersService.pageByRole(_role!, query) : _usersService.page(query);
  }

  @override
  Widget build(BuildContext context) {
    return _profile.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error) => Center(child: Text(extractError(error).message)),
      initial: () => const SizedBox(),
      data: (profile) => Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          Expanded(child: _buildListUsers(profile)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar usuario',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(onPressed: _openFilterSettings, icon: const Icon(Icons.settings)),
      ),
    );
  }

  Widget _buildListUsers(User profile) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(_pagingController.refresh),
      child: PagedListView<int, User>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<User>(
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('No se encontraron usuarios')),
          itemBuilder: (context, user, index) {
            if (user.id == profile.id) return const SizedBox();
            final representation = user.representation;
            return ListTile(
              title: Text('${representation.firstName} ${representation.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('@${representation.username}'),
              leading: CircleAvatar(
                backgroundImage: user.profilePicturePath != null ? NetworkImage(user.profilePicturePath!) : null,
                child: Text(representation.firstName[0]),
              ),
              trailing: IconButton(
                color: Theme.of(context).primaryColor,
                icon: const Icon(Icons.chat),
                onPressed: _openChat(context, user),
              ),
            );
          },
        ),
      ),
    );
  }

  _openChat(BuildContext context, User user) {
    return () {
      AutoRouter.of(context).push(ChatRoomRoute(owner: _profile.data!, getRoom: () => _chatService.room(userId: user.id)));
    };
  }

  void _openFilterSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ListTile(
                title: const Text('Todos'),
                leading: const Icon(Icons.group),
                onTap: () {
                  _role = null;
                  _pagingController.refresh();
                  Navigator.pop(context);
                },
              ),
              ...rolesData.entries.map((entry) {
                final role = entry.key;
                final data = entry.value;
                return ListTile(
                  title: Text(data['name']),
                  leading: Icon(data['icon']),
                  onTap: () {
                    _role = role;
                    _pagingController.refresh();
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
