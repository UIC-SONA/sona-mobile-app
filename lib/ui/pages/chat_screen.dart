import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/errors.dart';
import 'package:sona/shared/utils/deboucing.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/utils/helpers/chat_service_widget_helper.dart';
import 'package:sona/ui/utils/helpers/user_service_widget_helper.dart';
import 'package:sona/ui/utils/paging.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/professional_botton_sheet.dart';
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

  var _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final profile = _userService.currentUser;
    final isProfessional = profile.authorities.any((authority) => professionalAuthorities.contains(authority));

    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: isProfessional
          ? ChatsPageView(controller: _controller)
          : PageView(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                ChatsPageView(controller: _controller),
                UsersPageView(),
              ],
            ),
      bottomNavigationBar: isProfessional
          ? null
          : BottomNavigationBar(
              currentIndex: _currentPage,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Profesionales'),
              ],
              onTap: (index) {
                _controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _currentPage = index);
              },
            ),
    );
  }
}

class ChatsPageView extends StatefulWidget {
  final PageController controller;

  const ChatsPageView({
    super.key,
    required this.controller,
  });

  @override
  State<ChatsPageView> createState() => _ChatsPageViewState();
}

class _ChatsPageViewState extends FullState<ChatsPageView> with AutomaticKeepAliveClientMixin, ChatMessageListenner, UserServiceWidgetHelper, ChatServiceWidgetHelper {
  //
  @override
  final chatService = injector.get<ChatService>();
  @override
  final userService = injector.get<UserService>();

  final listenner = ChatRoomDataListenner();
  late final _loading = loadingState(false);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
    initMessageListeners();
  }

  @override
  void dispose() {
    disposeMessageListeners();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _loading.run(() async {
      final rooms = await roomsData();
      listenner.clearRooms();
      listenner.addRooms(rooms);
    });
  }

  @override
  void onReceiveMessage(ChatMessageSent messageSent) async {
    if (!mounted) return;
    final message = messageSent.message;
    final roomId = messageSent.roomId;

    if (listenner.exists(roomId)) {
      listenner.updateRoomLastMessage(roomId, message);
      return;
    }

    listenner.addRoom(await roomData(roomId: roomId));
  }

  @override
  void onReadMessage(ReadMessages readMessages) async {
    if (!mounted) return;
    final roomId = readMessages.roomId;
    final messageIds = readMessages.messageIds;
    final readBy = readMessages.readBy;

    if (listenner.exists(roomId)) {
      final room = listenner.value.firstWhere((room) => room.id == roomId);
      final messages = room.lastMessage;

      if (messages != null) {
        final set = messageIds.toSet();
        if (!set.contains(messages.id)) return;

        if (messages.readBy.any((readBy) => readBy.participantId == readBy.participantId)) return;
        messages.readBy.add(readBy);
        listenner.updateRoomLastMessage(roomId, messages);
      }
    }

    listenner.addRoom(await roomData(roomId: roomId));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _loading.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      initial: () => const SizedBox(),
      error: (error) => Center(child: Text(extractError(error).message)),
      value: (data) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: listenner,
      builder: (context, value, child) {
        if (value.isEmpty) return _buildNoMessages();
        return _buildListRooms(value);
      },
    );
  }

  Widget _buildListRooms(List<ChatRoomData> roomsData) {
    return RefreshIndicator(
      onRefresh: _loadData,
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
                  AutoRouter.of(context).push(ChatRoomRoute(roomData: roomData));
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  title: _buildTitle(roomData),
                  subtitle: _buildSubtitle(roomData),
                  leading: _buildLeading(roomData),
                  trailing: _buildTrailing(roomData),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoMessages() {
    final isProfessional = currentUser.authorities.any((authority) => professionalAuthorities.contains(authority));

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
          isProfessional
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

  Widget _buildTitle(ChatRoomData room) {
    return Text(
        switch (room.room.type) {
          ChatRoomType.group => room.room.name,
          ChatRoomType.private => room.participants.first.fullName,
        },
        style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _buildSubtitle(ChatRoomData room) {
    final lastMessage = room.lastMessage;
    if (lastMessage == null) return const SizedBox();
    final message = switch (lastMessage.type) {
      ChatMessageType.image => 'Imagen',
      ChatMessageType.voice => 'Mensaje de voz',
      _ => lastMessage.message,
    };
    return SizedBox(
      width: 250.0, // Ancho fijo para el subtítulo
      child: Text(
        lastMessage.sentBy == currentUser.id ? 'Tú: $message' : message,
        style: const TextStyle(color: Colors.grey),
        overflow: TextOverflow.ellipsis, // Trunca el texto si es demasiado largo
        maxLines: 1, // Solo una línea
      ),
    );
  }

  Widget _buildLeading(ChatRoomData state) {
    final room = state.room;
    if (room.type == ChatRoomType.group) {
      return const Icon(Icons.group);
    }
    final participant = state.participants.firstWhere((user) => user.id != currentUser.id);
    return buildUserAvatar(participant);
  }

  Widget _buildTrailing(ChatRoomData roomData) {
    final lastMessage = roomData.lastMessage;
    if (lastMessage == null) return const SizedBox();
    if (lastMessage.sentBy == currentUser.id) return const Icon(Icons.chevron_right, color: Colors.grey);

    final readBy = lastMessage.readBy.map((readBy) => readBy.participantId).toSet();
    final isRead = readBy.contains(currentUser.id);

    return isRead ? const Icon(Icons.chevron_right, color: Colors.grey) : Icon(Icons.info, color: Theme.of(context).primaryColor);
  }
}

class UsersPageView extends StatefulWidget {
  const UsersPageView({
    super.key,
  });

  @override
  State<UsersPageView> createState() => _UsersPageViewState();
}

class _UsersPageViewState extends FullState<UsersPageView> with AutomaticKeepAliveClientMixin, UserServiceWidgetHelper, ChatServiceWidgetHelper {
  //
  @override
  final chatService = injector.get<ChatService>();
  @override
  final userService = injector.get<UserService>();
  final pagingController = PagingQueryController<User>(firstPage: 0);
  final searchController = TextEditingController();

  var _authorities = professionalAuthorities;

  @override
  void initState() {
    super.initState();
    pagingController.configurePageRequestListener(_loadPageProfessionals);
    searchController.addListener(Debouncing.build(const Duration(milliseconds: 500), pagingController.refresh));
  }

  Future<List<User>> _loadPageProfessionals(int page) async {
    final result = await userService.page(PageQuery(
      page: page,
      size: 20,
      search: searchController.text,
      params: {
        'authorities': _authorities.map((authority) => authority.authority).toList(),
      },
    ));
    return result.content;
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
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Buscar profesional',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: _openFilterSettings,
          icon: const Icon(Icons.filter_alt_rounded),
        ),
      ),
    );
  }

  Widget _buildListUsers() {
    return RefreshIndicator(
      onRefresh: () => Future.sync(pagingController.refresh),
      child: PagedListView<int, User>(
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<User>(
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('No se encontraron usuarios')),
          firstPageErrorIndicatorBuilder: (context) {
            final error = extractError(pagingController.error);
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
                    onPressed: pagingController.refresh,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          },
          itemBuilder: (context, user, index) {
            if (user.id == currentUser.id) return const SizedBox();
            return TextButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
              ),
              onPressed: () => _openChat(user),
              child: ListTile(
                title: Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('@${user.username}'),
                leading: buildUserAvatar(user),
                trailing: Icon(Icons.chat, color: Theme.of(context).primaryColor),
              ),
            );
          },
        ),
      ),
    );
  }

  _openChat(User user) async {
    showLoadingDialog(context);
    try {
      final room = await roomData(userId: user.id);

      if (!mounted) return;
      Navigator.of(context).pop();
      AutoRouter.of(context).push(ChatRoomRoute(
        roomData: room,
      ));
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
    showProfessionalAuthoritiesSelector(
      context: context,
      onSelected: (authorities) {
        _authorities = authorities;
        pagingController.refresh();
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
