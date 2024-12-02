import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/user.dart';
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
          MyChatsPageView(),
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

class MyChatsPageView extends StatefulWidget {
  const MyChatsPageView({super.key});

  @override
  State<MyChatsPageView> createState() => _MyChatsPageViewState();
}

class _MyChatsPageViewState extends State<MyChatsPageView> {
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

class _UsersPageViewState extends FullState<UsersPageView> {
  final _userService = injector.get<UserService>();
  late final _usersState = fetchState(([positionalArguments, namedArguments]) => _userService.list());

  @override
  void initState() {
    super.initState();
    _usersState.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return _usersState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      initial: () => Container(),
      error: (error) => Center(child: Text(error.toString())),
      data: (users) => RefreshIndicator(
        onRefresh: _usersState.fetch,
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final representation = user.representation;

            return ListTile(
              title: Text('${representation.firstName} ${representation.lastName}'),
              subtitle: Text(representation.username),
              leading: CircleAvatar(
                backgroundImage: user.profilePicturePath != null ? NetworkImage(user.profilePicturePath!) : null,
              ),
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}

class BottomChatField extends StatefulWidget {
  const BottomChatField({super.key});

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attachment),
            onPressed: () {},
          ),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
