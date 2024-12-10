import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logger/logger.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/errors.dart';
import 'package:sona/shared/http/http.dart';
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
  final _userService = injector.get<UserService>();
  final _controller = PageController();

  late final _currentPage = valueState(0);

  @override
  Widget build(BuildContext context) {
    final profile = _userService.currentUser;

    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: profile.authorities.contains(Authority.professional)
          ? ChatsPageView(profile: profile, controller: _controller)
          : PageView(
              controller: _controller,
              onPageChanged: (index) => _currentPage.value = index,
              children: [
                ChatsPageView(profile: profile, controller: _controller),
                UsersPageView(profile: profile),
              ],
            ),
      bottomNavigationBar: profile.authorities.contains(Authority.professional)
          ? null
          : BottomNavigationBar(
              currentIndex: _currentPage.value!,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
              ],
              onTap: (index) {
                _controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                _currentPage.value = index;
              },
            ),
    );
  }
}

class _ChatRoomDataNotifier extends ChangeNotifier {
  final Map<String, ChatRoomData> _roomsData = {};

  List<ChatRoomData> get roomsData => _roomsData.values.toList()
    ..sort((a, b) {
      final createdAtA = a.lastMessage?.createdAt;
      final createdAtB = b.lastMessage?.createdAt;
      if (createdAtA == null || createdAtB == null) return 0;
      return createdAtB.compareTo(createdAtA);
    });

  void addRooms(List<ChatRoomData> rooms) {
    for (var room in rooms) {
      _roomsData[room.id] = room;
    }
    notifyListeners();
  }

  void addRoom(ChatRoomData room) {
    if (!_roomsData.containsKey(room.id)) {
      _roomsData[room.id] = room;
      notifyListeners();
    }
  }

  void updateRoomLastMessage(String roomId, ChatMessage message) {
    if (_roomsData.containsKey(roomId)) {
      final updatedRoom = _roomsData[roomId]!.copyWith(lastMessage: message);
      _roomsData[roomId] = updatedRoom;
      notifyListeners();
    }
  }

  bool exists(String roomId) => _roomsData.containsKey(roomId);

  void clearRooms() {
    _roomsData.clear();
    notifyListeners();
  }
}

class ChatsPageView extends StatefulWidget {
  final PageController controller;
  final User profile;

  const ChatsPageView({super.key, required this.controller, required this.profile});

  @override
  State<ChatsPageView> createState() => _ChatsPageViewState();
}

final Logger _log = Logger();

abstract class _ChatRoomHelperState<T extends StatefulWidget> extends FullState<T> with AutomaticKeepAliveClientMixin {
  //
  final _cacheUsers = <int, User>{};

  @override
  bool get wantKeepAlive => true;

  @protected
  ChatService get chatService;

  @protected
  UserService get userService;

  @protected
  User get profile;

  void cacheUser(User user) {
    _cacheUsers[user.id] = user;
  }

  Future<ChatRoomData> createRoomData(ChatRoom room) async {
    //
    final participants = <User>[];
    for (final userId in room.participants) {
      if (userId == profile.id) continue;
      participants.add(await getUser(userId));
    }

    final lastMessage = await chatService.lastMessage(roomId: room.id);
    return ChatRoomData(
      room: room,
      participants: participants,
      lastMessage: lastMessage,
    );
  }

  Future<User> getUser(int userId) async {
    return _cacheUsers[userId] ??= await onNotFound<User>(
      fetch: () => userService.find(userId),
      onNotFound: () => UserService.notFound,
    );
  }
}

class _ChatsPageViewState extends _ChatRoomHelperState<ChatsPageView> with ChatMessageListenner<ChatService> {
  //
  late final _chatService = injector.get<ChatService>();
  late final _userService = injector.get<UserService>();
  late final _room = fetchState(([positionalArguments, namedArguments]) => _chatService.rooms());
  late final _loading = loadingState(false);

  final _chatRoomNotifier = _ChatRoomDataNotifier();

  @override
  User get profile => widget.profile;

  @override
  ChatService get chatService => _chatService;

  @override
  UserService get userService => _userService;

  @override
  void initState() {
    super.initState();
    _chatRoomNotifier.addListener(refresh);
    loadData();
    initMessageListeners();
  }

  @override
  void dispose() {
    disposeMessageListeners();
    _chatRoomNotifier.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    await _loading.run(() async {
      _cacheUsers.clear();

      await _room.fetch();
      final rooms = _room.value!;

      final usersIds = rooms.expand((room) => room.participants).toSet().where((userId) => userId != profile.id).toList();

      final users = await _userService.findMany(usersIds);
      if (users.length != usersIds.length) _log.w("Not all users were found");

      users.forEach(cacheUser);

      final roomStates = await Future.wait(rooms.map(createRoomData));
      _chatRoomNotifier.clearRooms();
      _chatRoomNotifier.addRooms(roomStates);
    });
  }

  @override
  void onReceiveMessage(ChatMessageSent messageSent) async {
    if (!mounted) return;
    final message = messageSent.message;
    final roomId = messageSent.roomId;

    if (_chatRoomNotifier.exists(roomId)) {
      _chatRoomNotifier.updateRoomLastMessage(roomId, message);
      return;
    }

    final room = await _chatService.room(roomId: messageSent.roomId);
    final roomState = await createRoomData(room);
    _chatRoomNotifier.addRoom(roomState);
  }

  @override
  void onReadMessage(ReadMessages readMessages) async {
    if (!mounted) return;
    final roomId = readMessages.roomId;
    final messageIds = readMessages.messageIds;
    final readBy = readMessages.readBy;

    if (_chatRoomNotifier.exists(roomId)) {
      final room = _chatRoomNotifier.roomsData.firstWhere((room) => room.id == roomId);
      final messages = room.lastMessage;

      if (messages != null) {
        final set = messageIds.toSet();
        if (!set.contains(messages.id)) return;

        if (messages.readBy.any((readBy) => readBy.participantId == readBy.participantId)) return;
        messages.readBy.add(readBy);
        _chatRoomNotifier.updateRoomLastMessage(roomId, messages);
      }
    }

    final room = await _chatService.room(roomId: roomId);
    final roomState = await createRoomData(room);
    _chatRoomNotifier.addRoom(roomState);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FullState.whenAll(
      [_room, _loading],
      loading: () => const Center(child: CircularProgressIndicator()),
      initial: () => const SizedBox(),
      error: (error) => Center(child: Text(extractError(error).message)),
      data: (data) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final roomsData = _chatRoomNotifier.roomsData;

    if (roomsData.isEmpty) {
      return _buildNoMessages();
    }

    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView.builder(
        itemCount: roomsData.length,
        itemBuilder: (context, index) {
          final roomData = roomsData[index];

          return Column(
            children: [
              TextButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
                ),
                onPressed: () {
                  AutoRouter.of(context).push(
                    ChatRoomRoute(
                      owner: profile,
                      room: roomData,
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  title: _buildTitle(roomData, profile),
                  subtitle: _buildSubtitle(roomData, profile),
                  leading: _buildLeading(roomData, profile),
                  trailing: _buildTrailing(roomData, profile),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay mensajes aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600], // Color del texto principal.
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Empieza una conversación con alguien\npara ver los mensajes aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500], // Color secundario para la descripción.
            ),
          ),
          const SizedBox(height: 20),
          profile.authorities.contains(Authority.professional)
              ? const Text('¡Espere a que alguien inicie una conversación con usted!')
              : FilledButton.icon(
                  onPressed: () {
                    widget.controller.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('¡Comienza una conversación!'),
                  iconAlignment: IconAlignment.start,
                ),
        ],
      ),
    );
  }

  Widget _buildTitle(ChatRoomData room, User profile) {
    return Text(
        switch (room.room.type) {
          ChatRoomType.group => room.room.name,
          ChatRoomType.private => room.participants.first.representation.fullName,
        },
        style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _buildSubtitle(ChatRoomData room, User profile) {
    var lastMessage = room.lastMessage;
    if (lastMessage == null) return const SizedBox();
    return SizedBox(
      width: 250.0, // Ancho fijo para el subtítulo
      child: Text(
        lastMessage.sentBy == profile.id ? 'Tú: ${lastMessage.message}' : lastMessage.message,
        style: const TextStyle(color: Colors.grey),
        overflow: TextOverflow.ellipsis, // Trunca el texto si es demasiado largo
        maxLines: 1, // Solo una línea
      ),
    );
  }

  Widget _buildLeading(ChatRoomData state, User profile) {
    final room = state.room;
    if (room.type == ChatRoomType.group) {
      return const Icon(Icons.group);
    }
    final participant = state.participants.firstWhere((user) => user.id != profile.id);
    return _buildAvatar(participant);
  }

  Widget _buildTrailing(ChatRoomData roomData, User profile) {
    final lastMessage = roomData.lastMessage;
    if (lastMessage == null) return const SizedBox();
    if (lastMessage.sentBy == profile.id) return const Icon(Icons.chevron_right, color: Colors.grey);

    final readBy = lastMessage.readBy.map((readBy) => readBy.participantId).toList();

    final isRead = readBy.contains(profile.id);
    return Icon(
      isRead ? Icons.chevron_right : Icons.info,
      color: isRead ? Colors.grey : Theme.of(context).primaryColor,
    );
  }
}

class UsersPageView extends StatefulWidget {
  final User profile;

  const UsersPageView({super.key, required this.profile});

  @override
  State<UsersPageView> createState() => _UsersPageViewState();
}

class _UsersPageViewState extends _ChatRoomHelperState<UsersPageView> {
  final _chatService = injector.get<ChatService>();
  final _userService = injector.get<UserService>();
  final _pagingController = PagingQueryController<User>(firstPage: 0);
  final _searchController = TextEditingController();

  Authority _role = Authority.professional;

  @override
  ChatService get chatService => _chatService;

  @override
  UserService get userService => _userService;

  @override
  User get profile => widget.profile;

  @override
  void initState() {
    super.initState();
    _pagingController.configureFetcher(_fetchPage);
    _searchController.addListener(Debouncing.build(const Duration(milliseconds: 500), () => _pagingController.search(_searchController.text)));
  }

  Future<Page<User>> _fetchPage([PageQuery? query]) async {
    return _userService.pageByRole(_role, query);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 20),
        Expanded(child: _buildListUsers()),
      ],
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

  Widget _buildListUsers() {
    return RefreshIndicator(
      onRefresh: () => Future.sync(_pagingController.refresh),
      child: PagedListView<int, User>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<User>(
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('No se encontraron usuarios')),
          firstPageErrorIndicatorBuilder: (context) {
            final error = extractError(_pagingController.error);
            final title = error.title;
            final message = error.message;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title),
                  const SizedBox(height: 10),
                  Text(message),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pagingController.refresh,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          },
          itemBuilder: (context, user, index) {
            if (user.id == profile.id) return const SizedBox();
            final representation = user.representation;
            return TextButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
              ),
              onPressed: () => _openChat(user),
              child: ListTile(
                title: Text(
                  '${representation.firstName} ${representation.lastName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('@${representation.username}'),
                leading: _buildAvatar(user),
                trailing: Icon(Icons.chat, color: Theme.of(context).primaryColor),
              ),
            );
          },
        ),
      ),
    );
  }

  _openChat(User user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final roomData = await createRoomData(await _chatService.room(userId: user.id));

      if (!mounted) return;
      Navigator.of(context).pop();
      AutoRouter.of(context).push(
        ChatRoomRoute(
          owner: profile,
          room: roomData,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractError(error).message)),
      );
      rethrow;
    }
  }

  void _openFilterSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ListTile(
              //   title: const Text('Todos'),
              //   leading: const Icon(Icons.group),
              //   onTap: () {
              //     _role = null;
              //     _pagingController.refresh();
              //     Navigator.pop(context);
              //   },
              // ),
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

Widget _buildAvatar(User user) {
  final representation = user.representation;
  return CircleAvatar(
    backgroundImage: user.profilePicturePath != null ? NetworkImage(user.profilePicturePath!) : null,
    child: Text(representation.firstName[0]),
  );
}

final Map<Authority, dynamic> rolesData = {
  // Authority.admin: {
  //   'name': 'Administrador',
  //   'icon': Icons.admin_panel_settings,
  // },
  // Authority.administrative: {
  //   'name': 'Administrativo',
  //   'icon': Icons.business,
  // },
  Authority.professional: {
    'name': 'Todos los profesionales',
    'icon': Icons.business,
  },
  Authority.medicalProfessional: {
    'name': 'Profesional médico',
    'icon': Icons.medical_services,
  },
  Authority.legalProfessional: {
    'name': 'Profesional legal',
    'icon': Icons.gavel,
  },
  // Authority.user: {
  //   'name': 'Usuario',
  //   'icon': Icons.person,
  // },
};
