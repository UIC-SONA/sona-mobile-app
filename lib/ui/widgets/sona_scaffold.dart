import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/theme/backgrounds.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/utils/helpers/user_service_widget_helper.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';

class SonaAppBar extends StatelessWidget implements PreferredSizeWidget {
  //
  final Widget actionButton;
  final Widget? title;
  final bool showLeading;

  const SonaAppBar({
    super.key,
    required this.actionButton,
    required this.showLeading,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      leading: showLeading
          ? Builder(
              builder: (context) {
                return IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: Scaffold.of(context).openDrawer,
                  icon: const Icon(Icons.menu),
                );
              },
            )
          : null,
      actions: [actionButton],
      title: title ??
          Row(
            children: [
              SvgPicture.asset(
                height: 45,
                'assets/images/logo.svg',
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(width: 5),
              const Text(
                'Sona',
                style: TextStyle(fontSize: 45, fontWeight: FontWeight.w500),
              ),
            ],
          ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Container(
          color: Colors.white,
          height: 2.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class SonaDrawer extends StatefulWidget {
  const SonaDrawer({super.key});

  @override
  State<SonaDrawer> createState() => _SonaDrawerState();
}

class _SonaDrawerState extends FullState<SonaDrawer> with UserServiceWidgetHelper {
  @override
  final userService = injector.get<UserService>();
  final authProvider = injector.get<AuthProvider>();
  late final anonymizeState = fetchState(([positionalArguments, namedArguments]) => _anonymize(positionalArguments![0]));

  @override
  void initState() {
    super.initState();
    userService.refreshCurrentUser().whenComplete(refresh);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final user = userService.currentUser;

    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            height: 210,
            child: DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildUserAvatar(user, radius: 50),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: anonymizeState.isLoading ? const Text('Cambiando...') : const Text('Modo anónimo'),
            leading: Switch(
              value: user.anonymous,
              onChanged: anonymizeState.isLoading ? null : (value) => anonymizeState.fetch([value]),
            ),
          ),
          ListTile(
            title: const Text('Mi perfil'),
            leading: const Icon(Icons.person),
            onTap: () => AutoRouter.of(context).push(ProfileRoute()),
          ),
          if (kDebugMode)
            ListTile(
              title: const Text('Notificaciones'),
              leading: const Icon(Icons.notifications),
              onTap: () => AutoRouter.of(context).push(SchedulePushRoute()),
            ),
          ListTile(
            title: const Text('Acerca de'),
            leading: const Icon(Icons.info),
            onTap: () => AutoRouter.of(context).pushNamed('/about'),
          ),
          ListTile(
            title: const Text('Cambiar contraseña'),
            leading: const Icon(Icons.lock),
            onTap: () => AutoRouter.of(context).pushNamed('/change-password'),
          ),
          ListTile(
            title: const Text('Cerrar sesión'),
            leading: const Icon(Icons.logout),
            onTap: _showLogoutConfirmDialog,
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmDialog() async {
    final isConfirmed = await showAlertDialog<bool>(
      context,
      title: 'Cerrar sesión',
      message: '¿Estás seguro de que deseas cerrar sesión?',
      actions: {
        'Cancelar': () => Navigator.of(context).pop(false),
        'Aceptar': () => Navigator.of(context).pop(true),
      },
    );

    if (!mounted) return;

    if (isConfirmed != null && isConfirmed) {
      showLoadingDialog(context);
      await authProvider.logout();
      if (mounted) AutoRouter.of(context).replaceAll([const LoginRoute()]);
    }
  }

  Future<void> _anonymize(bool value) async {
    await userService.anonymize(value);
    await userService.refreshCurrentUser();
  }
}

class SonaDrawerItem {
  final String option;
  final Widget icon;
  final VoidCallback onPressed;

  const SonaDrawerItem({
    required this.option,
    required this.icon,
    required this.onPressed,
  });
}

class SonaCardDrawer extends StatelessWidget {
  final String title;
  final List<SonaDrawerItem> items;

  const SonaCardDrawer({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            onTap: () {},
          ),
          Column(
            children: items.map((item) {
              return ListTile(
                title: Text(item.option),
                leading: item.icon,
                onTap: item.onPressed,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SonaScaffold extends StatelessWidget {
  //
  final Widget actionButton;
  final bool showLeading;
  final Widget? appBarTittle;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final double padding;

  const SonaScaffold({
    super.key,
    required this.actionButton,
    this.showLeading = true,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding = 10,
    this.appBarTittle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SonaAppBar(
        actionButton: actionButton,
        showLeading: showLeading,
        title: appBarTittle,
      ),
      drawer: showLeading ? const SonaDrawer() : null,
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: body,
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class SonaActionButton extends StatelessWidget {
  //
  final String text;
  final void Function(BuildContext) onPressed;

  const SonaActionButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 10)),
          backgroundColor: WidgetStateProperty.all(Colors.white),
          foregroundColor: WidgetStateProperty.all(Colors.black),
        ),
        onPressed: () {
          onPressed(context);
        },
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  factory SonaActionButton.home() {
    return SonaActionButton(
      text: 'Inicio',
      onPressed: (context) => AutoRouter.of(context).popUntil((route) => route.isFirst),
    );
  }

  factory SonaActionButton.options() {
    return SonaActionButton(
      text: 'Opciones',
      onPressed: (context) => AutoRouter.of(context).push(const MenuOptionsRoute()),
    );
  }
}
